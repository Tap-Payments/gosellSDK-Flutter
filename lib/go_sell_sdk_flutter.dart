import 'dart:async';

import 'package:flutter/services.dart';

class GoSellSdkFlutter {
  static const MethodChannel _channel =
      const MethodChannel('go_sell_sdk_flutter');

  static Future<String> get platformVersion async {
    // final String version = await _channel.invokeMethod('getPlatformVersion');
    final String version = await _channel.invokeMethod('start_sdk');
    return version;
  }
}
