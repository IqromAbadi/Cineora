import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/glass_container.dart';

/// Pinned strip that keeps search reachable while posters scroll under it.
class SearchHeaderDelegate extends SliverPersistentHeaderDelegate {
  SearchHeaderDelegate({
    required this.child,
    required this.gutter,
    required this.textScaler,
  });

  final Widget child;
  final double gutter;
  final TextScaler textScaler;

  static const _verticalPadding = 12.0;

  double get _fieldHeight =>
      math.max(56, 32 + textScaler.scale(16) * 1.35);

  @override
  double get minExtent => _fieldHeight + _verticalPadding * 2;

  @override
  double get maxExtent => minExtent;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlaps) {
    return GlassContainer(
      tint: AppColors.background,
      opacity: overlaps ? 0.86 : 1,
      blur: overlaps ? 18 : 0,
      borderRadius: BorderRadius.zero,
      border: overlaps
          ? const Border(bottom: BorderSide(color: AppColors.border))
          : null,
      padding: EdgeInsets.symmetric(
        horizontal: gutter,
        vertical: _verticalPadding,
      ),
      child: Align(alignment: Alignment.topCenter, child: child),
    );
  }

  @override
  bool shouldRebuild(SearchHeaderDelegate oldDelegate) =>
      oldDelegate.child != child ||
      oldDelegate.gutter != gutter ||
      oldDelegate.textScaler != textScaler;
}
