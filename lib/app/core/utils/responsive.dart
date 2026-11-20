import 'dart:math' as math;

abstract final class Responsive {
  static const maxContentWidth = 1180.0;
  static const minGutter = 16.0;

  /// Horizontal padding that keeps content centred within [maxContentWidth].
  static double gutter(double width) {
    final base = width >= 600 ? 24.0 : minGutter;
    return math.max(base, (width - maxContentWidth) / 2);
  }

  /// Poster columns for the given content width. Posters stay between
  /// roughly 140 and 200 logical pixels wide.
  static int gridColumns(double contentWidth) {
    if (contentWidth < 300) return 1;
    if (contentWidth < 520) return 2;
    if (contentWidth < 720) return 3;
    if (contentWidth < 940) return 4;
    if (contentWidth < 1100) return 5;
    return 6;
  }

  static bool isWide(double width) => width >= 720;
}
