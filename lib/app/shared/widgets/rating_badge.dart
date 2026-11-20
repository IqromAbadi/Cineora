import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';

class RatingBadge extends StatelessWidget {
  const RatingBadge({super.key, required this.rating, this.votes});

  final double rating;
  final String? votes;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final value = rating.toStringAsFixed(1);
    final voteLabel = votes;
    return Semantics(
      label: 'IMDb rating $value out of 10'
          '${voteLabel == null ? '' : ', $voteLabel votes'}',
      child: ExcludeSemantics(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.glass,
            borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
            border: Border.all(color: AppColors.border),
          ),
          child: Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 6,
            children: [
              const Icon(Icons.star_rounded, color: AppColors.accent, size: 20),
              Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: value,
                      style: text.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    TextSpan(
                      text: ' / 10',
                      style: text.labelMedium,
                    ),
                  ],
                ),
              ),
              Text(
                voteLabel == null ? 'IMDb' : 'IMDb · $voteLabel votes',
                style: text.labelMedium,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
