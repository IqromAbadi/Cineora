import 'dart:async';

import 'package:cineora/app/data/models/movie_detail.dart';
import 'package:cineora/app/data/models/movie_summary.dart';
import 'package:cineora/app/data/models/search_page.dart';
import 'package:cineora/app/data/providers/favorite_storage_provider.dart';
import 'package:cineora/app/data/repositories/movie_repository.dart';
import 'package:dio/dio.dart';

MovieSummary movie(String id, {String? title, String? year = '2001'}) =>
    MovieSummary(
      imdbId: id,
      title: title ?? 'Movie $id',
      year: year,
      type: 'movie',
    );

/// Ten results per page, with ids such as `ttbatman-0`.
SearchPage pageOf(String query, int page, {int total = 100}) => SearchPage(
      items: List.generate(
        SearchPage.pageSize,
        (i) => movie('tt$query-${(page - 1) * 10 + i}'),
      ),
      totalResults: total,
    );

MovieDetail detailOf(String id) => MovieDetail(
      imdbId: id,
      title: 'Detail $id',
      year: '2014',
      rated: 'PG-13',
      released: '07 Nov 2014',
      runtime: '169 min',
      genres: const ['Adventure', 'Drama', 'Sci-Fi'],
      director: 'Christopher Nolan',
      writer: 'Jonathan Nolan, Christopher Nolan',
      actors: 'Matthew McConaughey, Anne Hathaway, Jessica Chastain',
      plot: 'A team of explorers travel through a wormhole in space.',
      language: 'English',
      country: 'United States, United Kingdom',
      awards: 'Won 1 Oscar',
      imdbRating: 8.7,
      imdbVotes: '2,100,000',
      type: 'movie',
    );

class FakeMovieRepository implements MovieRepository {
  FakeMovieRepository({this.onSearch, this.onDetail});

  Future<SearchPage> Function(String query, int page)? onSearch;
  Future<MovieDetail> Function(String imdbId)? onDetail;

  final searchCalls = <(String, int)>[];
  final detailCalls = <String>[];

  @override
  Future<SearchPage> searchMovies(
    String query, {
    int page = 1,
    CancelToken? cancelToken,
  }) {
    searchCalls.add((query, page));
    final handler = onSearch ?? (q, p) async => pageOf(q, p);
    return handler(query, page);
  }

  @override
  Future<MovieDetail> getMovieDetail(String imdbId, {CancelToken? cancelToken}) {
    detailCalls.add(imdbId);
    final handler = onDetail ?? (id) async => detailOf(id);
    return handler(imdbId);
  }
}

/// Mirrors GetStorage by keeping records in a map that outlives repositories.
class InMemoryFavoriteStorage implements FavoriteStorageProvider {
  List<Map<String, dynamic>> records = [];
  int writes = 0;

  @override
  List<Map<String, dynamic>> readAll() => List.of(records);

  @override
  Future<void> writeAll(List<Map<String, dynamic>> values) async {
    writes++;
    records = List.of(values);
  }
}
