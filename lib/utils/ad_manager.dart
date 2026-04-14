import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../providers/calculator_provider.dart';

class AdManager {
  static InterstitialAd? _interstitialAd;
  static RewardedAd? _rewardedAd;

  static const String _interstitialAdUnitId =
      'ca-app-pub-7995233823810215/9706871767';
  static const String _rewardedAdUnitId =
      'ca-app-pub-7995233823810215/5306472656';
  static const String _rewardedAdTestId =
      'ca-app-pub-3940256099942544/5224354917';

  // --- Interstitial Ads ---

  static void loadInterstitial() {
    InterstitialAd.load(
      adUnitId: _interstitialAdUnitId,
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
          loadInterstitial(); // Preload next
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
      adUnitId: kDebugMode ? _rewardedAdTestId : _rewardedAdUnitId,
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
          loadRewarded(); // Preload next
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
