import 'package:get/get.dart';
import 'package:milexact/data/repositories/visual_range_card_repository.dart';
import 'package:milexact/modules/visual_range_card/controllers/visual_range_card_controller.dart';
import 'package:milexact/services/visual_range_card_service.dart';

class VisualRangeCardBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<VisualRangeCardController>(
      () => VisualRangeCardController(
        Get.find<VisualRangeCardRepository>(),
        Get.find<VisualRangeCardService>(),
      ),
    );
  }
}
