import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

/// Test devices that should always receive test ads through the real ad
/// unit IDs. Add a device by running the app once, then copying the ID
/// printed in logcat (search for "Use RequestConfiguration"). Each device
/// you add lets you safely tap your live ad unit during development without
/// risking your AdMob account for invalid traffic.
const List<String> kAdMobTestDeviceIds = <String>[
  // Paste your device ID here, e.g. 'EMULATOR' or 'A1B2C3D4E5F6...'.
];

/// Call once at app startup before any ad is requested.
Future<void> initAdMob() async {
  await MobileAds.instance.initialize();
  await MobileAds.instance.updateRequestConfiguration(
    RequestConfiguration(testDeviceIds: kAdMobTestDeviceIds),
  );
}

/// Loads + shows a single rewarded ad. Calls [onEarnedReward] only when the
/// user actually finished watching. Calls [onFailed] if loading or showing
/// fails (network, no fill, user closed early).
class RewardedAdService {
  // Production rewarded ad unit. While developing, add your device ID to
  // [kAdMobTestDeviceIds] so AdMob serves test ads through this same unit.
  // iOS uses Google's official test unit until an iOS app is created in
  // AdMob — replace it with your real iOS rewarded unit ID then.
  static String get _rewardedUnitId => defaultTargetPlatform ==
          TargetPlatform.iOS
      ? 'ca-app-pub-3940256099942544/1712485313'
      : 'ca-app-pub-3861936402709464/3094225329';

  Future<void> showRewarded({
    required void Function() onEarnedReward,
    required void Function(String message) onFailed,
  }) async {
    try {
      await RewardedAd.load(
        adUnitId: _rewardedUnitId,
        request: const AdRequest(),
        rewardedAdLoadCallback: RewardedAdLoadCallback(
          onAdLoaded: (ad) {
            ad.fullScreenContentCallback = FullScreenContentCallback(
              onAdDismissedFullScreenContent: (ad) => ad.dispose(),
              onAdFailedToShowFullScreenContent: (ad, err) {
                ad.dispose();
                onFailed('Could not show ad: ${err.message}');
              },
            );
            ad.show(
              onUserEarnedReward: (_, reward) {
                onEarnedReward();
              },
            );
          },
          onAdFailedToLoad: (err) {
            // Surface enough context to debug "no fill" / unapproved-unit
            // errors. The Google SDK prints the test-device hint on its own;
            // we just mirror the load error to the in-app message.
            if (kDebugMode) {
              developer.log(
                'Rewarded ad failed to load: code=${err.code} domain=${err.domain} '
                'message=${err.message} responseInfo=${err.responseInfo}',
                name: 'ads',
              );
            }
            onFailed('Ad failed to load: ${err.message}');
          },
        ),
      );
    } catch (e) {
      onFailed('Ad service error: $e');
    }
  }
}
