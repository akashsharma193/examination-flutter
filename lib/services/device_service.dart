import 'package:flutter/foundation.dart';
import 'package:flutter_udid/flutter_udid.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

class DeviceService {
  DeviceService._();

  static final DeviceService _instance = DeviceService._();

  static DeviceService get instance => _instance;

  Future<String> get uniqueDeviceId async {
    if (kIsWeb) {
      return _getDeviceId();
    } else {
      return await FlutterUdid.consistentUdid;
    }
  }

  Future<String> _getDeviceId() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String? deviceId = prefs.getString('device_id');

    if (deviceId == null) {
      deviceId = const Uuid().v4(); // Generate a random UUID
      await prefs.setString('device_id', deviceId);
    }

    return deviceId;
  }
}
