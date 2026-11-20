import 'package:get_storage/get_storage.dart';

class FavoriteStorageProvider {
  FavoriteStorageProvider(this._box);

  static const storageKey = 'favorite_movies';

  final GetStorage _box;

  List<Map<String, dynamic>> readAll() {
    final raw = _box.read<List<dynamic>>(storageKey);
    if (raw == null) return const [];
    return raw
        .whereType<Map>()
        .map((e) => Map<String, dynamic>.from(e))
        .toList(growable: false);
  }

  Future<void> writeAll(List<Map<String, dynamic>> records) =>
      _box.write(storageKey, records);
}
