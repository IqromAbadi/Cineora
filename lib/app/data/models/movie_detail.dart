import 'movie_summary.dart';
import 'omdb_value.dart';

class MovieDetail {
  const MovieDetail({
    required this.imdbId,
    required this.title,
    this.year,
    this.rated,
    this.released,
    this.runtime,
    this.genres = const [],
    this.director,
    this.writer,
    this.actors,
    this.plot,
    this.language,
    this.country,
    this.awards,
    this.posterUrl,
    this.imdbRating,
    this.imdbVotes,
    this.type,
  });

  factory MovieDetail.fromJson(Map<String, dynamic> json) {
    final genre = omdbValue(json['Genre']);
    return MovieDetail(
      imdbId: omdbValue(json['imdbID']) ?? '',
      title: omdbValue(json['Title']) ?? 'Untitled',
      year: omdbValue(json['Year']),
      rated: omdbValue(json['Rated']),
      released: omdbValue(json['Released']),
      runtime: omdbValue(json['Runtime']),
      genres: genre == null
          ? const []
          : genre
              .split(',')
              .map((g) => g.trim())
              .where((g) => g.isNotEmpty)
              .toList(growable: false),
      director: omdbValue(json['Director']),
      writer: omdbValue(json['Writer']),
      actors: omdbValue(json['Actors']),
      plot: omdbValue(json['Plot']),
      language: omdbValue(json['Language']),
      country: omdbValue(json['Country']),
      awards: omdbValue(json['Awards']),
      posterUrl: omdbValue(json['Poster']),
      imdbRating: double.tryParse(omdbValue(json['imdbRating']) ?? ''),
      imdbVotes: omdbValue(json['imdbVotes']),
      type: omdbValue(json['Type']),
    );
  }

  final String imdbId;
  final String title;
  final String? year;
  final String? rated;
  final String? released;
  final String? runtime;
  final List<String> genres;
  final String? director;
  final String? writer;
  final String? actors;
  final String? plot;
  final String? language;
  final String? country;
  final String? awards;
  final String? posterUrl;
  final double? imdbRating;
  final String? imdbVotes;
  final String? type;

  MovieSummary toSummary() => MovieSummary(
        imdbId: imdbId,
        title: title,
        year: year,
        type: type,
        posterUrl: posterUrl,
      );

  /// Uses OMDb keys so a stored copy parses through [MovieDetail.fromJson].
  Map<String, dynamic> toJson() => {
        'imdbID': imdbId,
        'Title': title,
        'Year': year,
        'Rated': rated,
        'Released': released,
        'Runtime': runtime,
        'Genre': genres.join(', '),
        'Director': director,
        'Writer': writer,
        'Actors': actors,
        'Plot': plot,
        'Language': language,
        'Country': country,
        'Awards': awards,
        'Poster': posterUrl,
        'imdbRating': imdbRating?.toString(),
        'imdbVotes': imdbVotes,
        'Type': type,
      };
}
