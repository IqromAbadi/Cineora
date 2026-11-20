import 'package:get/get.dart';

import '../controllers/detail_arguments.dart';
import '../controllers/detail_controller.dart';

class DetailBinding extends Bindings {
  @override
  void dependencies() {
    final args = Get.arguments;
    Get.lazyPut<DetailController>(
      () => DetailController(
        Get.find(),
        Get.find(),
        arguments: args is DetailArguments ? args : null,
      ),
    );
  }
}
