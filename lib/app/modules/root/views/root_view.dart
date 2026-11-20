import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../../../shared/widgets/glass_bottom_navigation.dart';
import '../../favorites/views/favorites_view.dart';
import '../../home/views/home_view.dart';
import '../controllers/root_controller.dart';

/// Hosts Discover and Favorites in an IndexedStack so switching tabs keeps
/// the search query, results and scroll position.
class RootView extends GetView<RootController> {
  const RootView({super.key});

  static const _items = [
    GlassNavItem(
      icon: Icons.local_movies_outlined,
      selectedIcon: Icons.local_movies_rounded,
      label: 'Discover',
    ),
    GlassNavItem(
      icon: Icons.favorite_border_rounded,
      selectedIcon: Icons.favorite_rounded,
      label: 'Favorites',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final index = controller.tabIndex.value;
      return PopScope(
        canPop: index == RootController.discoverTab,
        onPopInvokedWithResult: (didPop, _) {
          if (!didPop) controller.selectTab(RootController.discoverTab);
        },
        child: Scaffold(
          extendBody: true,
          body: IndexedStack(
            index: index,
            children: const [HomeView(), FavoritesView()],
          ),
          bottomNavigationBar: GlassBottomNavigation(
            items: _items,
            currentIndex: index,
            onSelected: (i) {
              FocusManager.instance.primaryFocus?.unfocus();
              controller.selectTab(i);
            },
          ),
        ),
      );
    });
  }
}
