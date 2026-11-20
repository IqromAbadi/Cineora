import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../data/models/movie_summary.dart';
import '../../../../shared/widgets/favorite_button.dart';
import '../../../../shared/widgets/movie_poster.dart';

/// The first result, staged like a marquee: the poster is reused as a dimmed
/// backdrop behind a sharp copy, so no extra artwork is needed.
class FeaturedMovieCard extends StatelessWidget {
  const FeaturedMovieCard({
    super.key,
    required this.movie,
    required this.heroTag,
    required this.isFavorite,
    required this.onOpen,
    required this.onFavoritePressed,
  });

  final MovieSummary movie;
  final String heroTag;
  final bool isFavorite;
  final VoidCallback onOpen;
  final VoidCallback onFavoritePressed;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final radius = BorderRadius.circular(AppTheme.radiusLarge);
    final meta = [movie.year, movie.typeLabel].whereType<String>().join(' · ');

    return LayoutBuilder(
      builder: (context, constraints) {
        final posterWidth = (constraints.maxWidth * 0.3).clamp(96.0, 168.0);
        final wide = constraints.maxWidth >= 600;
        return ClipRRect(
          borderRadius: radius,
          child: Stack(
            children: [
              Positioned.fill(
                child: MoviePoster(
                  url: movie.posterUrl,
                  title: movie.title,
                  borderRadius: BorderRadius.zero,
                ),
              ),
              const Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: [Color(0xE6080F1E), Color(0xF2101D32)],
                    ),
                  ),
                ),
              ),
              Material(
                color: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: radius,
                  side: const BorderSide(color: AppColors.border),
                ),
                child: InkWell(
                  onTap: onOpen,
                  child: Padding(
                    padding: EdgeInsets.all(wide ? 24 : 16),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: posterWidth,
                          child: AspectRatio(
                            aspectRatio: 2 / 3,
                            child: MoviePoster(
                              url: movie.posterUrl,
                              title: movie.title,
                              heroTag: heroTag,
                              borderRadius: BorderRadius.circular(
                                AppTheme.radiusMedium,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: wide ? 24 : 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Top result',
                                style: text.labelLarge?.copyWith(
                                  color: AppColors.accent,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                movie.title,
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                                style: (wide
                                        ? text.headlineMedium
                                        : text.titleLarge)
                                    ?.copyWith(
                                  fontWeight: FontWeight.w800,
                                  height: 1.15,
                                ),
                              ),
                              if (meta.isNotEmpty) ...[
                                const SizedBox(height: 6),
                                Text(
                                  meta,
                                  style: text.bodyMedium?.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                              const SizedBox(height: 16),
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                crossAxisAlignment: WrapCrossAlignment.center,
                                children: [
                                  FilledButton(
                                    onPressed: onOpen,
                                    child: const Text('See plot & cast'),
                                  ),
                                  FavoriteButton(
                                    isFavorite: isFavorite,
                                    onPressed: onFavoritePressed,
                                    style: FavoriteButtonStyle.outlined,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
