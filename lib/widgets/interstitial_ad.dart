import 'package:crackitx/ad_helper.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

InterstitialVideoAdManagerState? _globalAdManagerState;

class InterstitialVideoAdManager extends StatefulWidget {
  final Widget child;
  final VoidCallback? onAdClosed;
  final VoidCallback? onAdFailedToLoad;

  const InterstitialVideoAdManager({
    super.key,
    required this.child,
    this.onAdClosed,
    this.onAdFailedToLoad,
  });

  @override
  State<InterstitialVideoAdManager> createState() =>
      InterstitialVideoAdManagerState();

  static InterstitialVideoAdManagerState? get current => _globalAdManagerState;
}

class InterstitialVideoAdManagerState
    extends State<InterstitialVideoAdManager> {
  InterstitialAd? _interstitialAd;
  bool _isLoaded = false;
  bool _isLoading = false;
  late InterstitialVideoAdManager widget;

  @override
  void initState() {
    super.initState();
    this.widget = super.widget;
    _globalAdManagerState = this;
    _loadAd();
  }

  void _loadAd() {
    if (_isLoading) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final adUnitId = AdHelper.getInterstitialVideoAdUnitId();

    InterstitialAd.load(
      adUnitId: adUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
          setState(() {
            _isLoaded = true;
            _isLoading = false;
          });

          ad.fullScreenContentCallback = FullScreenContentCallback(
            onAdShowedFullScreenContent: (ad) {},
            onAdDismissedFullScreenContent: (ad) {
              ad.dispose();
              setState(() {
                _isLoaded = false;
                _interstitialAd = null;
              });
              widget.onAdClosed?.call();
              Future.delayed(const Duration(milliseconds: 500), () {
                if (mounted) _loadAd();
              });
            },
            onAdFailedToShowFullScreenContent: (ad, error) {
              ad.dispose();
              setState(() {
                _isLoaded = false;
                _interstitialAd = null;
              });
              widget.onAdFailedToLoad?.call();
            },
          );
        },
        onAdFailedToLoad: (error) {
          setState(() {
            _isLoaded = false;
            _isLoading = false;
          });
          widget.onAdFailedToLoad?.call();
        },
      ),
    );
  }

  void loadAdDirectly({
    required VoidCallback onAdReady,
    required VoidCallback onAdFailed,
  }) {
    if (_isLoading) {
      Future.delayed(const Duration(milliseconds: 100), () {
        loadAdDirectly(onAdReady: onAdReady, onAdFailed: onAdFailed);
      });
      return;
    }

    if (_isLoaded && _interstitialAd != null) {
      onAdReady();
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final adUnitId = AdHelper.getInterstitialVideoAdUnitId();

    InterstitialAd.load(
      adUnitId: adUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
          setState(() {
            _isLoaded = true;
            _isLoading = false;
          });

          ad.fullScreenContentCallback = FullScreenContentCallback(
            onAdShowedFullScreenContent: (ad) {},
            onAdDismissedFullScreenContent: (ad) {
              ad.dispose();
              setState(() {
                _isLoaded = false;
                _interstitialAd = null;
              });
              widget.onAdClosed?.call();
            },
            onAdFailedToShowFullScreenContent: (ad, error) {
              ad.dispose();
              setState(() {
                _isLoaded = false;
                _interstitialAd = null;
              });
              onAdFailed();
            },
          );

          onAdReady();
        },
        onAdFailedToLoad: (error) {
          setState(() {
            _isLoaded = false;
            _isLoading = false;
          });
          onAdFailed();
        },
      ),
    );
  }

  void showAd() {
    if (_interstitialAd != null && _isLoaded) {
      _interstitialAd!.show();
    } else {
      widget.onAdFailedToLoad?.call();
    }
  }

  bool get isAdReady {
    return _isLoaded && _interstitialAd != null;
  }

  @override
  void dispose() {
    if (_globalAdManagerState == this) {
      _globalAdManagerState = null;
    }
    _interstitialAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}

class InterstitialVideoAdButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final String buttonText;
  final bool showAdFirst;
  final VoidCallback? onAdClosed;
  final VoidCallback? onAdFailedToLoad;

  const InterstitialVideoAdButton({
    super.key,
    this.onPressed,
    this.buttonText = 'Continue',
    this.showAdFirst = true,
    this.onAdClosed,
    this.onAdFailedToLoad,
  });

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (context) {
        InterstitialVideoAdManagerState? adManager =
            context.findAncestorStateOfType<InterstitialVideoAdManagerState>();
        adManager ??= InterstitialVideoAdManager.current;

        return ElevatedButton(
          onPressed: () {
            if (showAdFirst && adManager != null && adManager.isAdReady) {
              adManager.showAd();
            } else {
              onPressed?.call();
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: Text(buttonText),
        );
      },
    );
  }
}

