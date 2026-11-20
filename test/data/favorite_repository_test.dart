import 'dart:io';

import 'package:cineora/app/data/providers/favorite_storage_provider.dart';
import 'package:cineora/app/data/repositories/favorite_repository.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_storage/get_storage.dart';

import '../helpers/fakes.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late InMemoryFavoriteStorage storage;
  late FavoriteRepository repo;

  setUp(() {
    storage = InMemoryFavoriteStorage();
    repo = FavoriteRepository(storage);
  });

  test('add and remove update state and storage', () async {
    await repo.add(movie('tt1'));
    expect(repo.isFavorite('tt1'), isTrue);
    expect(storage.records, hasLength(1));

    await repo.remove('tt1');
    expect(repo.isFavorite('tt1'), isFalse);
    expect(storage.records, isEmpty);
  });

  test('adding the same title twice keeps one record', () async {
    await repo.add(movie('tt1'));
    await repo.add(movie('tt1'));
    expect(repo.count, 1);
    expect(storage.records, hasLength(1));
  });

  test('toggle flips state and reports it', () async {
    expect(await repo.toggle(movie('tt1')), isTrue);
    expect(await repo.toggle(movie('tt1')), isFalse);
    expect(repo.count, 0);
  });

  test('favorites survive a restart (new repository, same storage)', () async {
    await repo.add(movie('tt1', title: 'First'));
    await repo.add(movie('tt2', title: 'Second'), detail: detailOf('tt2'));

    final restarted = FavoriteRepository(storage);

    expect(restarted.count, 2);
    expect(restarted.isFavorite('tt1'), isTrue);
    expect(restarted.savedDetail('tt2')?.director, 'Christopher Nolan');
  });

  test('newest favorite comes first', () async {
    var tick = 0;
    final clocked = FavoriteRepository(
      InMemoryFavoriteStorage(),
      clock: () => DateTime(2026, 1, 1).add(Duration(minutes: tick++)),
    );
    await clocked.add(movie('tt1'));
    await clocked.add(movie('tt2'));

    expect(clocked.favorites.map((f) => f.imdbId), ['tt2', 'tt1']);
  });

  test('updateDetail only touches saved titles', () async {
    await repo.updateDetail(detailOf('tt9'));
    expect(repo.isFavorite('tt9'), isFalse);

    await repo.add(movie('tt1'));
    await repo.updateDetail(detailOf('tt1'));
    expect(repo.savedDetail('tt1')?.plot, isNotNull);
  });

  test('corrupt records are skipped, valid ones load', () {
    storage.records = [
      {'movie': 'broken'},
      movieRecord('tt1'),
    ];
    final loaded = FavoriteRepository(storage);
    expect(loaded.count, 1);
  });

  test('GetStorage provider writes favorites to disk', () async {
    final dir = await Directory.systemTemp.createTemp('cineora_fav');
    addTearDown(() => dir.delete(recursive: true));
    const channel = MethodChannel('plugins.flutter.io/path_provider');
    final messenger =
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
    messenger.setMockMethodCallHandler(channel, (_) async => dir.path);
    addTearDown(() => messenger.setMockMethodCallHandler(channel, null));
    final box = GetStorage('favorites_test', dir.path);
    await box.initStorage;

    final provider = FavoriteStorageProvider(box);
    final persisted = FavoriteRepository(provider);
    await persisted.add(movie('tt0816692', title: 'Interstellar'));
    await box.save();

    final file = File('${dir.path}/favorites_test.gs');
    for (var i = 0; i < 20 && !_fileHas(file, 'tt0816692'); i++) {
      await Future<void>.delayed(const Duration(milliseconds: 50));
    }
    expect(file.readAsStringSync(), contains('tt0816692'));
    expect(FavoriteRepository(provider).isFavorite('tt0816692'), isTrue);
  });
}

bool _fileHas(File file, String text) =>
    file.existsSync() && file.readAsStringSync().contains(text);

Map<String, dynamic> movieRecord(String id) => {
      'movie': movie(id).toJson(),
      'savedAt': DateTime(2026).toIso8601String(),
    };
