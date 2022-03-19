import 'dart:ffi';
import 'dart:io';
import 'package:ffi/ffi.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:win32/win32.dart';
import 'package:winss/screenshot.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;
  int keypresses = 0;

  int _enterCounter = 0;
  int _exitCounter = 0;
  double x = 0.0;
  double y = 0.0;

  void _incrementEnter(PointerEvent details) {
    setState(() {
      _enterCounter++;
    });
  }

  void _incrementExit(PointerEvent details) {
    setState(() {
      _exitCounter++;
    });
  }

  void _updateLocation(PointerEvent details) {
    setState(() {
      x = details.position.dx;
      y = details.position.dy;
    });
  }

  void takess() {
    // Register the window class.
    final className = TEXT('GDI Image Capture');

    final wc = calloc<WNDCLASS>()
      ..ref.style = CS_HREDRAW | CS_VREDRAW
      ..ref.lpfnWndProc = Pointer.fromFunction<WindowProc>(mainWindowProc, 0)
      ..ref.hInstance = hInstance
      ..ref.lpszClassName = className
      ..ref.hCursor = LoadCursor(NULL, IDC_ARROW)
      ..ref.hbrBackground = GetStockObject(WHITE_BRUSH);
    RegisterClass(wc);

    // Create the window.

    final hWnd = CreateWindowEx(
        0,
        // Optional window styles.
        className,
        // Window class
        className,
        // Window caption
        WS_OVERLAPPEDWINDOW,
        // Window style

        // Size and position
        CW_USEDEFAULT,
        0,
        CW_USEDEFAULT,
        0,
        NULL,
        // Parent window
        NULL,
        // Menu
        hInstance,
        // Instance handle
        nullptr // Additional application data
        );

    if (hWnd == FALSE) {
      exit(-1);
    }

    ShowWindow(hWnd, SW_SHOWNORMAL);
    UpdateWindow(hWnd);
    DestroyWindow(hWnd);

    // Run the message loop
    final msg = calloc<MSG>();
    while (GetMessage(msg, NULL, 0, 0) != FALSE) {
      TranslateMessage(msg);
      DispatchMessage(msg);
    }
  }

  void _incrementCounter() {
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return RawKeyboardListener(
      autofocus: true,
      focusNode: FocusNode(),
      onKey: (event) {
        if (event is RawKeyDownEvent) {
          setState(() {
            keypresses++;
          });

          print("Total Key Presses = " + keypresses.toString());
        }
      },
      child: Scaffold(
        appBar: AppBar(
          // Here we take the value from the MyHomePage object that was created by
          // the App.build method, and use it to set our appbar title.
          title: Text(widget.title),
        ),
        body: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints.tight(const Size(400.0, 400.0)),
            child: MouseRegion(
              onEnter: _incrementEnter,
              onHover: _updateLocation,
              onExit: _incrementExit,
              child: Container(
                color: Colors.lightBlueAccent,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    const Text(
                        'You have entered or exited this box this many times:'),
                    Text(
                      '$_enterCounter Entries\n$_exitCounter Exits',
                      style: Theme.of(context).textTheme.headline4,
                    ),
                    Text(
                      'The cursor is here: (${x.toStringAsFixed(2)}, ${y.toStringAsFixed(2)})',
                    ),

                    
                    Padding(
                      padding: const EdgeInsets.fromLTRB(0, 40, 0, 0),
                      // child: const Text(
                      //   'You have pushed the button this many times:',
                      // ),

                      child: const Text(
                        'You have pressed keys on the keyborad this many times:',
                      ),
                    ),
                    // Text(
                    //   '$_counter',
                    //   style: Theme.of(context).textTheme.headline4,
                    // ),
                    Text(
                      '$keypresses',
                      style: Theme.of(context).textTheme.headline4,
                    ),
                  ],
                ),
              ),
            ),
          ),

        ),
        floatingActionButton: FloatingActionButton(
          onPressed: takess,
          // onPressed: _incrementCounter,
          tooltip: 'Take Screenshot',
          child: const Icon(Icons.add),
        ), // This trailing comma makes auto-formatting nicer for build methods.
      ),
    );
  }
}

// Center(
// // Center is a layout widget. It takes a single child and positions it
// // in the middle of the parent.
// child: Column(
// // Column is also a layout widget. It takes a list of children and
// // arranges them vertically. By default, it sizes itself to fit its
// // children horizontally, and tries to be as tall as its parent.
// //
// // Invoke "debug painting" (press "p" in the console, choose the
// // "Toggle Debug Paint" action from the Flutter Inspector in Android
// // Studio, or the "Toggle Debug Paint" command in Visual Studio Code)
// // to see the wireframe for each widget.
// //
// // Column has various properties to control how it sizes itself and
// // how it positions its children. Here we use mainAxisAlignment to
// // center the children vertically; the main axis here is the vertical
// // axis because Columns are vertical (the cross axis would be
// // horizontal).
// mainAxisAlignment: MainAxisAlignment.center,
// children: <Widget>[
// const Text(
// 'You have pushed the button this many times:',
// ),
// Text(
// '$_counter',
// style: Theme.of(context).textTheme.headline4,
// ),
// ],
// ),
// ),
