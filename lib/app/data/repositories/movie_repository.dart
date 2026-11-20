import 'package:dio/dio.dart';

import '../models/movie_detail.dart';
import '../models/search_page.dart';
import '../providers/omdb_provider.dart';

class MovieRepository {
  MovieRepository(this._provider);

  /// OMDb stops serving search results after page 100.
  static const maxPage = 100;

  final OmdbProvider _provider;

  Future<SearchPage> searchMovies(
    String query, {
    int page = 1,
    CancelToken? cancelToken,
  }) {
    return _provider.search(
      query.trim(),
      page: page.clamp(1, maxPage),
      cancelToken: cancelToken,
    );
  }

  Future<MovieDetail> getMovieDetail(
    String imdbId, {
    CancelToken? cancelToken,
  }) {
    return _provider.detail(imdbId, cancelToken: cancelToken);
  }
}
