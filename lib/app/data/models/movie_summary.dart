import 'omdb_value.dart';

class MovieSummary {
  const MovieSummary({
    required this.imdbId,
    required this.title,
    this.year,
    this.type,
    this.posterUrl,
  });

  factory MovieSummary.fromJson(Map<String, dynamic> json) {
    return MovieSummary(
      imdbId: omdbValue(json['imdbID']) ?? '',
      title: omdbValue(json['Title']) ?? 'Untitled',
      year: omdbValue(json['Year']),
      type: omdbValue(json['Type']),
      posterUrl: omdbValue(json['Poster']),
    );
  }

  final String imdbId;
  final String title;
  final String? year;
  final String? type;
  final String? posterUrl;

  /// "movie" -> "Movie", "series" -> "Series".
  String? get typeLabel {
    final value = type;
    if (value == null || value.isEmpty) return null;
    return value[0].toUpperCase() + value.substring(1);
  }

  Map<String, dynamic> toJson() => {
        'imdbID': imdbId,
        'Title': title,
        'Year': year,
        'Type': type,
        'Poster': posterUrl,
      };
}
