import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/responsive.dart';
import '../../../shared/widgets/glass_search_field.dart';
import '../controllers/home_controller.dart';
import 'widgets/home_header.dart';
import 'widgets/home_results.dart';
import 'widgets/quick_searches.dart';
import 'widgets/search_header_delegate.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  /// Start fetching the next batch this far before the end of the list.
  static const _prefetchExtent = 900.0;

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final gutter = Responsive.gutter(media.size.width);

    return Scaffold(
      // The pinned search strip must stop below the status bar, not under it.
      body: SafeArea(
        bottom: false,
        child: NotificationListener<ScrollMetricsNotification>(
          onNotification: (n) => _maybeLoadMore(n.metrics),
          child: NotificationListener<ScrollUpdateNotification>(
            onNotification: (n) => _maybeLoadMore(n.metrics),
            child: RefreshIndicator(
              onRefresh: controller.refreshMovies,
              color: AppColors.accent,
              backgroundColor: AppColors.glass,
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                slivers: [
                  SliverToBoxAdapter(child: HomeHeader(gutter: gutter)),
                  SliverPersistentHeader(
                    pinned: true,
                    delegate: SearchHeaderDelegate(
                      gutter: gutter,
                      textScaler: media.textScaler,
                      child: Obx(
                        () => GlassSearchField(
                          controller: controller.searchController,
                          onChanged: controller.onQueryChanged,
                          onSubmitted: controller.submitSearch,
                          onClear: controller.clearSearch,
                          isSearching:
                              controller.status.value == HomeStatus.loading,
                        ),
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(child: QuickSearches(gutter: gutter)),
                  HomeResults(gutter: gutter),
                  SliverToBoxAdapter(
                    child: SizedBox(height: media.padding.bottom + 24),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  bool _maybeLoadMore(ScrollMetrics metrics) {
    if (metrics.axis == Axis.vertical &&
        metrics.extentAfter < _prefetchExtent) {
      controller.loadMore();
    }
    return false;
  }
}
