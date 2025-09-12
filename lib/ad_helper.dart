import 'dart:io';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdHelper {
  static String get bannerAdUnitId {
    if (Platform.isAndroid) {
      return 'ca-app-pub-6836526074800523/8692203491'; // Replace with your actual banner ad unit ID
    } else {
      throw UnsupportedError('Unsupported platform');
    }
  }

  static String get testBannerAdUnitId {
    if (Platform.isAndroid) {
      return 'ca-app-pub-3940256099942544/6300978111';
    }else {
      throw UnsupportedError('Unsupported platform');
    }
  }

  static const bool useTestAds = true; // Set to false for production

  static String getBannerAdUnitId() {
    return useTestAds ? testBannerAdUnitId : bannerAdUnitId;
  }

  static Future<void> initializeAds() async {
    await MobileAds.instance.initialize();
  }
}
