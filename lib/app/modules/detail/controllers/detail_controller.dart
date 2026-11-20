import 'package:dio/dio.dart';
import 'package:get/get.dart';

import '../../../data/models/movie_detail.dart';
import '../../../data/models/movie_summary.dart';
import '../../../data/providers/omdb_exception.dart';
import '../../../data/repositories/favorite_repository.dart';
import '../../../data/repositories/movie_repository.dart';
import 'detail_arguments.dart';

enum DetailStatus { loading, success, error }

class DetailController extends GetxController {
  DetailController(this._movies, this._favorites, {this.arguments});

  final MovieRepository _movies;
  final FavoriteRepository _favorites;
  final DetailArguments? arguments;

  final status = DetailStatus.loading.obs;
  final detail = Rxn<MovieDetail>();
  final failure = Rxn<OmdbException>();

  /// True when the network failed and the copy saved with the favorite is shown.
  final isShowingSavedCopy = false.obs;

  CancelToken? _cancelToken;

  MovieSummary? get movie => detail.value?.toSummary() ?? arguments?.movie;
  String get heroTag => arguments?.heroTag ?? 'detail-${movie?.imdbId}';
  bool get isFavorite {
    final id = movie?.imdbId;
    return id != null && _favorites.isFavorite(id);
  }

  @override
  void onInit() {
    super.onInit();
    load();
  }

  Future<void> load() async {
    final id = arguments?.movie.imdbId;
    if (id == null || id.isEmpty) {
      failure.value = const OmdbException(OmdbFailure.notFound);
      status.value = DetailStatus.error;
      return;
    }

    _cancelToken?.cancel();
    final token = _cancelToken = CancelToken();
    status.value = DetailStatus.loading;
    failure.value = null;

    try {
      final result = await _movies.getMovieDetail(id, cancelToken: token);
      detail.value = result;
      isShowingSavedCopy.value = false;
      status.value = DetailStatus.success;
      await _favorites.updateDetail(result);
    } on OmdbException catch (e) {
      if (e.isCancelled) return;
      final saved = _favorites.savedDetail(id);
      if (saved != null) {
        detail.value = saved;
        isShowingSavedCopy.value = true;
        status.value = DetailStatus.success;
      } else {
        failure.value = e;
        status.value = DetailStatus.error;
      }
    }
  }

  Future<void> toggleFavorite() async {
    final current = movie;
    if (current == null) return;
    await _favorites.toggle(current, detail: detail.value);
  }

  @override
  void onClose() {
    _cancelToken?.cancel();
    super.onClose();
  }
}
