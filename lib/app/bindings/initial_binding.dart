import 'package:get/get.dart';
import 'package:milexact/data/repositories/auth_repository.dart';
import 'package:milexact/data/repositories/dope_profiles_repository.dart';
import 'package:milexact/data/repositories/presets_repository.dart';
import 'package:milexact/data/repositories/range_card_repository.dart';
import 'package:milexact/data/repositories/settings_repository.dart';
import 'package:milexact/data/repositories/visual_range_card_repository.dart';
import 'package:milexact/services/calculation_service.dart';
import 'package:milexact/services/auth_api_service.dart';
import 'package:milexact/services/auth_service.dart';
import 'package:milexact/services/reticle_measurement_service.dart';
import 'package:milexact/services/social_identity_service.dart';
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
    Get.put<AuthApiService>(AuthApiService(), permanent: true);
    Get.put<ReticleMeasurementService>(
      ReticleMeasurementService(),
      permanent: true,
    );
    Get.put<SocialIdentityService>(SocialIdentityService(), permanent: true);
    Get.put<VisualRangeCardService>(VisualRangeCardService(), permanent: true);

    await Get.putAsync<SettingsRepository>(
      () => SettingsRepository(storage).init(),
      permanent: true,
    );
    await Get.putAsync<AuthRepository>(
      () => AuthRepository(storage).init(),
      permanent: true,
    );
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
    Get.put<AuthService>(
      AuthService(
        Get.find<AuthRepository>(),
        Get.find<AuthApiService>(),
        Get.find<SocialIdentityService>(),
      ),
      permanent: true,
    );
  }

  @override
  void dependencies() {}
}
