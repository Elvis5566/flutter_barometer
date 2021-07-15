import 'dart:async';

import 'package:flutter/services.dart';

class FlutterBarometer {
  static const MethodChannel _methodChannel = const MethodChannel('flutter_barometer/method');

  static const EventChannel _eventChannel = const EventChannel('flutter_barometer/event');

  static FlutterBarometer instance = FlutterBarometer();

  Future<bool> get isValid async {
    final result = await _methodChannel.invokeMethod<bool>('isValid');
    return result!;
  }

  Stream<BarometerData>? _stream;

  Stream<BarometerData> get stream {
    if (_stream != null) return _stream!;
    _stream = _eventChannel.receiveBroadcastStream().map((event) => BarometerData(event["pressure"], event["altitude"]));
    return _stream!;
  }
}

class BarometerData {
  BarometerData(this.pressure, this.altitude);

  final double pressure;
  final double altitude;
}
