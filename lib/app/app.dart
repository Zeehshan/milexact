import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:milexact/app/routes/app_pages.dart';
import 'package:milexact/app/routes/app_routes.dart';
import 'package:milexact/app/theme/app_theme.dart';

class MilExactApp extends StatelessWidget {
  const MilExactApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'MilExact',
      theme: AppTheme.darkTheme,
      initialRoute: AppRoutes.calculator,
      getPages: AppPages.pages,
    );
  }
}
