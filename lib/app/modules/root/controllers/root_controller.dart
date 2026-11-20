import 'package:get/get.dart';

class RootController extends GetxController {
  static const discoverTab = 0;
  static const favoritesTab = 1;

  final tabIndex = discoverTab.obs;

  void selectTab(int index) => tabIndex.value = index;
}
