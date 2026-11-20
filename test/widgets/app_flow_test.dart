import 'package:cineora/app/core/theme/app_theme.dart';
import 'package:cineora/app/data/models/search_page.dart';
import 'package:cineora/app/data/providers/omdb_exception.dart';
import 'package:cineora/app/data/repositories/favorite_repository.dart';
import 'package:cineora/app/data/repositories/movie_repository.dart';
import 'package:cineora/app/routes/app_pages.dart';
import 'package:cineora/app/shared/widgets/movie_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

import '../helpers/fakes.dart';

const _sizes = <String, Size>{
  'small phone': Size(320, 568),
  'standard phone': Size(390, 844),
  'large phone': Size(430, 932),
  'tablet portrait': Size(834, 1194),
  'tablet landscape': Size(1366, 1024),
};

late FakeMovieRepository _movies;
late FavoriteRepository _favorites;

Future<void> _pumpApp(
  WidgetTester tester, {
  required Size size,
  double textScale = 1,
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  tester.platformDispatcher.textScaleFactorTestValue = textScale;
  addTearDown(tester.view.reset);
  addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

  await tester.pumpWidget(
    GetMaterialApp(
      theme: AppTheme.dark,
      initialBinding: BindingsBuilder(() {
        Get.put<MovieRepository>(_movies);
        Get.put<FavoriteRepository>(_favorites, permanent: true);
      }),
      initialRoute: AppPages.INITIAL,
      getPages: AppPages.routes,
    ),
  );
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 50));
}

Future<void> _scrollTo(WidgetTester tester, Finder finder) async {
  await tester.scrollUntilVisible(
    finder,
    300,
    scrollable: find.byType(Scrollable).hitTestable().first,
  );
  await tester.pump();
}

