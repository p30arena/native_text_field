import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';

typedef OnNativeTextFieldCreated = void Function(
    NativeTextEditingController controller);

class NativeTextField extends StatefulWidget {
  final OnNativeTextFieldCreated onCreated;
  final String fontAsset;

  const NativeTextField({
    Key key,
    this.onCreated,
    this.fontAsset,
  }) : super(key: key);

  @override
  _NativeTextFieldState createState() => _NativeTextFieldState();
}

class _NativeTextFieldState extends State<NativeTextField> {
  NativeTextEditingController controller;

  @override
  void didUpdateWidget(NativeTextField oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.fontAsset != widget.fontAsset) {
      setParams();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (defaultTargetPlatform == TargetPlatform.android) {
      return AndroidView(
        viewType: 'native_text_field',
        onPlatformViewCreated: _onPlatformViewCreated,
        hitTestBehavior: PlatformViewHitTestBehavior.translucent,
      );
    }

    return Text(
        '$defaultTargetPlatform is not yet supported by the text_view plugin');
  }

  void _onPlatformViewCreated(int id) {
    controller = NativeTextEditingController._(id);
    widget.onCreated(controller);
    setParams();
  }

  setParams() {
    if (widget.fontAsset != null) {
      controller._channel.invokeMethod("setFont", widget.fontAsset);
    }
  }
}

class NativeTextEditingController extends ValueNotifier<TextEditingValue> {
  NativeTextEditingController._(int id, {String text})
      : _channel = MethodChannel('native_text_field_$id'),
        _eventChannel = EventChannel('native_text_field_$id/text_change'),
        super(text == null
            ? TextEditingValue.empty
            : TextEditingValue(text: text)) {
    _onTextChanged = _eventChannel
        .receiveBroadcastStream()
        .map((dynamic event) => event as String);

    _onTextChanged.listen((event) {
      _setValue(event);
    });
  }

  final MethodChannel _channel;
  final EventChannel _eventChannel;

  Stream<String> _onTextChanged;

  String get text => value.text;

  _setValue(String newText) {
    value = value.copyWith(
      text: newText,
      selection: const TextSelection.collapsed(offset: -1),
      composing: TextRange.empty,
    );
  }

  set text(String newText) {
    _setValue(newText);
    _channel.invokeMethod('setText', newText);
  }

  void clear() {
    value = TextEditingValue.empty;
    _channel.invokeMethod('setText', "");
  }
}
