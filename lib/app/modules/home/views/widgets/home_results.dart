import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../data/models/movie_summary.dart';
import '../../../../data/providers/omdb_exception.dart';
import '../../../../routes/app_pages.dart';
import '../../../../shared/widgets/empty_state_widget.dart';
import '../../../../shared/widgets/error_state_widget.dart';
import '../../../../shared/widgets/loading_shimmer.dart';
import '../../../../shared/widgets/movie_card.dart';
import '../../../../shared/widgets/sliver_fill_message.dart';
import '../../../../shared/widgets/sliver_movie_grid.dart';
import '../../../detail/controllers/detail_arguments.dart';
import '../../controllers/home_controller.dart';
import 'featured_movie_card.dart';

/// Slivers for the result area, switched on [HomeController.status].
class HomeResults extends GetView<HomeController> {
  const HomeResults({super.key, required this.gutter});

  final double gutter;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final slivers = switch (controller.status.value) {
        HomeStatus.loading => _loading(),
        HomeStatus.empty => [_empty()],
        HomeStatus.error => [_error(controller.failure.value)],
        HomeStatus.success => _results(context, controller.movies.toList()),
      };
      return SliverMainAxisGroup(slivers: slivers);
    });
  }

  List<Widget> _loading() => [
    SliverPadding(
      padding: EdgeInsets.fromLTRB(gutter, 8, gutter, 24),
      sliver: const SliverToBoxAdapter(
        child: LoadingShimmer(child: SkeletonBox(height: 196, radius: 24)),
      ),
    ),
    SliverPadding(
      padding: EdgeInsets.symmetric(horizontal: gutter),
      sliver: SliverMovieGrid(
        itemCount: 8,
        itemBuilder: (_, _) =>
            const LoadingShimmer(child: SkeletonBox(radius: 16)),
      ),
    ),
  ];

  Widget _empty() {
    final term = controller.activeQuery.value;
    return SliverFillMessage(
      child: EmptyStateWidget(
        icon: Icons.search_off_rounded,
        title: 'No titles match “$term”',
        message: 'Check the spelling or try the original release title.',
        actionLabel: controller.isBrowsingDefault ? null : 'Clear search',
        onAction: controller.isBrowsingDefault ? null : controller.clearSearch,
      ),
    );
  }

  Widget _error(OmdbException? failure) {
    final error = failure ?? const OmdbException(OmdbFailure.server);
    final needsRebuild =
        error.failure == OmdbFailure.missingApiKey ||
        error.failure == OmdbFailure.invalidApiKey;
    return SliverFillMessage(
      child: ErrorStateWidget(
        icon: needsRebuild
            ? Icons.vpn_key_outlined
            : error.failure == OmdbFailure.tooManyResults
            ? Icons.manage_search_rounded
            : Icons.cloud_off_rounded,
        title: error.title,
        message: error.message,
        onRetry: needsRebuild || error.failure == OmdbFailure.tooManyResults
            ? null
            : controller.retry,
      ),
    );
  }

  List<Widget> _results(BuildContext context, List<MovieSummary> movies) {
    final featured = movies.first;
    final rest = movies.sublist(1);
    final text = Theme.of(context).textTheme;
    final total = controller.totalResults.value;

    return [
      SliverPadding(
        padding: EdgeInsets.fromLTRB(gutter, 8, gutter, 28),
        sliver: SliverToBoxAdapter(
          child: Obx(
            () => FeaturedMovieCard(
              movie: featured,
              heroTag: 'featured-${featured.imdbId}',
              isFavorite: controller.isFavorite(featured.imdbId),
              onOpen: () =>
                  _openDetail(featured, 'featured-${featured.imdbId}'),
              onFavoritePressed: () => controller.toggleFavorite(featured),
            ),
          ),
        ),
      ),
      SliverPadding(
        padding: EdgeInsets.fromLTRB(gutter, 0, gutter, 14),
        sliver: SliverToBoxAdapter(
          child: Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.end,
            spacing: 12,
            runSpacing: 4,
            children: [
              Semantics(
                header: true,
                child: Text(
                  controller.isShowingDefaultList
                      ? 'Start browsing'
                      : 'Results for “${controller.activeQuery.value}”',
                  style: text.titleLarge,
                ),
              ),
              Text(
                'Showing ${movies.length} of ${_formatCount(total)} titles',
                style: text.labelMedium,
              ),
            ],
          ),
        ),
      ),
      if (rest.isNotEmpty)
        SliverPadding(
          padding: EdgeInsets.symmetric(horizontal: gutter),
          sliver: SliverMovieGrid(
            itemCount: rest.length,
            itemBuilder: (context, index) {
              final movie = rest[index];
              final tag = 'home-${movie.imdbId}';
              return Obx(
                () => MovieCard(
                  movie: movie,
                  heroTag: tag,
                  isFavorite: controller.isFavorite(movie.imdbId),
                  onTap: () => _openDetail(movie, tag),
                  onFavoritePressed: () => controller.toggleFavorite(movie),
                ),
              );
            },
          ),
        ),
      SliverPadding(
        padding: EdgeInsets.fromLTRB(gutter, 20, gutter, 0),
        sliver: SliverToBoxAdapter(child: _PaginationFooter(controller)),
      ),
    ];
  }

  void _openDetail(MovieSummary movie, String heroTag) {
    FocusManager.instance.primaryFocus?.unfocus();
    Get.toNamed(
      Routes.DETAIL,
      arguments: DetailArguments(movie: movie, heroTag: heroTag),
    );
  }

  static String _formatCount(int value) {
    final digits = value.toString();
    final buffer = StringBuffer();
    for (var i = 0; i < digits.length; i++) {
      if (i > 0 && (digits.length - i) % 3 == 0) buffer.write(',');
      buffer.write(digits[i]);
    }
    return buffer.toString();
  }
}

class _PaginationFooter extends StatelessWidget {
  const _PaginationFooter(this.controller);

  final HomeController controller;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme.labelMedium;
    return Obx(() {
      final Widget child;
      if (controller.isLoadingMore.value) {
        child = const Padding(
          padding: EdgeInsets.all(12),
          child: SizedBox.square(
            dimension: 24,
            child: CircularProgressIndicator(strokeWidth: 2.5),
          ),
        );
      } else if (controller.loadMoreFailure.value != null) {
        child = Wrap(
          alignment: WrapAlignment.center,
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 4,
          children: [
            Text('More titles did not load.', style: text),
            TextButton(
              onPressed: controller.loadMore,
              child: const Text('Retry'),
            ),
          ],
        );
      } else if (!controller.hasMore) {
        child = Padding(
          padding: const EdgeInsets.all(12),
          child: Text(
            'That is every match OMDb has for “${controller.activeQuery.value}”.',
            textAlign: TextAlign.center,
            style: text?.copyWith(color: AppColors.textSecondary),
          ),
        );
      } else {
        child = const SizedBox(height: 48);
      }
      return Center(child: child);
    });
  }
}
