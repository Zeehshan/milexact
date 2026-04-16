import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:milexact/modules/app_shell/controllers/app_shell_controller.dart';
import 'package:milexact/modules/calculator/views/calculator_screen.dart';
import 'package:milexact/modules/dope/views/dope_profiles_screen.dart';
import 'package:milexact/modules/presets/views/preset_manager_screen.dart';
import 'package:milexact/modules/range_card/views/range_card_list_screen.dart';
import 'package:milexact/modules/visual_range_card/views/visual_range_card_screen.dart';
import 'package:milexact/shared/widgets/app_bottom_nav_bar.dart';

class AppShellScreen extends GetView<AppShellController> {
  const AppShellScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final pages = <Widget>[
      CalculatorScreen(showBottomNav: false),
      const RangeCardListScreen(showBottomNav: false),
      const QuickPresetScreen(showBottomNav: false),
      const DopeProfilesScreen(showBottomNav: false),
      const VisualRangeCardScreen(showBottomNav: false),
    ];

    return Obx(
      () => Scaffold(
        body: IndexedStack(index: controller.currentIndex, children: pages),
        bottomNavigationBar: AppBottomNavBar(
          currentRoute: controller.currentRoute.value,
          onRouteSelected: controller.selectRoute,
        ),
      ),
    );
  }
}
