import 'package:get/get.dart';

import '../../../data/models/favorite_movie.dart';
import '../../../data/repositories/favorite_repository.dart';
import '../../../routes/app_pages.dart';
import '../../root/controllers/root_controller.dart';

class FavoritesController extends GetxController {
  FavoritesController(this._favorites);

  final FavoriteRepository _favorites;

  List<FavoriteMovie> get favorites => _favorites.favorites;
  int get count => _favorites.count;

  Future<FavoriteMovie?> remove(String imdbId) => _favorites.remove(imdbId);

  Future<void> undoRemove(FavoriteMovie favorite) =>
      _favorites.restore(favorite);

  void browseMovies() {
    if (Get.isRegistered<RootController>()) {
      Get.find<RootController>().selectTab(RootController.discoverTab);
    } else {
      Get.offAllNamed(Routes.ROOT);
    }
  }
}
