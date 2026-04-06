import 'package:get/get.dart';
import 'package:milexact/data/repositories/range_card_repository.dart';
import 'package:milexact/modules/range_card/controllers/range_card_edit_controller.dart';

class RangeCardEditBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<RangeCardEditController>(
      () => RangeCardEditController(Get.find<RangeCardRepository>()),
    );
  }
}
