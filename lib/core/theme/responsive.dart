import 'package:flutter/material.dart';

extension ResponsiveContext on BuildContext {
  Size get _size => MediaQuery.sizeOf(this);
  double get screenW => _size.width;
  double get screenH => _size.height;

  bool get isSmallPhone => _size.width < 360;
  bool get isPhone => _size.width < 600;
  bool get isTablet => _size.width >= 600 && _size.width < 900;
  bool get isLargeTablet => _size.width >= 900;

  double wp(double percent) => _size.width * percent / 100;
  double hp(double percent) => _size.height * percent / 100;

  double sp(double size) {
    final scale = (_size.width / 375).clamp(0.85, 1.4);
    return size * scale;
  }

  double get pagePadding {
    if (isLargeTablet) return 64;
    if (isTablet) return 40;
    if (isSmallPhone) return 16;
    return 24;
  }

  double get maxContentWidth {
    if (isLargeTablet) return 560;
    if (isTablet) return 520;
    return _size.width;
  }
}

class ResponsiveBox extends StatelessWidget {
  final Widget child;
  const ResponsiveBox({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    // Force the wrapped screen to fully rebuild whenever the resolved
    // brightness flips. Subscribing to Theme alone is not enough because
    // [child] is a stored widget reference, so Flutter would reuse the
    // existing element subtree and the static AppColors.surfaceLight /
    // .tint adaptive getters would never get re-read. Keying the subtree
    // by brightness invalidates it on each flip, at the cost of resetting
    // local screen state (e.g. scroll position) — acceptable for a rare
    // theme-toggle event.
    final brightness = Theme.of(context).brightness;
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: context.maxContentWidth),
        child: KeyedSubtree(
          key: ValueKey<Brightness>(brightness),
          child: child,
        ),
      ),
    );
  }
}
