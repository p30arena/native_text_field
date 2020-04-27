import 'dart:async';

import 'package:flutter/services.dart';

class NativeTextField {
  static const MethodChannel _channel =
      const MethodChannel('native_text_field');

  static Future<String> get platformVersion async {
    final String version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }
}
