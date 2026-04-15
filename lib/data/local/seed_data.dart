import 'package:milexact/data/models/app_settings.dart';
import 'package:milexact/data/models/dope_profile.dart';
import 'package:milexact/data/models/dope_profile_entry.dart';
import 'package:milexact/data/models/enums.dart';
import 'package:milexact/data/models/target_category.dart';
import 'package:milexact/data/models/target_preset.dart';
import 'package:milexact/shared/utils/id_generator.dart';

abstract final class SeedData {
  static const humanCategoryId = 'category-human';
  static const animalsCategoryId = 'category-animals';
  static const vehiclesCategoryId = 'category-vehicles';
  static const targetsCategoryId = 'category-targets';
  static const militaryCategoryId = 'category-military';
  static const objectsCategoryId = 'category-objects';

  static AppSettings defaultSettings() => AppSettings.defaults();

  static List<TargetCategory> defaultCategories() {
    final now = DateTime.now();

    return [
      TargetCategory(
        id: humanCategoryId,
        name: 'Human',
        createdAt: now,
        updatedAt: now,
      ),
      TargetCategory(
        id: animalsCategoryId,
        name: 'Animals',
        createdAt: now,
        updatedAt: now,
      ),
      TargetCategory(
        id: vehiclesCategoryId,
        name: 'Vehicles',
        createdAt: now,
        updatedAt: now,
      ),
      TargetCategory(
        id: targetsCategoryId,
        name: 'Targets',
        createdAt: now,
        updatedAt: now,
      ),
      TargetCategory(
        id: militaryCategoryId,
        name: 'Military',
        createdAt: now,
        updatedAt: now,
      ),
      TargetCategory(
        id: objectsCategoryId,
        name: 'Objects',
        createdAt: now,
        updatedAt: now,
      ),
    ];
  }

