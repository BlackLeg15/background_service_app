import 'package:flutter/services.dart';

class KeepAppOnChannel {
  final _methodChannel = const MethodChannel('com.example.background_service_app/keep_app_on');

  Future<void> initService() async {
    await _methodChannel.invokeMethod('initService');
  }
  Future<void> stopService() async {
    await _methodChannel.invokeMethod('stopService');
  }
}
