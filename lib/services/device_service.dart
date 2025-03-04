import 'package:flutter_udid/flutter_udid.dart';

class DeviceService {
  DeviceService._();

  static final DeviceService _instance = DeviceService._();

  static DeviceService get instance => _instance;

  Future<String> get uniqueDeviceId async {
    return await FlutterUdid.consistentUdid;
  }
}
