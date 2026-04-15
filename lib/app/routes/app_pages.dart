import 'package:get/get.dart';
import 'package:milexact/app/middleware/auth_guard_middleware.dart';
import 'package:milexact/app/routes/app_routes.dart';
import 'package:milexact/modules/auth/bindings/forgot_password_binding.dart';
import 'package:milexact/modules/auth/bindings/reset_password_binding.dart';
import 'package:milexact/modules/auth/bindings/sign_in_binding.dart';
import 'package:milexact/modules/auth/bindings/sign_up_binding.dart';
import 'package:milexact/modules/auth/views/check_email_screen.dart';
import 'package:milexact/modules/auth/views/forgot_password_screen.dart';
import 'package:milexact/modules/auth/views/reset_password_screen.dart';
import 'package:milexact/modules/auth/views/sign_in_screen.dart';
import 'package:milexact/modules/auth/views/sign_up_screen.dart';
import 'package:milexact/modules/calculator/bindings/calculator_binding.dart';
import 'package:milexact/modules/calculator/views/calculator_screen.dart';
import 'package:milexact/modules/dope/bindings/dope_profiles_binding.dart';
import 'package:milexact/modules/dope/views/dope_profiles_screen.dart';
import 'package:milexact/modules/presets/bindings/preset_manager_binding.dart';
import 'package:milexact/modules/presets/views/preset_manager_screen.dart';
import 'package:milexact/modules/range_card/bindings/range_card_edit_binding.dart';
import 'package:milexact/modules/range_card/bindings/range_card_list_binding.dart';
import 'package:milexact/modules/range_card/views/range_card_edit_screen.dart';
import 'package:milexact/modules/range_card/views/range_card_list_screen.dart';
import 'package:milexact/modules/settings/bindings/settings_binding.dart';
import 'package:milexact/modules/settings/views/settings_screen.dart';
import 'package:milexact/modules/visual_range_card/bindings/visual_range_card_binding.dart';
import 'package:milexact/modules/visual_range_card/views/visual_range_card_screen.dart';

class AppPages {
  static final pages = <GetPage<dynamic>>[
    GetPage(
      name: AppRoutes.signIn,
      page: SignInScreen.new,
      binding: SignInBinding(),
      middlewares: [AuthGuardMiddleware(requiresAuth: false)],
    ),
    GetPage(
      name: AppRoutes.signUp,
      page: SignUpScreen.new,
      binding: SignUpBinding(),
      middlewares: [AuthGuardMiddleware(requiresAuth: false)],
    ),
    GetPage(
      name: AppRoutes.forgotPassword,
      page: ForgotPasswordScreen.new,
      binding: ForgotPasswordBinding(),
      middlewares: [AuthGuardMiddleware(requiresAuth: false)],
    ),
    GetPage(
      name: AppRoutes.checkEmail,
      page: CheckEmailScreen.new,
      middlewares: [AuthGuardMiddleware(requiresAuth: false)],
    ),
    GetPage(
      name: AppRoutes.resetPassword,
      page: ResetPasswordScreen.new,
      binding: ResetPasswordBinding(),
      middlewares: [AuthGuardMiddleware(requiresAuth: false)],
    ),
    GetPage(
      name: AppRoutes.calculator,
      page: CalculatorScreen.new,
      binding: CalculatorBinding(),
      middlewares: [AuthGuardMiddleware(requiresAuth: true)],
    ),
    GetPage(
      name: AppRoutes.rangeCardList,
      page: RangeCardListScreen.new,
      binding: RangeCardListBinding(),
      middlewares: [AuthGuardMiddleware(requiresAuth: true)],
    ),
    GetPage(
      name: AppRoutes.rangeCardEdit,
      page: RangeCardEditScreen.new,
      binding: RangeCardEditBinding(),
      middlewares: [AuthGuardMiddleware(requiresAuth: true)],
    ),
    GetPage(
      name: AppRoutes.quickPresets,
      page: QuickPresetScreen.new,
      binding: QuickPresetBinding(),
      middlewares: [AuthGuardMiddleware(requiresAuth: true)],
    ),
    GetPage(
      name: AppRoutes.dopeProfiles,
      page: DopeProfilesScreen.new,
      binding: DopeProfilesBinding(),
      middlewares: [AuthGuardMiddleware(requiresAuth: true)],
    ),
    GetPage(
      name: AppRoutes.visualRangeCard,
      page: VisualRangeCardScreen.new,
      binding: VisualRangeCardBinding(),
      middlewares: [AuthGuardMiddleware(requiresAuth: true)],
    ),
    GetPage(
      name: AppRoutes.settings,
      page: SettingsScreen.new,
      binding: SettingsBinding(),
      middlewares: [AuthGuardMiddleware(requiresAuth: true)],
    ),
  ];
}
