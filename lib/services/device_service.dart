import 'package:flutter_udid/flutter_udid.dart';

class DeviceService {
  DeviceService._() {
    _initialize();
  }

  static final DeviceService _instance = DeviceService._();

  static DeviceService get instance => _instance;

  late String uniqueDeviceId;
  bool _isInitialized = false;

  Future<void> _initialize() async {
    if (!_isInitialized) {
      uniqueDeviceId = await FlutterUdid.udid;
      _isInitialized = true;
    }
  }
}
