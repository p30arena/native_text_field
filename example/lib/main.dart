import 'dart:async';

import 'package:flutter/material.dart';

import 'package:native_text_field/native_text_field.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Completer<NativeTextEditingController> _controller = Completer();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        fontFamily: "Shabnam",
      ),
      home: Scaffold(
        appBar: AppBar(
          title: const Text('NativeTextField'),
        ),
        body: Center(
          child: Column(
            children: [
              SizedBox(
                height: 80,
                child: NativeTextField(
                  // fontAsset: "assets/fonts/IRANSans.ttf",
                  fontAsset: "assets/fonts/Shabnam-FD.ttf",
                  onCreated: (controller) {
                    _controller.complete(controller);
                    controller.text = "سلام 123 eng تست";
                  },
                ),
              ),
              RaisedButton(
                onPressed: () {},
                child: Text("ارسال"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
