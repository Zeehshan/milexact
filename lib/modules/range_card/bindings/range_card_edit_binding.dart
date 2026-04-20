import 'package:get/get.dart';
import 'package:milexact/data/repositories/dope_profiles_repository.dart';
import 'package:milexact/data/repositories/range_card_repository.dart';
import 'package:milexact/modules/range_card/controllers/range_card_edit_controller.dart';
import 'package:milexact/services/unit_conversion_service.dart';

class RangeCardEditBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<RangeCardEditController>(
      () => RangeCardEditController(
        Get.find<RangeCardRepository>(),
        Get.find<DopeProfilesRepository>(),
        Get.find<UnitConversionService>(),
      ),
    );
  }
}
