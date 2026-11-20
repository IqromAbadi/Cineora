import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/theme/app_colors.dart';
import '../../controllers/home_controller.dart';

class QuickSearches extends GetView<HomeController> {
  const QuickSearches({super.key, required this.gutter});

  final double gutter;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Obx(() {
      if (controller.isQueryTooShort) {
        return Padding(
          padding: EdgeInsets.fromLTRB(gutter, 0, gutter, 12),
          child: Text(
            'Type at least ${HomeController.minQueryLength} letters to search.',
            style: text.labelMedium,
          ),
        );
      }
      // The opening list is not a user filter, so no chip is marked for it.
      final active = controller.isShowingDefaultList
          ? null
          : controller.activeQuery.value.toLowerCase();
      return SizedBox(
        height: 56,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: EdgeInsets.fromLTRB(gutter, 0, gutter, 8),
          itemCount: HomeController.quickSearches.length,
          separatorBuilder: (_, _) => const SizedBox(width: 8),
          itemBuilder: (context, index) {
            final term = HomeController.quickSearches[index];
            final selected = term.toLowerCase() == active;
            return ChoiceChip(
              label: Text(term),
              selected: selected,
              showCheckmark: false,
              materialTapTargetSize: MaterialTapTargetSize.padded,
              selectedColor: AppColors.primary,
              labelStyle: text.labelLarge?.copyWith(
                color: AppColors.textPrimary,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
              ),
              onSelected: (_) => controller.applyQuickSearch(term),
            );
          },
        ),
      );
    });
  }
}
