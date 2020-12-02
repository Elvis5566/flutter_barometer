import 'dart:async';

import 'package:flutter/services.dart';

class FlutterBarometer {
  static const MethodChannel _methodChannel = const MethodChannel('flutter_barometer/method');

  static const EventChannel _eventChannel = const EventChannel('flutter_barometer/event');

  static Future<bool> get isValid => _methodChannel.invokeMethod('isValid');

  static var _streamCount = 0;

  static Stream<BarometerData> get stream {
    return _eventChannel.receiveBroadcastStream(_streamCount++).map((event) => BarometerData(event["pressure"], event["altitude"]));
  }
}

class BarometerData {
  BarometerData(this.pressure, this.altitude);

  final double pressure;
  final double altitude;
}
