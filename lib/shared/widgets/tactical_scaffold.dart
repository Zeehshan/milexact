import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:milexact/app/routes/app_routes.dart';
import 'package:milexact/shared/widgets/app_bottom_nav_bar.dart';
import 'package:milexact/shared/widgets/app_bar_action_menu.dart';

class TacticalScaffold extends StatelessWidget {
  const TacticalScaffold({
    super.key,
    required this.title,
    required this.body,
    this.currentRoute,
    this.actions = const <Widget>[],
    this.menuActions = const <AppBarMenuAction>[],
    this.showBottomNav = true,
    this.showSettingsAction = true,
    this.floatingActionButton,
    this.resizeToAvoidBottomInset = true,
  });

  final String title;
  final Widget body;
  final String? currentRoute;
  final List<Widget> actions;
  final List<AppBarMenuAction> menuActions;
  final bool showBottomNav;
  final bool showSettingsAction;
  final Widget? floatingActionButton;
  final bool resizeToAvoidBottomInset;

  @override
  Widget build(BuildContext context) {
    final hasSettingsAction =
        showSettingsAction && currentRoute != AppRoutes.settings;
    final resolvedMenuActions = <AppBarMenuAction>[
      ...menuActions,
      if (menuActions.isNotEmpty && hasSettingsAction)
        AppBarMenuAction(
          id: 'settings',
          label: 'Settings',
          icon: Icons.settings_rounded,
          onSelected: () => Get.toNamed(AppRoutes.settings),
        ),
    ];
    final resolvedActions = <Widget>[
      ...actions,
      if (resolvedMenuActions.isNotEmpty)
        AppBarActionMenu(actions: resolvedMenuActions)
      else if (hasSettingsAction)
        IconButton(
          tooltip: 'Settings',
          onPressed: () => Get.toNamed(AppRoutes.settings),
          icon: const Icon(Icons.settings_rounded),
        ),
    ];

    return Scaffold(
      resizeToAvoidBottomInset: resizeToAvoidBottomInset,
      appBar: AppBar(title: Text(title), actions: resolvedActions),
      body: SafeArea(child: body),
      floatingActionButton: floatingActionButton,
      bottomNavigationBar: showBottomNav && currentRoute != null
          ? AppBottomNavBar(currentRoute: currentRoute!)
          : null,
    );
  }
}
