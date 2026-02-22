import 'package:get/get.dart';

class MainController extends GetxController {
  var selectedIndex = 2.obs; // Default to 'Al Quran' tab (index 2)

  void changeTabIndex(int index) {
    selectedIndex.value = index;
  }
}
