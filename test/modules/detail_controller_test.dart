import 'package:cineora/app/data/providers/omdb_exception.dart';
import 'package:cineora/app/data/repositories/favorite_repository.dart';
import 'package:cineora/app/modules/detail/controllers/detail_arguments.dart';
import 'package:cineora/app/modules/detail/controllers/detail_controller.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

import '../helpers/fakes.dart';

void main() {
  late FakeMovieRepository movies;
  late FavoriteRepository favorites;

  DetailController create(String id) => Get.put(
        DetailController(
          movies,
          favorites,
          arguments: DetailArguments(movie: movie(id), heroTag: 'home-$id'),
        ),
      );

  setUp(() {
    Get.testMode = true;
    movies = FakeMovieRepository();
    favorites = FavoriteRepository(InMemoryFavoriteStorage());
  });

  tearDown(Get.reset);

  test('loads detail for the IMDb id that was tapped', () async {
    final c = create('tt0816692');
    await pumpEventQueue();

    expect(movies.detailCalls, ['tt0816692']);
    expect(c.status.value, DetailStatus.success);
    expect(c.detail.value?.imdbId, 'tt0816692');
  });

  test('favorite toggled on detail stores the full detail', () async {
    final c = create('tt1');
    await pumpEventQueue();

    await c.toggleFavorite();

    expect(c.isFavorite, isTrue);
    expect(favorites.savedDetail('tt1')?.director, 'Christopher Nolan');
  });

  test('offline favorite falls back to the saved copy', () async {
    await favorites.add(movie('tt1'), detail: detailOf('tt1'));
    movies.onDetail =
        (_) async => throw const OmdbException(OmdbFailure.network);

    final c = create('tt1');
    await pumpEventQueue();

    expect(c.status.value, DetailStatus.success);
    expect(c.isShowingSavedCopy.value, isTrue);
    expect(c.detail.value?.plot, isNotNull);
  });

  test('offline title that is not saved shows the error state', () async {
    movies.onDetail =
        (_) async => throw const OmdbException(OmdbFailure.network);

    final c = create('tt1');
    await pumpEventQueue();

    expect(c.status.value, DetailStatus.error);
    expect(c.failure.value?.failure, OmdbFailure.network);
  });
}
