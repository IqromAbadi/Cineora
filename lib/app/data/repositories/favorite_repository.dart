import 'package:get/get.dart';

import '../models/favorite_movie.dart';
import '../models/movie_detail.dart';
import '../models/movie_summary.dart';
import '../providers/favorite_storage_provider.dart';

/// Single source of truth for favorites. Registered permanently so Home,
/// Detail and Favorites all observe the same reactive map.
class FavoriteRepository extends GetxService {
  FavoriteRepository(this._storage, {DateTime Function()? clock})
      : _clock = clock ?? DateTime.now {
    _load();
  }

  final FavoriteStorageProvider _storage;
  final DateTime Function() _clock;
  final RxMap<String, FavoriteMovie> _items = <String, FavoriteMovie>{}.obs;

  /// Newest first.
  List<FavoriteMovie> get favorites {
    final list = _items.values.toList()
      ..sort((a, b) => b.savedAt.compareTo(a.savedAt));
    return list;
  }

  int get count => _items.length;

  bool isFavorite(String imdbId) => _items[imdbId] != null;

  MovieDetail? savedDetail(String imdbId) => _items[imdbId]?.detail;

  Future<void> add(MovieSummary movie, {MovieDetail? detail}) {
    final existing = _items[movie.imdbId];
    _items[movie.imdbId] = FavoriteMovie(
      movie: detail?.toSummary() ?? movie,
      savedAt: existing?.savedAt ?? _clock(),
      detail: detail ?? existing?.detail,
    );
    return _persist();
  }

  Future<void> restore(FavoriteMovie favorite) {
    _items[favorite.imdbId] = favorite;
    return _persist();
  }

  Future<FavoriteMovie?> remove(String imdbId) async {
    final removed = _items.remove(imdbId);
    if (removed != null) await _persist();
    return removed;
  }

  /// Returns the new favorite state.
  Future<bool> toggle(MovieSummary movie, {MovieDetail? detail}) async {
    if (isFavorite(movie.imdbId)) {
      await remove(movie.imdbId);
      return false;
    }
    await add(movie, detail: detail);
    return true;
  }

  /// Refreshes the offline copy of a title that is already saved.
  Future<void> updateDetail(MovieDetail detail) async {
    final existing = _items[detail.imdbId];
    if (existing == null) return;
    _items[detail.imdbId] = existing.withDetail(detail);
    await _persist();
  }

  void _load() {
    final records = _storage.readAll();
    final loaded = <String, FavoriteMovie>{};
    for (final record in records) {
      try {
        final favorite = FavoriteMovie.fromJson(record);
        if (favorite.imdbId.isNotEmpty) loaded[favorite.imdbId] = favorite;
      } catch (_) {
        // A corrupt record is skipped rather than wiping every favorite.
      }
    }
    _items.assignAll(loaded);
  }

  Future<void> _persist() => _storage.writeAll(
        _items.values.map((f) => f.toJson()).toList(growable: false),
      );
}
