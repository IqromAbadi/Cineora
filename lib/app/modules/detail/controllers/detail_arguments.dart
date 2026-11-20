import '../../../data/models/movie_summary.dart';

class DetailArguments {
  const DetailArguments({required this.movie, required this.heroTag});

  final MovieSummary movie;

  /// Unique per source list so the same title can appear in several places.
  final String heroTag;
}
