import 'dart:math' as math;

import 'package:flutter/widgets.dart';

/// Centres a state message in the space left in the viewport, but lets it
/// grow and scroll when that space is smaller than the message, such as
/// when the keyboard is open.
class SliverFillMessage extends StatelessWidget {
  const SliverFillMessage({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return SliverLayoutBuilder(
      builder: (context, constraints) {
        final remaining = math.max(
          0.0,
          constraints.viewportMainAxisExtent - constraints.precedingScrollExtent,
        );
        return SliverToBoxAdapter(
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: remaining),
            child: Center(child: child),
          ),
        );
      },
    );
  }
}
