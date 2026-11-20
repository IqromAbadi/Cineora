import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/responsive.dart';
import '../../../data/providers/omdb_exception.dart';
import '../../../shared/widgets/error_state_widget.dart';
import '../../../shared/widgets/favorite_button.dart';
import '../controllers/detail_controller.dart';
import 'widgets/detail_backdrop.dart';
import 'widgets/detail_header.dart';
import 'widgets/detail_sections.dart';

class DetailView extends GetView<DetailController> {
  const DetailView({super.key});

  static const _maxBodyWidth = 980.0;

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final gutter = Responsive.gutter(media.size.width);
    final wide = Responsive.isWide(media.size.width);

    return Scaffold(
      body: Stack(
        children: [
          Obx(
            () => DetailBackdrop(
              posterUrl: controller.movie?.posterUrl,
              title: controller.movie?.title ?? '',
            ),
          ),
          CustomScrollView(
            slivers: [
              SliverPadding(
                padding: EdgeInsets.fromLTRB(
                  gutter,
                  media.padding.top + 72,
                  gutter,
                  media.padding.bottom + 40,
                ),
                sliver: SliverToBoxAdapter(
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(
                        maxWidth: _maxBodyWidth,
                      ),
                      child: Obx(() => _body(wide)),
                    ),
                  ),
                ),
              ),
            ],
          ),
          // Keeps scrolled text from running under the status bar and buttons.
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: media.padding.top + 76,
            child: const IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    stops: [0, 0.6, 1],
                    colors: [
                      Color(0xF2080F1E),
                      Color(0xB3080F1E),
                      Color(0x00080F1E),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: gutter - 4,
                  vertical: 8,
                ),
                child: Row(
                  children: [
                    IconButton(
                      tooltip: 'Back',
                      onPressed: Get.back,
                      style: IconButton.styleFrom(
                        minimumSize: const Size.square(44),
                        backgroundColor: AppColors.background.withValues(
                          alpha: 0.62,
                        ),
                      ),
                      icon: const Icon(Icons.arrow_back_rounded),
                    ),
                    const Spacer(),
                    Obx(() {
                      if (controller.movie == null) {
                        return const SizedBox.shrink();
                      }
                      return FavoriteButton(
                        isFavorite: controller.isFavorite,
                        onPressed: controller.toggleFavorite,
                      );
                    }),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _body(bool wide) {
    final movie = controller.movie;
    final status = controller.status.value;
    final detail = controller.detail.value;

    if (movie == null) {
      return const ErrorStateWidget(
        icon: Icons.movie_filter_outlined,
        title: 'This title could not be opened',
        message: 'Go back and pick a movie from the list.',
      );
    }

    final Widget content = switch (status) {
      DetailStatus.loading => const DetailSectionsSkeleton(),
      DetailStatus.error => ErrorStateWidget(
        title: controller.failure.value?.title ?? 'Details did not load',
        message:
            controller.failure.value?.message ??
            'Something went wrong. Try again.',
        onRetry: _canRetry(controller.failure.value) ? controller.load : null,
      ),
      DetailStatus.success when detail != null => DetailSections(
        detail: detail,
        wide: wide,
      ),
      DetailStatus.success => const SizedBox.shrink(),
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        DetailHeader(
          movie: movie,
          detail: detail,
          heroTag: controller.heroTag,
          isFavorite: controller.isFavorite,
          onFavoritePressed: controller.toggleFavorite,
          wide: wide,
        ),
        if (controller.isShowingSavedCopy.value) ...[
          const SizedBox(height: 24),
          const _SavedCopyNotice(),
        ],
        const SizedBox(height: 32),
        content,
      ],
    );
  }

  bool _canRetry(OmdbException? failure) {
    final kind = failure?.failure;
    return kind != OmdbFailure.missingApiKey &&
        kind != OmdbFailure.invalidApiKey &&
        kind != OmdbFailure.notFound;
  }
}

class _SavedCopyNotice extends StatelessWidget {
  const _SavedCopyNotice();

  @override
  Widget build(BuildContext context) {
    return Semantics(
      liveRegion: true,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.glass,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            const Icon(Icons.offline_pin_outlined, color: AppColors.accent),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'No connection. Showing the copy saved with your favorite.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
