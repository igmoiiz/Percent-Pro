import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../providers/calculator_provider.dart';

class AdManager {
  static InterstitialAd? _interstitialAd;
  static RewardedAd? _rewardedAd;

  // Actual Production IDs
  static const String _prodInterstitialId =
      'ca-app-pub-7995233823810215/9706871767';
  static const String _prodRewardedId =
      'ca-app-pub-7995233823810215/5306472656';
  static const String _prodBannerId = 'ca-app-pub-7995233823810215/6530044087';

  // Google Test IDs (Universal)
  static const String _testInterstitialId =
      'ca-app-pub-3940256099942544/1033173712';
  static const String _testRewardedId =
      'ca-app-pub-3940256099942544/5224354917';
  static const String _testBannerId = 'ca-app-pub-3940256099942544/6300978111';

  // Helper to get correct ID based on mode
  static String get bannerAdUnitId =>
      kDebugMode ? _testBannerId : _prodBannerId;
  static String get interstitialAdUnitId =>
      kDebugMode ? _testInterstitialId : _prodInterstitialId;
  static String get rewardedAdUnitId =>
      kDebugMode ? _testRewardedId : _prodRewardedId;

  // --- Interstitial Ads ---

  static void loadInterstitial() {
    InterstitialAd.load(
      adUnitId: interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
        },
        onAdFailedToLoad: (err) {
          _interstitialAd = null;
        },
      ),
    );
  }

  static void showInterstitial({required VoidCallback onAdClosed}) {
    if (_interstitialAd != null) {
      _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
        onAdDismissedFullScreenContent: (ad) {
          ad.dispose();
          loadInterstitial();
          onAdClosed();
        },
        onAdFailedToShowFullScreenContent: (ad, err) {
          ad.dispose();
          loadInterstitial();
          onAdClosed();
        },
      );
      _interstitialAd!.show();
    } else {
      onAdClosed();
      loadInterstitial();
    }
  }

  // --- Rewarded Ads ---

  static void loadRewarded() {
    RewardedAd.load(
      adUnitId: rewardedAdUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          _rewardedAd = ad;
        },
        onAdFailedToLoad: (err) {
          _rewardedAd = null;
        },
      ),
    );
  }

  static void showRewarded({
    required Function(RewardItem) onRewardEarned,
    required VoidCallback onAdClosed,
    required VoidCallback onAdFailed,
  }) {
    if (_rewardedAd != null) {
      _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
        onAdDismissedFullScreenContent: (ad) {
          ad.dispose();
          loadRewarded();
          onAdClosed();
        },
        onAdFailedToShowFullScreenContent: (ad, err) {
          ad.dispose();
          loadRewarded();
          onAdFailed();
        },
      );

      _rewardedAd!.show(
        onUserEarnedReward: (ad, reward) {
          onRewardEarned(reward);
        },
      );
    } else {
      onAdFailed();
      loadRewarded();
    }
  }

  // --- Trigger Logic ---

  static void showInterstitialIfNeeded(CalculatorProvider provider) {
    if (provider.areAdsRemoved) return;

    provider.incrementCalcCount();
    if (provider.calcCount >= 3) {
      AdManager.showInterstitial(
        onAdClosed: () {
          provider.resetCalcCount();
        },
      );
    }
  }
}
