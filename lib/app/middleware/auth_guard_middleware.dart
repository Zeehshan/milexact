import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:milexact/app/routes/app_routes.dart';
import 'package:milexact/services/auth_service.dart';

class AuthGuardMiddleware extends GetMiddleware {
  AuthGuardMiddleware({required this.requiresAuth});

  final bool requiresAuth;

  @override
  RouteSettings? redirect(String? route) {
    final authService = Get.find<AuthService>();

    if (requiresAuth && !authService.isSignedIn) {
      return const RouteSettings(name: AppRoutes.signIn);
    }
    if (!requiresAuth && authService.isSignedIn) {
      return const RouteSettings(name: AppRoutes.calculator);
    }

    return null;
  }
}
