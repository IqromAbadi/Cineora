import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/movie_summary.dart';
import 'favorite_button.dart';
import 'movie_poster.dart';

/// Poster-first card: the artwork fills the tile and the title sits on a
/// scrim at the bottom so posters stay the loudest thing on screen.
class MovieCard extends StatelessWidget {
  const MovieCard({
    super.key,
    required this.movie,
    required this.heroTag,
    required this.isFavorite,
    required this.onTap,
    required this.onFavoritePressed,
  });

  final MovieSummary movie;
  final String heroTag;
  final bool isFavorite;
  final VoidCallback onTap;
  final VoidCallback onFavoritePressed;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    const radius = BorderRadius.all(Radius.circular(AppTheme.radiusMedium));
    final meta = [movie.year, movie.typeLabel].whereType<String>().join(' · ');

    return Stack(
      fit: StackFit.expand,
      children: [
        MoviePoster(url: movie.posterUrl, title: movie.title, heroTag: heroTag),
        const IgnorePointer(
          child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: radius,
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                stops: [0.35, 0.68, 1],
                colors: [
                  Color(0x00080F1E),
                  Color(0xD9080F1E),
                  Color(0xF5080F1E),
                ],
              ),
            ),
          ),
        ),
        Positioned(
          left: 12,
          right: 12,
          bottom: 12,
          child: IgnorePointer(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  movie.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: text.titleSmall?.copyWith(height: 1.2),
                ),
                if (meta.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    meta,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: text.labelMedium,
                  ),
                ],
              ],
            ),
          ),
        ),
        Positioned.fill(
          child: Semantics(
            button: true,
            label: [movie.title, meta, 'Open details']
                .where((s) => s.isNotEmpty)
                .join(', '),
            excludeSemantics: true,
            child: Material(
              color: Colors.transparent,
              shape: const RoundedRectangleBorder(
                borderRadius: radius,
                side: BorderSide(color: AppColors.border),
              ),
              clipBehavior: Clip.antiAlias,
              child: InkWell(onTap: onTap),
            ),
          ),
        ),
        Positioned(
          top: 6,
          right: 6,
          child: FavoriteButton(
            isFavorite: isFavorite,
            onPressed: onFavoritePressed,
          ),
        ),
      ],
    );
  }
}
