import 'dart:ui';

import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/movie_poster.dart';

/// The poster, heavily blurred, as a colour wash behind the header. It fades
/// into the page background before any body text begins.
class DetailBackdrop extends StatelessWidget {
  const DetailBackdrop({
    super.key,
    required this.posterUrl,
    required this.title,
  });

  final String? posterUrl;
  final String title;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final height = (size.height * 0.62).clamp(320.0, 620.0);
    return SizedBox(
      height: height,
      width: double.infinity,
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (posterUrl != null)
            // Clip so the blur cannot bleed past the gradient as a lighter band.
            ClipRect(
              child: ImageFiltered(
                imageFilter: ImageFilter.blur(sigmaX: 28, sigmaY: 28),
                child: Opacity(
                  opacity: 0.7,
                  child: MoviePoster(
                    url: posterUrl,
                    title: title,
                    borderRadius: BorderRadius.zero,
                  ),
                ),
              ),
            ),
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                stops: [0, 0.55, 1],
                colors: [
                  Color(0x66080F1E),
                  Color(0xCC080F1E),
                  AppColors.background,
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
