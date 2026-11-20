import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';

class MoviePoster extends StatelessWidget {
  const MoviePoster({
    super.key,
    required this.url,
    required this.title,
    this.heroTag,
    this.borderRadius = const BorderRadius.all(
      Radius.circular(AppTheme.radiusMedium),
    ),
  });

  final String? url;
  final String title;
  final Object? heroTag;
  final BorderRadius borderRadius;

  @override
  Widget build(BuildContext context) {
    final poster = ClipRRect(
      borderRadius: borderRadius,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final src = url;
          if (src == null) return _PosterFallback(title: title);
          final dpr = MediaQuery.devicePixelRatioOf(context);
          final width = constraints.maxWidth;
          return CachedNetworkImage(
            imageUrl: src,
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
            memCacheWidth: width.isFinite ? (width * dpr).round() : null,
            fadeInDuration: const Duration(milliseconds: 220),
            placeholder: (_, _) => const ColoredBox(color: AppColors.surface),
            errorWidget: (_, _, _) => _PosterFallback(title: title),
          );
        },
      ),
    );

    final tag = heroTag;
    return ExcludeSemantics(
      child: tag == null ? poster : Hero(tag: tag, child: poster),
    );
  }
}

class _PosterFallback extends StatelessWidget {
  const _PosterFallback({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.surface,
      child: LayoutBuilder(
        builder: (context, constraints) {
          const icon = Icon(
            Icons.local_movies_outlined,
            color: AppColors.textSecondary,
            size: 32,
          );
          if (constraints.maxHeight < 120 || constraints.maxWidth < 80) {
            return const Center(child: icon);
          }
          return Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                icon,
                const SizedBox(height: 8),
                Flexible(
                  child: Text(
                    'No poster',
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.labelMedium,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