void main() {
  setUp(() {
    Get.testMode = true;
    _movies = FakeMovieRepository();
    _favorites = FavoriteRepository(InMemoryFavoriteStorage());
  });

  tearDown(Get.reset);

  for (final entry in _sizes.entries) {
    testWidgets('home renders results without overflow on ${entry.key}',
        (tester) async {
      await _pumpApp(tester, size: entry.value);

      expect(find.text('Top result'), findsOneWidget);
      await _scrollTo(tester, find.text('Start browsing'));
      expect(find.text('Start browsing'), findsOneWidget);
      expect(find.byType(MovieCard), findsWidgets);
      expect(tester.takeException(), isNull);
    });

    testWidgets('detail renders without overflow on ${entry.key}',
        (tester) async {
      await _pumpApp(tester, size: entry.value);

      await _scrollTo(tester, find.text('See plot & cast'));
      await tester.tap(find.text('See plot & cast'));
      await tester.pumpAndSettle();
      await _scrollTo(tester, find.text('Christopher Nolan'));

      expect(find.text('Synopsis'), findsOneWidget);
      expect(find.text('Christopher Nolan'), findsOneWidget);
      expect(_movies.detailCalls.single, 'tt${'star'}-0');
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('home holds up at 1.6x text on a small phone', (tester) async {
    await _pumpApp(tester, size: const Size(320, 568), textScale: 1.6);
    await _scrollTo(tester, find.text('Top result'));
    await _scrollTo(tester, find.text('Start browsing'));
    expect(tester.takeException(), isNull);
  });

  testWidgets('favorite set on Home shows on Favorites and detail',
      (tester) async {
    await _pumpApp(tester, size: const Size(390, 844));

    await tester.tap(find.byTooltip('Add to favorites').first);
    await tester.pump();
    expect(_favorites.count, 1);

    await tester.tap(find.text('Favorites'));
    await tester.pumpAndSettle();
    expect(find.text('1 saved title, available offline'), findsOneWidget);

    await tester.tap(find.byType(MovieCard).hitTestable().first);
    await tester.pumpAndSettle();
    expect(find.text('Saved to favorites'), findsOneWidget);

    await tester.tap(find.text('Saved to favorites'));
    await tester.pump();
    expect(_favorites.count, 0);
    expect(find.text('Add to favorites'), findsOneWidget);
  });

  testWidgets('favorites empty state offers a way back to Discover',
      (tester) async {
    await _pumpApp(tester, size: const Size(390, 844));

    await tester.tap(find.text('Favorites'));
    await tester.pumpAndSettle();
    expect(find.text('Nothing saved yet'), findsOneWidget);

    await tester.tap(find.text('Browse movies'));
    await tester.pumpAndSettle();
    expect(find.text('Top result').hitTestable(), findsOneWidget);
  });

  testWidgets('removing a favorite can be undone', (tester) async {
    await _favorites.add(movie('tt1', title: 'Kept Film'));
    await _pumpApp(tester, size: const Size(390, 844));

    await tester.tap(find.text('Favorites'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Remove from favorites').hitTestable());
    await tester.pumpAndSettle();
    expect(_favorites.count, 0);

    await tester.tap(find.text('Undo'));
    await tester.pumpAndSettle();
    expect(_favorites.isFavorite('tt1'), isTrue);
  });

  testWidgets('network error renders the error state with retry',
      (tester) async {
    _movies.onSearch =
        (q, p) async => throw const OmdbException(OmdbFailure.network);
    await _pumpApp(tester, size: const Size(390, 844));

    expect(find.text('You appear to be offline'), findsOneWidget);

    _movies.onSearch = (q, p) async => pageOf(q, p);
    await tester.tap(find.text('Try again'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));
    expect(find.text('Top result'), findsOneWidget);
  });

  testWidgets('search with no matches renders the empty state',
      (tester) async {
    _movies.onSearch = (q, p) async => q == 'qqzzxx'
        ? throw const OmdbException(OmdbFailure.notFound)
        : pageOf(q, p);
    await _pumpApp(tester, size: const Size(390, 844));

    await tester.enterText(find.byType(TextField), 'qqzzxx');
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pump();

    expect(find.text('No titles match “qqzzxx”'), findsOneWidget);
    await tester.tap(find.text('Clear search'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.text('Top result'), findsOneWidget);
  });

  for (final size in const [Size(320, 568), Size(360, 640), Size(390, 844)]) {
    testWidgets(
        'state messages do not overflow with the keyboard open on $size',
        (tester) async {
      _movies.onSearch = (q, p) async => q == 'ab'
          ? throw const OmdbException(OmdbFailure.tooManyResults)
          : pageOf(q, p);
      await _pumpApp(tester, size: size);

      await tester.enterText(find.byType(TextField), 'ab');
      tester.view.viewInsets = const FakeViewPadding(bottom: 336);
      addTearDown(tester.view.resetViewInsets);
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pump();

      expect(tester.takeException(), isNull);
      await _scrollTo(tester, find.text('Too many matches'));
      expect(find.text('Too many matches'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('no search filter is active when the app opens',
      (tester) async {
    await _pumpApp(tester, size: const Size(390, 844));
    await _scrollTo(tester, find.text('Start browsing'));
    await tester.drag(
        find.byType(Scrollable).hitTestable().first, const Offset(0, 2000));
    await tester.pump();

    final chips = tester.widgetList<ChoiceChip>(find.byType(ChoiceChip));
    expect(chips, isNotEmpty);
    expect(chips.where((c) => c.selected), isEmpty);

    await tester.tap(find.widgetWithText(ChoiceChip, 'Batman'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));
    final selected = tester
        .widgetList<ChoiceChip>(find.byType(ChoiceChip))
        .where((c) => c.selected);
    expect(selected, hasLength(1));
    await _scrollTo(tester, find.textContaining('Results for “Batman”'));
    expect(find.textContaining('Results for “Batman”'), findsOneWidget);
    await tester.pump(const Duration(milliseconds: 500));
  });

  testWidgets('a short result list reports its end', (tester) async {
    _movies.onSearch = (q, p) async => SearchPage(
          items: [movie('tt1'), movie('tt2'), movie('tt3')],
          totalResults: 3,
        );
    await _pumpApp(tester, size: const Size(390, 844));

    await _scrollTo(tester, find.textContaining('That is every match'));
    expect(find.textContaining('That is every match'), findsOneWidget);
  });
}
