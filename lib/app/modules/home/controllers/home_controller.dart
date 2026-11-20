import 'package:dio/dio.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

import '../../../data/models/movie_summary.dart';
import '../../../data/models/search_page.dart';
import '../../../data/providers/omdb_exception.dart';
import '../../../data/repositories/favorite_repository.dart';
import '../../../data/repositories/movie_repository.dart';

enum HomeStatus { loading, success, empty, error }

class HomeController extends GetxController {
  HomeController(
    this._movies,
    this._favorites, {
    this.debounceDuration = const Duration(milliseconds: 450),
  });

  /// OMDb has no "trending" endpoint, so the landing list is a real search.
  static const defaultQuery = 'star';
  static const quickSearches = ['Star', 'Batman', 'Love', 'Night', 'Dragon', 'Ocean'];
  static const minQueryLength = 2;

  /// Two OMDb pages of 10, so every batch shows 20 titles.
  static const pagesPerBatch = 2;

  final MovieRepository _movies;
  final FavoriteRepository _favorites;
  final Duration debounceDuration;

  final searchController = TextEditingController();
  final query = ''.obs;
  final activeQuery = defaultQuery.obs;
  final status = HomeStatus.loading.obs;
  final movies = <MovieSummary>[].obs;
  final totalResults = 0.obs;
  final failure = Rxn<OmdbException>();
  final isLoadingMore = false.obs;
  final loadMoreFailure = Rxn<OmdbException>();

  late final Worker _queryWorker;
  _SearchCursor _cursor = _SearchCursor(defaultQuery);
  CancelToken? _cancelToken;

  bool get isBrowsingDefault => query.value.trim().isEmpty;

  /// True while the opening list is shown and the user has not searched yet.
  bool get isShowingDefaultList =>
      isBrowsingDefault && activeQuery.value == defaultQuery;
  bool get isQueryTooShort {
    final length = query.value.trim().length;
    return length > 0 && length < minQueryLength;
  }

  bool get hasMore => _cursor.hasMore;
  bool isFavorite(String imdbId) => _favorites.isFavorite(imdbId);

  @override
  void onInit() {
    super.onInit();
    _queryWorker = debounce<String>(
      query,
      (_) => _onQueryDebounced(),
      time: debounceDuration,
    );
    _startSearch(defaultQuery);
  }

  void onQueryChanged(String text) => query.value = text;

  void clearSearch() {
    searchController.clear();
    query.value = '';
    _searchNow(defaultQuery);
  }

  void applyQuickSearch(String term) {
    searchController.value = TextEditingValue(
      text: term,
      selection: TextSelection.collapsed(offset: term.length),
    );
    query.value = term;
    _searchNow(term);
  }

  void submitSearch(String text) {
    final term = _resolveTerm(text);
    if (term != null) _searchNow(term);
  }

  Future<void> retry() => _startSearch(activeQuery.value);

  Future<void> refreshMovies() => _startSearch(activeQuery.value);

  Future<void> loadMore() async {
    if (status.value != HomeStatus.success ||
        isLoadingMore.value ||
        !_cursor.hasMore) {
      return;
    }
    final cursor = _cursor;
    final token = _cancelToken;
    isLoadingMore.value = true;
    loadMoreFailure.value = null;
    try {
      final batch = await _fetchBatch(cursor, token);
      if (!identical(cursor, _cursor)) return;
      movies.addAll(batch);
      totalResults.value = cursor.total ?? movies.length;
    } on OmdbException catch (e) {
      if (!identical(cursor, _cursor) || e.isCancelled) return;
      loadMoreFailure.value = e;
    } finally {
      if (identical(cursor, _cursor)) isLoadingMore.value = false;
    }
  }

  Future<void> toggleFavorite(MovieSummary movie) => _favorites.toggle(movie);

  void _onQueryDebounced() {
    final term = _resolveTerm(query.value);
    if (term == null) return;
    final unchanged = term.toLowerCase() == activeQuery.value.toLowerCase() &&
        status.value != HomeStatus.error;
    if (unchanged) return;
    _startSearch(term);
  }

  /// Search right away and make the pending debounce a no-op.
  void _searchNow(String term) {
    if (term.toLowerCase() == activeQuery.value.toLowerCase() &&
        status.value == HomeStatus.success) {
      return;
    }
    _startSearch(term);
  }

  String? _resolveTerm(String raw) {
    final text = raw.trim();
    if (text.isEmpty) return defaultQuery;
    if (text.length < minQueryLength) return null;
    return text;
  }

  Future<void> _startSearch(String term) async {
    _cancelToken?.cancel();
    final token = _cancelToken = CancelToken();
    final cursor = _cursor = _SearchCursor(term);

    activeQuery.value = term;
    status.value = HomeStatus.loading;
    failure.value = null;
    loadMoreFailure.value = null;
    isLoadingMore.value = false;
    movies.clear();
    totalResults.value = 0;

    try {
      final batch = await _fetchBatch(cursor, token);
      if (!identical(cursor, _cursor)) return;
      movies.assignAll(batch);
      totalResults.value = cursor.total ?? movies.length;
      status.value = batch.isEmpty ? HomeStatus.empty : HomeStatus.success;
    } on OmdbException catch (e) {
      if (!identical(cursor, _cursor) || e.isCancelled) return;
      if (e.failure == OmdbFailure.notFound) {
        status.value = HomeStatus.empty;
      } else {
        failure.value = e;
        status.value = HomeStatus.error;
      }
    }
  }

  Future<List<MovieSummary>> _fetchBatch(
    _SearchCursor cursor,
    CancelToken? token,
  ) async {
    final batch = <MovieSummary>[];
    for (var i = 0; i < pagesPerBatch && cursor.hasMore; i++) {
      final SearchPage page;
      try {
        page = await _movies.searchMovies(
          cursor.term,
          page: cursor.nextPage,
          cancelToken: token,
        );
      } on OmdbException {
        // Keep what this batch already has; the failed page is retried next time.
        if (batch.isEmpty) rethrow;
        break;
      }
      cursor.total = page.totalResults;
      cursor.nextPage++;
      for (final movie in page.items) {
        if (cursor.seenIds.add(movie.imdbId)) batch.add(movie);
      }
      if (page.items.isEmpty) cursor.exhausted = true;
    }
    return batch;
  }

  @override
  void onClose() {
    _queryWorker.dispose();
    _cancelToken?.cancel();
    searchController.dispose();
    super.onClose();
  }
}

/// Pagination state for one search term. A new search gets a new cursor, so
/// responses for an outdated term can be detected with [identical].
class _SearchCursor {
  _SearchCursor(this.term);

  final String term;
  final Set<String> seenIds = {};
  int nextPage = 1;
  int? total;
  bool exhausted = false;

  bool get hasMore {
    if (exhausted || nextPage > MovieRepository.maxPage) return false;
    final known = total;
    if (known == null) return true;
    return (nextPage - 1) * SearchPage.pageSize < known;
  }
}
