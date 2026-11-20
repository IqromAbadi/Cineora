import 'package:flutter/material.dart';

import '../../core/utils/responsive.dart';

/// Poster grid whose column count follows the available width.
class SliverMovieGrid extends StatelessWidget {
  const SliverMovieGrid({
    super.key,
    required this.itemCount,
    required this.itemBuilder,
  });

  final int itemCount;
  final IndexedWidgetBuilder itemBuilder;

  @override
  Widget build(BuildContext context) {
    return SliverLayoutBuilder(
      builder: (context, constraints) {
        final columns = Responsive.gridColumns(constraints.crossAxisExtent);
        return SliverGrid(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            mainAxisSpacing: 16,
            crossAxisSpacing: 12,
            childAspectRatio: 2 / 3,
          ),
          delegate: SliverChildBuilderDelegate(
            itemBuilder,
            childCount: itemCount,
          ),
        );
      },
    );
  }
}
