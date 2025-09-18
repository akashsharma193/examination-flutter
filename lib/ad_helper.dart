import 'dart:io';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdHelper {
  static String get bannerAdUnitId {
    if (Platform.isAndroid) {
      return 'ca-app-pub-6836526074800523/9549257078';
    } else {
      throw UnsupportedError('Unsupported platform');
    }
  }

  static String get testBannerAdUnitId {
    if (Platform.isAndroid) {
      return 'ca-app-pub-3940256099942544/6300978111';
    } else {
      throw UnsupportedError('Unsupported platform');
    }
  }

  static String get interstitialVideoAdUnitId {
    if (Platform.isAndroid) {
      return 'ca-app-pub-6836526074800523/7714620590';
    } else {
      throw UnsupportedError('Unsupported platform');
    }
  }

  static String get testInterstitialVideoAdUnitId {
    if (Platform.isAndroid) {
      return 'ca-app-pub-3940256099942544/1033173712';
    } else {
      throw UnsupportedError('Unsupported platform');
    }
  }

  static const bool useTestAds = false;

  static String getBannerAdUnitId() {
    final adUnitId = useTestAds ? testBannerAdUnitId : bannerAdUnitId;
    print('🎯 Banner Ad Unit ID: $adUnitId');
    print('🎯 Using ${useTestAds ? "TEST" : "PRODUCTION"} banner ads');
    return adUnitId;
  }

  static String getInterstitialVideoAdUnitId() {
    final adUnitId =
        useTestAds ? testInterstitialVideoAdUnitId : interstitialVideoAdUnitId;
    print('🎯 Interstitial Video Ad Unit ID: $adUnitId');
    print(
        '🎯 Using ${useTestAds ? "TEST" : "PRODUCTION"} interstitial video ads');
    return adUnitId;
  }

  static bool isUsingTestAds() => useTestAds;
  static String getCurrentAdType() => useTestAds ? "TEST" : "PRODUCTION";

  static Future<void> initializeAds() async {
    try {
      await MobileAds.instance.initialize();
      await MobileAds.instance.updateRequestConfiguration(
        RequestConfiguration(
          testDeviceIds: [],
          tagForChildDirectedTreatment:
              TagForChildDirectedTreatment.unspecified,
          tagForUnderAgeOfConsent: TagForUnderAgeOfConsent.unspecified,
        ),
      );
      print('🎯 Request configuration updated');
    } catch (e) {
      print('🎯 Error initializing Mobile Ads: $e');
    }
  }
}
