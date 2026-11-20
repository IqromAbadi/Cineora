import 'dart:ui';

import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';

/// Frosted surface for chrome that floats over scrolling posters.
/// Pass `blur: 0` for a solid tinted surface when nothing moves beneath it.
class GlassContainer extends StatelessWidget {
  const GlassContainer({
    super.key,
    required this.child,
    this.blur = 20,
    this.tint = AppColors.glass,
    this.opacity = 0.82,
    this.borderRadius = const BorderRadius.all(
      Radius.circular(AppTheme.radiusMedium),
    ),
    this.padding = EdgeInsets.zero,
    this.border = const Border.fromBorderSide(
      BorderSide(color: AppColors.border),
    ),
  });

  final Widget child;
  final double blur;
  final Color tint;
  final double opacity;
  final BorderRadius borderRadius;
  final EdgeInsetsGeometry padding;
  final BoxBorder? border;

  @override
  Widget build(BuildContext context) {
    Widget surface = DecoratedBox(
      decoration: BoxDecoration(
        color: tint.withValues(alpha: opacity),
        borderRadius: borderRadius,
        border: border,
      ),
      child: Padding(padding: padding, child: child),
    );
    if (blur > 0) {
      surface = BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: surface,
      );
    }
    return ClipRRect(borderRadius: borderRadius, child: surface);
  }
}
