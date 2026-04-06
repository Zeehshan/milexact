import 'package:get/get.dart';
import 'package:milexact/data/repositories/range_card_repository.dart';
import 'package:milexact/modules/range_card/controllers/range_card_list_controller.dart';

class RangeCardListBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<RangeCardListController>(
      () => RangeCardListController(Get.find<RangeCardRepository>()),
    );
  }
}
