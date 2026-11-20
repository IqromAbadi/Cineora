import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../data/models/movie_detail.dart';
import '../../../../data/models/movie_summary.dart';
import '../../../../shared/widgets/movie_poster.dart';
import '../../../../shared/widgets/rating_badge.dart';

class DetailHeader extends StatelessWidget {
  const DetailHeader({
    super.key,
    required this.movie,
    required this.detail,
    required this.heroTag,
    required this.isFavorite,
    required this.onFavoritePressed,
    required this.wide,
  });

  final MovieSummary movie;
  final MovieDetail? detail;
  final String heroTag;
  final bool isFavorite;
  final VoidCallback onFavoritePressed;
  final bool wide;

  @override
  Widget build(BuildContext context) {
    final poster = MoviePoster(
      url: detail?.posterUrl ?? movie.posterUrl,
      title: movie.title,
      heroTag: heroTag,
      borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
    );

    if (wide) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          SizedBox(
            width: 260,
            child: AspectRatio(aspectRatio: 2 / 3, child: poster),
          ),
          const SizedBox(width: 32),
          Expanded(child: _info(context, CrossAxisAlignment.start)),
        ],
      );
    }

    final posterWidth = (MediaQuery.sizeOf(context).width * 0.56).clamp(
      150.0,
      240.0,
    );
    return Column(
      children: [
        SizedBox(
          width: posterWidth,
          child: AspectRatio(aspectRatio: 2 / 3, child: poster),
        ),
        const SizedBox(height: 24),
        _info(context, CrossAxisAlignment.center),
      ],
    );
  }

  Widget _info(BuildContext context, CrossAxisAlignment alignment) {
    final text = Theme.of(context).textTheme;
    final centered = alignment == CrossAxisAlignment.center;
    final wrapAlignment = centered ? WrapAlignment.center : WrapAlignment.start;
    final rating = detail?.imdbRating;
    final genres = detail?.genres ?? const <String>[];
    final meta = [
      detail?.year ?? movie.year,
      detail?.runtime,
      movie.typeLabel,
    ].whereType<String>().toList();

    return Column(
      crossAxisAlignment: alignment,
      children: [
        Semantics(
          header: true,
          child: Text(
            detail?.title ?? movie.title,
            textAlign: centered ? TextAlign.center : TextAlign.start,
            style: (wide ? text.displaySmall : text.headlineMedium)?.copyWith(
              fontWeight: FontWeight.w800,
              letterSpacing: -0.8,
              height: 1.08,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          alignment: wrapAlignment,
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 10,
          runSpacing: 8,
          children: [
            if (meta.isNotEmpty)
              Text(
                meta.join(' · '),
                style: text.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            if (detail?.rated case final rated?) _RatedLabel(rated),
          ],
        ),
        if (rating != null) ...[
          const SizedBox(height: 16),
          RatingBadge(rating: rating, votes: detail?.imdbVotes),
        ],
        if (genres.isNotEmpty) ...[
          const SizedBox(height: 16),
          Wrap(
            alignment: wrapAlignment,
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final genre in genres)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Text(genre, style: text.labelLarge),
                ),
            ],
          ),
        ],
        const SizedBox(height: 20),
        _FavoriteAction(isFavorite: isFavorite, onPressed: onFavoritePressed),
      ],
    );
  }
}

class _RatedLabel extends StatelessWidget {
  const _RatedLabel(this.rated);

  final String rated;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Rated $rated',
      excludeSemantics: true,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: AppColors.textSecondary),
        ),
        child: Text(
          rated,
          style: Theme.of(
            context,
          ).textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}

class _FavoriteAction extends StatelessWidget {
  const _FavoriteAction({required this.isFavorite, required this.onPressed});

  final bool isFavorite;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    if (isFavorite) {
      return OutlinedButton.icon(
        onPressed: onPressed,
        icon: const Icon(Icons.favorite_rounded, color: AppColors.accent),
        label: const Text('Saved to favorites'),
      );
    }
    return FilledButton.icon(
      onPressed: onPressed,
      icon: const Icon(Icons.favorite_border_rounded),
      label: const Text('Add to favorites'),
    );
  }
}
