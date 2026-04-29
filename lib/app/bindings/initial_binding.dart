import 'package:get/get.dart';
import 'package:milexact/data/repositories/auth_repository.dart';
import 'package:milexact/data/remote/firebase/firebase_auth_data_source.dart';
import 'package:milexact/data/remote/firebase/firestore_user_profile_data_source.dart';
import 'package:milexact/data/repositories/dope_profiles_repository.dart';
import 'package:milexact/data/repositories/presets_repository.dart';
import 'package:milexact/data/repositories/range_card_repository.dart';
import 'package:milexact/data/repositories/settings_repository.dart';
import 'package:milexact/data/repositories/visual_range_card_repository.dart';
import 'package:milexact/domain/auth/repositories/auth_repository_contract.dart';
import 'package:milexact/domain/auth/use_cases/observe_auth_state_use_case.dart';
import 'package:milexact/domain/auth/use_cases/reload_current_user_use_case.dart';
import 'package:milexact/domain/auth/use_cases/restore_current_user_use_case.dart';
import 'package:milexact/domain/auth/use_cases/send_email_verification_use_case.dart';
import 'package:milexact/domain/auth/use_cases/send_password_reset_email_use_case.dart';
import 'package:milexact/domain/auth/use_cases/sign_in_with_apple_use_case.dart';
import 'package:milexact/domain/auth/use_cases/sign_in_with_email_use_case.dart';
import 'package:milexact/domain/auth/use_cases/sign_in_with_google_use_case.dart';
import 'package:milexact/domain/auth/use_cases/sign_out_use_case.dart';
import 'package:milexact/domain/auth/use_cases/sign_up_with_email_use_case.dart';
import 'package:milexact/services/calculation_service.dart';
import 'package:milexact/services/auth_service.dart';
import 'package:milexact/services/reticle_measurement_service.dart';
import 'package:milexact/services/storage_service.dart';
import 'package:milexact/services/unit_conversion_service.dart';
import 'package:milexact/services/visual_range_card_service.dart';

class InitialBinding extends Bindings {
  static Future<void> initServices() async {
    if (Get.isRegistered<StorageService>()) {
      return;
    }

    final storage = await Get.putAsync<StorageService>(
      () => StorageService().init(),
      permanent: true,
    );
    final unitConversion = Get.put<UnitConversionService>(
      UnitConversionService(),
      permanent: true,
    );

    Get.put<CalculationService>(
      CalculationService(unitConversion),
      permanent: true,
    );
    Get.put<FirebaseAuthDataSource>(FirebaseAuthDataSource(), permanent: true);
    Get.put<FirestoreUserProfileDataSource>(
      FirestoreUserProfileDataSource(),
      permanent: true,
    );
    Get.put<ReticleMeasurementService>(
      ReticleMeasurementService(),
      permanent: true,
    );
    Get.put<VisualRangeCardService>(VisualRangeCardService(), permanent: true);

    await Get.putAsync<SettingsRepository>(
      () => SettingsRepository(storage).init(),
      permanent: true,
    );
    final authRepository = await Get.putAsync<AuthRepository>(
      () => AuthRepository(
        Get.find<FirebaseAuthDataSource>(),
        Get.find<FirestoreUserProfileDataSource>(),
      ).init(),
      permanent: true,
    );
    Get.put<AuthRepositoryContract>(authRepository, permanent: true);
    await Get.putAsync<PresetsRepository>(
      () => PresetsRepository(storage).init(),
      permanent: true,
    );
    await Get.putAsync<RangeCardRepository>(
      () => RangeCardRepository(storage).init(),
      permanent: true,
    );
    await Get.putAsync<DopeProfilesRepository>(
      () => DopeProfilesRepository(storage).init(),
      permanent: true,
    );
    await Get.putAsync<VisualRangeCardRepository>(
      () => VisualRangeCardRepository(storage).init(),
      permanent: true,
    );
    Get.put<ObserveAuthStateUseCase>(
      ObserveAuthStateUseCase(Get.find<AuthRepositoryContract>()),
      permanent: true,
    );
    Get.put<RestoreCurrentUserUseCase>(
      RestoreCurrentUserUseCase(Get.find<AuthRepositoryContract>()),
      permanent: true,
    );
    Get.put<ReloadCurrentUserUseCase>(
      ReloadCurrentUserUseCase(Get.find<AuthRepositoryContract>()),
      permanent: true,
    );
    Get.put<SignUpWithEmailUseCase>(
      SignUpWithEmailUseCase(Get.find<AuthRepositoryContract>()),
      permanent: true,
    );
    Get.put<SignInWithEmailUseCase>(
      SignInWithEmailUseCase(Get.find<AuthRepositoryContract>()),
      permanent: true,
    );
    Get.put<SignInWithGoogleUseCase>(
      SignInWithGoogleUseCase(Get.find<AuthRepositoryContract>()),
      permanent: true,
    );
    Get.put<SignInWithAppleUseCase>(
      SignInWithAppleUseCase(Get.find<AuthRepositoryContract>()),
      permanent: true,
    );
    Get.put<SendPasswordResetEmailUseCase>(
      SendPasswordResetEmailUseCase(Get.find<AuthRepositoryContract>()),
      permanent: true,
    );
    Get.put<SendEmailVerificationUseCase>(
      SendEmailVerificationUseCase(Get.find<AuthRepositoryContract>()),
      permanent: true,
    );
    Get.put<SignOutUseCase>(
      SignOutUseCase(Get.find<AuthRepositoryContract>()),
      permanent: true,
    );

    await Get.putAsync<AuthService>(
      () => AuthService(
        observeAuthStateUseCase: Get.find<ObserveAuthStateUseCase>(),
        restoreCurrentUserUseCase: Get.find<RestoreCurrentUserUseCase>(),
        reloadCurrentUserUseCase: Get.find<ReloadCurrentUserUseCase>(),
        signUpWithEmailUseCase: Get.find<SignUpWithEmailUseCase>(),
        signInWithEmailUseCase: Get.find<SignInWithEmailUseCase>(),
        signInWithGoogleUseCase: Get.find<SignInWithGoogleUseCase>(),
        signInWithAppleUseCase: Get.find<SignInWithAppleUseCase>(),
        sendPasswordResetEmailUseCase:
            Get.find<SendPasswordResetEmailUseCase>(),
        sendEmailVerificationUseCase: Get.find<SendEmailVerificationUseCase>(),
        signOutUseCase: Get.find<SignOutUseCase>(),
      ).init(),
      permanent: true,
    );
  }

  @override
  void dependencies() {}
}
