import 'package:get/get.dart';
import 'package:milexact/app/routes/app_routes.dart';
import 'package:milexact/modules/calculator/bindings/calculator_binding.dart';
import 'package:milexact/modules/calculator/views/calculator_screen.dart';
import 'package:milexact/modules/presets/bindings/preset_manager_binding.dart';
import 'package:milexact/modules/presets/views/preset_manager_screen.dart';
import 'package:milexact/modules/range_card/bindings/range_card_edit_binding.dart';
import 'package:milexact/modules/range_card/bindings/range_card_list_binding.dart';
import 'package:milexact/modules/range_card/views/range_card_edit_screen.dart';
import 'package:milexact/modules/range_card/views/range_card_list_screen.dart';
import 'package:milexact/modules/settings/bindings/settings_binding.dart';
import 'package:milexact/modules/settings/views/settings_screen.dart';

class AppPages {
  static final pages = <GetPage<dynamic>>[
    GetPage(
      name: AppRoutes.calculator,
      page: CalculatorScreen.new,
      binding: CalculatorBinding(),
    ),
    GetPage(
      name: AppRoutes.rangeCardList,
      page: RangeCardListScreen.new,
      binding: RangeCardListBinding(),
    ),
    GetPage(
      name: AppRoutes.rangeCardEdit,
      page: RangeCardEditScreen.new,
      binding: RangeCardEditBinding(),
    ),
    GetPage(
      name: AppRoutes.presetManager,
      page: PresetManagerScreen.new,
      binding: PresetManagerBinding(),
    ),
    GetPage(
      name: AppRoutes.settings,
      page: SettingsScreen.new,
      binding: SettingsBinding(),
    ),
  ];
}
