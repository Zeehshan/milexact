import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:milexact/app/routes/app_routes.dart';
import 'package:milexact/modules/auth/models/check_email_mode.dart';
import 'package:milexact/services/auth_service.dart';

class AuthGuardMiddleware extends GetMiddleware {
  AuthGuardMiddleware({required this.requiresAuth});

  final bool requiresAuth;

  @override
  RouteSettings? redirect(String? route) {
    final authService = Get.find<AuthService>();
    final needsVerification = authService.needsEmailVerification;

    RouteSettings verificationRoute() {
      return RouteSettings(
        name: AppRoutes.checkEmail,
        arguments: <String, dynamic>{
          'email': authService.currentUser.value?.email ?? '',
          'mode': CheckEmailMode.verification.routeValue,
        },
      );
    }

    if (requiresAuth && !authService.isSignedIn) {
      return const RouteSettings(name: AppRoutes.signIn);
    }
    if (requiresAuth && needsVerification) {
      return verificationRoute();
    }
    if (!requiresAuth && authService.isSignedIn) {
      if (needsVerification && route != AppRoutes.checkEmail) {
        return verificationRoute();
      }
      if (!needsVerification) {
        return const RouteSettings(name: AppRoutes.home);
      }
    }

    return null;
  }
}
