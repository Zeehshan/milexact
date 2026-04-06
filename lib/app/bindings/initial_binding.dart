import 'package:get/get.dart';
import 'package:milexact/data/repositories/presets_repository.dart';
import 'package:milexact/data/repositories/range_card_repository.dart';
import 'package:milexact/data/repositories/settings_repository.dart';
import 'package:milexact/services/calculation_service.dart';
import 'package:milexact/services/storage_service.dart';
import 'package:milexact/services/unit_conversion_service.dart';

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

    await Get.putAsync<SettingsRepository>(
      () => SettingsRepository(storage).init(),
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
  }

  @override
  void dependencies() {}
}
