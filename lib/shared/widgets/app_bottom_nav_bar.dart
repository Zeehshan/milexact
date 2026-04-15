import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:milexact/app/routes/app_routes.dart';

class AppBottomNavBar extends StatelessWidget {
  const AppBottomNavBar({super.key, required this.currentRoute});

  final String currentRoute;

  static const _items = <_NavItem>[
    _NavItem(
      route: AppRoutes.calculator,
      label: 'Calc',
      icon: Icons.radar_rounded,
    ),
    _NavItem(
      route: AppRoutes.rangeCardList,
      label: 'Range',
      icon: Icons.view_agenda_rounded,
    ),
    _NavItem(
      route: AppRoutes.quickPresets,
      label: 'Presets',
      icon: Icons.category_rounded,
    ),
    _NavItem(
      route: AppRoutes.dopeProfiles,
      label: 'DOPE',
      icon: Icons.straighten_rounded,
    ),
    _NavItem(
      route: AppRoutes.visualRangeCard,
      label: 'Visual',
      icon: Icons.explore_rounded,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final selectedIndex = _items.indexWhere(
      (item) => item.route == currentRoute,
    );

    return NavigationBar(
      selectedIndex: selectedIndex < 0 ? 0 : selectedIndex,
      destinations: _items
          .map(
            (item) =>
                NavigationDestination(icon: Icon(item.icon), label: item.label),
          )
          .toList(growable: false),
      onDestinationSelected: (index) {
        final route = _items[index].route;
        if (route == currentRoute) {
          return;
        }
        Get.offNamed(route);
      },
    );
  }
}

class _NavItem {
  const _NavItem({
    required this.route,
    required this.label,
    required this.icon,
  });

  final String route;
  final String label;
  final IconData icon;
}
