import 'package:get/get.dart';
import 'package:milexact/app/routes/app_routes.dart';

class AppShellController extends GetxController {
  static const tabRoutes = <String>[
    AppRoutes.calculator,
    AppRoutes.rangeCardList,
    AppRoutes.quickPresets,
    AppRoutes.dopeProfiles,
    AppRoutes.visualRangeCard,
  ];

  final currentRoute = AppRoutes.calculator.obs;

  @override
  void onInit() {
    super.onInit();
    currentRoute.value = _normalizedRoute(Get.arguments);
  }

  void selectRoute(String route) {
    currentRoute.value = _normalizedRoute(route);
  }

  int get currentIndex {
    final index = tabRoutes.indexOf(currentRoute.value);
    return index < 0 ? 0 : index;
  }

  String _normalizedRoute(Object? route) {
    if (route is String && tabRoutes.contains(route)) {
      return route;
    }
    return AppRoutes.calculator;
  }
}
