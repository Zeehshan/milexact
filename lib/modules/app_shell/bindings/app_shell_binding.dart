import 'package:get/get.dart';
import 'package:milexact/modules/app_shell/controllers/app_shell_controller.dart';
import 'package:milexact/modules/calculator/bindings/calculator_binding.dart';
import 'package:milexact/modules/dope/bindings/dope_profiles_binding.dart';
import 'package:milexact/modules/presets/bindings/preset_manager_binding.dart';
import 'package:milexact/modules/range_card/bindings/range_card_list_binding.dart';
import 'package:milexact/modules/visual_range_card/bindings/visual_range_card_binding.dart';

class AppShellBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<AppShellController>()) {
      Get.put(AppShellController());
    }

    CalculatorBinding().dependencies();
    RangeCardListBinding().dependencies();
    QuickPresetBinding().dependencies();
    DopeProfilesBinding().dependencies();
    VisualRangeCardBinding().dependencies();
  }
}
