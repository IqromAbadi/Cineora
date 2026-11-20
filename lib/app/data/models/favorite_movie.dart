import 'movie_detail.dart';
import 'movie_summary.dart';

/// A saved title. [detail] is filled once the detail screen has loaded it,
/// so the favorite can be read offline later.
class FavoriteMovie {
  const FavoriteMovie({
    required this.movie,
    required this.savedAt,
    this.detail,
  });

  factory FavoriteMovie.fromJson(Map<String, dynamic> json) {
    final detail = json['detail'];
    return FavoriteMovie(
      movie: MovieSummary.fromJson(Map<String, dynamic>.from(json['movie'])),
      savedAt: DateTime.tryParse('${json['savedAt']}') ?? DateTime(1970),
      detail: detail is Map
          ? MovieDetail.fromJson(Map<String, dynamic>.from(detail))
          : null,
    );
  }

  final MovieSummary movie;
  final DateTime savedAt;
  final MovieDetail? detail;

  String get imdbId => movie.imdbId;

  FavoriteMovie withDetail(MovieDetail value) => FavoriteMovie(
        movie: value.toSummary(),
        savedAt: savedAt,
        detail: value,
      );

  Map<String, dynamic> toJson() => {
        'movie': movie.toJson(),
        'savedAt': savedAt.toIso8601String(),
        'detail': detail?.toJson(),
      };
}
