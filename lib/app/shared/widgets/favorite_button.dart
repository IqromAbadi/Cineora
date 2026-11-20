import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/theme/app_colors.dart';

enum FavoriteButtonStyle { overlay, outlined }

class FavoriteButton extends StatelessWidget {
  const FavoriteButton({
    super.key,
    required this.isFavorite,
    required this.onPressed,
    this.style = FavoriteButtonStyle.overlay,
  });

  final bool isFavorite;
  final VoidCallback onPressed;
  final FavoriteButtonStyle style;

  @override
  Widget build(BuildContext context) {
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    // Re-keyed on every change so the pop plays once per toggle and confirms the tap.
    final icon = TweenAnimationBuilder<double>(
      key: ValueKey(isFavorite),
      tween: Tween(begin: reduceMotion ? 1 : 0.6, end: 1),
      duration: Duration(milliseconds: reduceMotion ? 0 : 320),
      curve: Curves.easeOutBack,
      builder: (context, scale, child) =>
          Transform.scale(scale: scale, child: child),
      child: Icon(
        isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
        color: isFavorite ? AppColors.accent : AppColors.textPrimary,
        size: 22,
      ),
    );

    return IconButton(
      tooltip: isFavorite ? 'Remove from favorites' : 'Add to favorites',
      isSelected: isFavorite,
      onPressed: () {
        HapticFeedback.selectionClick();
        onPressed();
      },
      style: IconButton.styleFrom(
        minimumSize: const Size.square(44),
        backgroundColor: style == FavoriteButtonStyle.overlay
            ? AppColors.background.withValues(alpha: 0.62)
            : AppColors.glass,
        side: style == FavoriteButtonStyle.outlined
            ? const BorderSide(color: AppColors.border)
            : null,
      ),
      icon: icon,
    );
  }
}
