import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import '../data/providers/favorite_storage_provider.dart';
import '../data/providers/omdb_provider.dart';
import '../data/repositories/favorite_repository.dart';
import '../data/repositories/movie_repository.dart';

class InitialBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<OmdbProvider>(() => OmdbProvider(), fenix: true);
    Get.lazyPut<MovieRepository>(
      () => MovieRepository(Get.find()),
      fenix: true,
    );
    Get.put<FavoriteRepository>(
      FavoriteRepository(FavoriteStorageProvider(GetStorage())),
      permanent: true,
    );
  }
}
