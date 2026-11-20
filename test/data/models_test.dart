import 'package:cineora/app/data/models/favorite_movie.dart';
import 'package:cineora/app/data/models/movie_detail.dart';
import 'package:cineora/app/data/models/search_page.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('search page parses items and treats N/A poster as missing', () {
    final page = SearchPage.fromJson({
      'Search': [
        {
          'Title': 'Interstellar',
          'Year': '2014',
          'imdbID': 'tt0816692',
          'Type': 'movie',
          'Poster': 'https://example.com/p.jpg',
        },
        {
          'Title': 'Obscure',
          'Year': '1999',
          'imdbID': 'tt0000001',
          'Type': 'series',
          'Poster': 'N/A',
        },
      ],
      'totalResults': '42',
      'Response': 'True',
    });

    expect(page.totalResults, 42);
    expect(page.items, hasLength(2));
    expect(page.items.first.imdbId, 'tt0816692');
    expect(page.items.first.posterUrl, 'https://example.com/p.jpg');
    expect(page.items.last.posterUrl, isNull);
    expect(page.items.last.typeLabel, 'Series');
  });

  test('detail parses genres, rating and hides N/A fields', () {
    final detail = MovieDetail.fromJson({
      'Title': 'Interstellar',
      'imdbID': 'tt0816692',
      'Genre': 'Adventure, Drama, Sci-Fi',
      'imdbRating': '8.7',
      'Awards': 'N/A',
      'Runtime': '169 min',
    });

    expect(detail.genres, ['Adventure', 'Drama', 'Sci-Fi']);
    expect(detail.imdbRating, 8.7);
    expect(detail.awards, isNull);
    expect(detail.runtime, '169 min');
  });

  test('favorite with detail survives a JSON round trip', () {
    final original = FavoriteMovie(
      movie: MovieDetail.fromJson({
        'Title': 'Interstellar',
        'imdbID': 'tt0816692',
      }).toSummary(),
      savedAt: DateTime(2026, 11, 20, 9),
      detail: MovieDetail.fromJson({
        'Title': 'Interstellar',
        'imdbID': 'tt0816692',
        'Genre': 'Drama, Sci-Fi',
        'imdbRating': '8.7',
        'Plot': 'Wormhole.',
      }),
    );

    final copy = FavoriteMovie.fromJson(original.toJson());

    expect(copy.imdbId, 'tt0816692');
    expect(copy.savedAt, original.savedAt);
    expect(copy.detail?.genres, ['Drama', 'Sci-Fi']);
    expect(copy.detail?.imdbRating, 8.7);
    expect(copy.detail?.plot, 'Wormhole.');
  });
}
