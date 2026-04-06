import 'package:flutter/material.dart';
import 'package:milexact/shared/widgets/app_bottom_nav_bar.dart';

class TacticalScaffold extends StatelessWidget {
  const TacticalScaffold({
    super.key,
    required this.title,
    required this.body,
    this.currentRoute,
    this.actions = const <Widget>[],
    this.showBottomNav = true,
    this.floatingActionButton,
    this.resizeToAvoidBottomInset = true,
  });

  final String title;
  final Widget body;
  final String? currentRoute;
  final List<Widget> actions;
  final bool showBottomNav;
  final Widget? floatingActionButton;
  final bool resizeToAvoidBottomInset;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: resizeToAvoidBottomInset,
      appBar: AppBar(title: Text(title), actions: actions),
      body: SafeArea(child: body),
      floatingActionButton: floatingActionButton,
      bottomNavigationBar: showBottomNav && currentRoute != null
          ? AppBottomNavBar(currentRoute: currentRoute!)
          : null,
    );
  }
}