  static List<TargetPreset> defaultPresets() {
    final now = DateTime.now();

    return [
      TargetPreset(
        id: 'preset-ipsc-a-zone',
        categoryId: targetsCategoryId,
        name: 'IPSC A-Zone',
        heightValue: 11,
        heightUnit: UnitType.inch,
        widthValue: 6,
        widthUnit: UnitType.inch,
        supportsMetric: true,
        supportsImperial: true,
        isCustom: false,
        createdAt: now,
        updatedAt: now,
      ),
      TargetPreset(
        id: 'preset-ipsc-full',
        categoryId: targetsCategoryId,
        name: 'IPSC Full Target',
        heightValue: 30,
        heightUnit: UnitType.inch,
        widthValue: 18,
        widthUnit: UnitType.inch,
        supportsMetric: true,
        supportsImperial: true,
        isCustom: false,
        createdAt: now,
        updatedAt: now,
      ),
      TargetPreset(
        id: 'preset-steel-12',
        categoryId: targetsCategoryId,
        name: '12 inch Steel',
        heightValue: 12,
        heightUnit: UnitType.inch,
        widthValue: 12,
        widthUnit: UnitType.inch,
        supportsMetric: true,
        supportsImperial: true,
        isCustom: false,
        createdAt: now,
        updatedAt: now,
      ),
      TargetPreset(
        id: 'preset-steel-18',
        categoryId: targetsCategoryId,
        name: '18 inch Steel',
        heightValue: 18,
        heightUnit: UnitType.inch,
        widthValue: 18,
        widthUnit: UnitType.inch,
        supportsMetric: true,
        supportsImperial: true,
        isCustom: false,
        createdAt: now,
        updatedAt: now,
      ),
      TargetPreset(
        id: 'preset-steel-24',
        categoryId: targetsCategoryId,
        name: '24 inch Steel',
        heightValue: 24,
        heightUnit: UnitType.inch,
        widthValue: 24,
        widthUnit: UnitType.inch,
        supportsMetric: true,
        supportsImperial: true,
        isCustom: false,
        createdAt: now,
        updatedAt: now,
      ),
      TargetPreset(
        id: 'preset-idpa-target',
        categoryId: targetsCategoryId,
        name: 'IDPA Target',
        heightValue: 30,
        heightUnit: UnitType.inch,
        widthValue: 18,
        widthUnit: UnitType.inch,
        supportsMetric: true,
        supportsImperial: true,
        isCustom: false,
        createdAt: now,
        updatedAt: now,
      ),
      TargetPreset(
        id: 'preset-b27-full',
        categoryId: targetsCategoryId,
        name: 'B27 Full Target',
        heightValue: 45,
        heightUnit: UnitType.inch,
        widthValue: 24,
        widthUnit: UnitType.inch,
        supportsMetric: true,
        supportsImperial: true,
        isCustom: false,
        createdAt: now,
        updatedAt: now,
      ),
      TargetPreset(
        id: 'preset-standing-adult',
        categoryId: humanCategoryId,
        name: 'Standing Adult',
        heightValue: 1.75,
        heightUnit: UnitType.meter,
        widthValue: 0.46,
        widthUnit: UnitType.meter,
        supportsMetric: true,
        supportsImperial: true,
        isCustom: false,
        createdAt: now,
        updatedAt: now,
      ),
      TargetPreset(
        id: 'preset-deer-body',
        categoryId: animalsCategoryId,
        name: 'Deer Body',
        heightValue: 0.90,
        heightUnit: UnitType.meter,
        widthValue: 1.35,
        widthUnit: UnitType.meter,
        supportsMetric: true,
        supportsImperial: true,
        isCustom: false,
        createdAt: now,
        updatedAt: now,
      ),
      TargetPreset(
        id: 'preset-pickup-truck',
        categoryId: vehiclesCategoryId,
        name: 'Pickup Truck',
        heightValue: 1.90,
        heightUnit: UnitType.meter,
        widthValue: 2.10,
        widthUnit: UnitType.meter,
        supportsMetric: true,
        supportsImperial: true,
        isCustom: false,
        createdAt: now,
        updatedAt: now,
      ),
      TargetPreset(
        id: 'preset-humvee',
        categoryId: militaryCategoryId,
        name: 'HMMWV / Humvee',
        heightValue: 1.83,
        heightUnit: UnitType.meter,
        widthValue: 2.16,
        widthUnit: UnitType.meter,
        supportsMetric: true,
        supportsImperial: true,
        isCustom: false,
        createdAt: now,
        updatedAt: now,
      ),
      TargetPreset(
        id: 'preset-door-frame',
        categoryId: objectsCategoryId,
        name: 'Door Frame',
        heightValue: 2.03,
        heightUnit: UnitType.meter,
        widthValue: 0.91,
        widthUnit: UnitType.meter,
        supportsMetric: true,
        supportsImperial: true,
        isCustom: false,
        createdAt: now,
        updatedAt: now,
      ),
    ];
  }

  static List<DopeProfile> defaultDopeProfiles() {
    final now = DateTime.now();
    const profileId = 'dope-demo-308';

    return [
      DopeProfile(
        id: profileId,
        rifleName: 'Demo Rifle',
        caliber: '.308 Win',
        bulletGrain: 168,
        velocityFps: 2650,
        entries: [
          DopeProfileEntry(
            id: IdGenerator.generate(prefix: 'dope-row'),
            profileId: profileId,
            distanceValue: 300,
            distanceUnit: UnitType.yard,
            dropValue: '1.5 MIL',
            notes: 'Zero confirm',
          ),
          DopeProfileEntry(
            id: IdGenerator.generate(prefix: 'dope-row'),
            profileId: profileId,
            distanceValue: 500,
            distanceUnit: UnitType.yard,
            dropValue: '3.2 MIL',
            notes: 'Baseline',
          ),
          DopeProfileEntry(
            id: IdGenerator.generate(prefix: 'dope-row'),
            profileId: profileId,
            distanceValue: 700,
            distanceUnit: UnitType.yard,
            dropValue: '5.4 MIL',
            notes: 'High confidence',
          ),
        ],
        isActive: true,
        createdAt: now,
        updatedAt: now,
      ),
    ];
  }
}
