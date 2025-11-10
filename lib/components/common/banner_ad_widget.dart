import 'package:flutter/material.dart';
import '../../widgets/common/ad_banner.dart';

/// Banner ad widget wrapper
class BannerAdWidget extends StatelessWidget {
  final VoidCallback? onAdLoaded;
  final VoidCallback? onAdFailedToLoad;
  final VoidCallback? onAdClicked;

  const BannerAdWidget({
    super.key,
    this.onAdLoaded,
    this.onAdFailedToLoad,
    this.onAdClicked,
  });

  @override
  Widget build(BuildContext context) {
    return AdBanner(
      height: 60,
      onAdLoaded: onAdLoaded,
      onAdFailedToLoad: onAdFailedToLoad,
    );
  }
}

