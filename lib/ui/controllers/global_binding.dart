
import 'package:get/get.dart';

import 'filterItemsController.dart';

class GlobalBindings extends Bindings{
  @override
  void dependencies() {
    Get.put(FilteredItemsController());
  }
}