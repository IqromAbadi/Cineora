import 'dart:async';

import 'package:cineora/app/data/models/search_page.dart';
import 'package:cineora/app/data/providers/omdb_exception.dart';
import 'package:cineora/app/data/repositories/favorite_repository.dart';
import 'package:cineora/app/modules/home/controllers/home_controller.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

import '../helpers/fakes.dart';

const _debounce = Duration(milliseconds: 40);

Future<void> _settle([Duration extra = Duration.zero]) =>
    Future<void>.delayed(_debounce * 2 + extra);

void main() {
  late FakeMovieRepository movies;
  late FavoriteRepository favorites;

  HomeController create() => Get.put(
        HomeController(movies, favorites, debounceDuration: _debounce),
      );

  setUp(() {
    Get.testMode = true;
    movies = FakeMovieRepository();
    favorites = FavoriteRepository(InMemoryFavoriteStorage());
  });

  tearDown(Get.reset);

  test('first load shows 20 titles from two OMDb pages', () async {
    final c = create();
    await _settle();

    expect(c.status.value, HomeStatus.success);
    expect(c.movies, hasLength(20));
    expect(movies.searchCalls, [
      (HomeController.defaultQuery, 1),
      (HomeController.defaultQuery, 2),
    ]);
    expect(c.hasMore, isTrue);
  });

  test('loadMore appends the next 20 and skips duplicate ids', () async {
    movies.onSearch = (q, p) async {
      final page = pageOf(q, p);
      if (p == 3) {
        // OMDb occasionally repeats a title across pages.
        return SearchPage(
          items: [movie('tt$q-0'), ...page.items.skip(1)],
          totalResults: page.totalResults,
        );
      }
      return page;
    };
    final c = create();
    await _settle();

    await c.loadMore();

    expect(c.movies, hasLength(39));
    expect(c.movies.map((m) => m.imdbId).toSet(), hasLength(39));
    expect(movies.searchCalls.map((e) => e.$2), [1, 2, 3, 4]);
  });

  test('pagination stops at totalResults', () async {
    movies.onSearch = (q, p) async => pageOf(q, p, total: 15);
    final c = create();
    await _settle();

    expect(c.hasMore, isFalse);
    await c.loadMore();
    expect(movies.searchCalls, hasLength(2));
  });

  test('typing is debounced into a single request', () async {
    final c = create();
    await _settle();
    movies.searchCalls.clear();

    for (final text in ['b', 'ba', 'bat', 'batm', 'batman']) {
      c.onQueryChanged(text);
      await Future<void>.delayed(const Duration(milliseconds: 10));
    }
    expect(movies.searchCalls, isEmpty);

    await _settle();
    expect(movies.searchCalls.map((e) => e.$1).toSet(), {'batman'});
    expect(c.activeQuery.value, 'batman');
  });

  test('a single letter does not hit the API', () async {
    final c = create();
    await _settle();
    movies.searchCalls.clear();

    c.onQueryChanged('b');
    await _settle();

    expect(movies.searchCalls, isEmpty);
    expect(c.isQueryTooShort, isTrue);
  });

  test('an outdated response never replaces newer results', () async {
    final slow = Completer<SearchPage>();
    movies.onSearch = (q, p) =>
        q == 'alien' && p == 1 ? slow.future : Future.value(pageOf(q, p));
    final c = create();
    await _settle();

    c.onQueryChanged('alien');
    await _settle();
    c.onQueryChanged('batman');
    await _settle();

    slow.complete(pageOf('alien', 1));
    await _settle();

    expect(c.activeQuery.value, 'batman');
    expect(c.movies.every((m) => m.imdbId.startsWith('ttbatman')), isTrue);
  });

  test('clearing search goes back to the default list', () async {
    final c = create();
    await _settle();
    c.applyQuickSearch('Batman');
    await _settle();
    expect(c.activeQuery.value, 'Batman');

    c.clearSearch();
    await _settle();

    expect(c.activeQuery.value, HomeController.defaultQuery);
    expect(c.searchController.text, isEmpty);
  });

  test('not found shows the empty state', () async {
    movies.onSearch =
        (q, p) async => throw const OmdbException(OmdbFailure.notFound);
    final c = create();
    await _settle();

    expect(c.status.value, HomeStatus.empty);
  });

  test('network failure shows the error state and retry recovers', () async {
    var fail = true;
    movies.onSearch = (q, p) async {
      if (fail) throw const OmdbException(OmdbFailure.network);
      return pageOf(q, p);
    };
    final c = create();
    await _settle();
    expect(c.status.value, HomeStatus.error);
    expect(c.failure.value?.failure, OmdbFailure.network);

    fail = false;
    await c.retry();
    expect(c.status.value, HomeStatus.success);
  });

  test('favorite toggled on Home is visible through the shared repository',
      () async {
    final c = create();
    await _settle();
    final first = c.movies.first;

    await c.toggleFavorite(first);

    expect(c.isFavorite(first.imdbId), isTrue);
    expect(favorites.isFavorite(first.imdbId), isTrue);
  });
}
