import 'dart:io';
import 'package:package_info_plus/package_info_plus.dart';

class AppPackageService {
  AppPackageService._();

  static final AppPackageService _instance = AppPackageService._();

  static AppPackageService get instance => _instance;

  late PackageInfo _info;
  bool _isInitialized = false;

  Future<void> initialize() async {
    if (!_isInitialized) {
      _info = await PackageInfo.fromPlatform();
      _isInitialized = true;
    }
  }

  String get appVersion {
    if (!_isInitialized) {
      throw Exception(
          "AppPackageService is not initialized. Call instance first.");
    }
    return "${Platform.isAndroid ? 'ANDROID' : 'IOS'} ${_info.version}+${_info.buildNumber}";
  }

  String get appName {
    if (!_isInitialized) {
      throw Exception(
          "AppPackageService is not initialized. Call instance first.");
    }
    return _info.appName;
  }
}
