import 'package:get/get.dart';

import '../../favorites/bindings/favorites_binding.dart';
import '../../home/bindings/home_binding.dart';
import '../controllers/root_controller.dart';

class RootBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<RootController>(() => RootController());
    HomeBinding().dependencies();
    FavoritesBinding().dependencies();
  }
}
