import 'package:milexact/data/models/app_settings.dart';
import 'package:milexact/data/models/enums.dart';
import 'package:milexact/data/models/target_category.dart';
import 'package:milexact/data/models/target_preset.dart';

abstract final class SeedData {
  static const humanCategoryId = 'category-human';
  static const animalCategoryId = 'category-animal';
  static const vehicleCategoryId = 'category-vehicle';
  static const objectCategoryId = 'category-object';
  static const steelTargetCategoryId = 'category-steel-target';

  static AppSettings defaultSettings() => AppSettings.defaults();

  static List<TargetCategory> defaultCategories() {
    final now = DateTime.now();

    return [
      TargetCategory(id: humanCategoryId, name: 'Human', createdAt: now),
      TargetCategory(id: animalCategoryId, name: 'Animal', createdAt: now),
      TargetCategory(id: vehicleCategoryId, name: 'Vehicle', createdAt: now),
      TargetCategory(id: objectCategoryId, name: 'Object', createdAt: now),
      TargetCategory(
        id: steelTargetCategoryId,
        name: 'Steel Target',
        createdAt: now,
      ),
    ];
  }

  static List<TargetPreset> defaultPresets() {
    final now = DateTime.now();

    return [
      TargetPreset(
        id: 'preset-human-standing-adult',
        categoryId: humanCategoryId,
        name: 'Standing Adult',
        sizeValue: 1.75,
        sizeUnit: MeasurementUnit.meter,
        isCustom: false,
        createdAt: now,
        updatedAt: now,
      ),
      TargetPreset(
        id: 'preset-human-shoulder-width',
        categoryId: humanCategoryId,
        name: 'Shoulder Width',
        sizeValue: 0.46,
        sizeUnit: MeasurementUnit.meter,
        isCustom: false,
        createdAt: now,
        updatedAt: now,
      ),
      TargetPreset(
        id: 'preset-human-torso-width',
        categoryId: humanCategoryId,
        name: 'Torso Width',
        sizeValue: 18,
        sizeUnit: MeasurementUnit.inch,
        isCustom: false,
        createdAt: now,
        updatedAt: now,
      ),
      TargetPreset(
        id: 'preset-animal-deer-chest',
        categoryId: animalCategoryId,
        name: 'Deer Chest Depth',
        sizeValue: 18,
        sizeUnit: MeasurementUnit.inch,
        isCustom: false,
        createdAt: now,
        updatedAt: now,
      ),
      TargetPreset(
        id: 'preset-animal-coyote-shoulder',
        categoryId: animalCategoryId,
        name: 'Coyote Shoulder Height',
        sizeValue: 0.45,
        sizeUnit: MeasurementUnit.meter,
        isCustom: false,
        createdAt: now,
        updatedAt: now,
      ),
      TargetPreset(
        id: 'preset-animal-hog-body',
        categoryId: animalCategoryId,
        name: 'Hog Body Height',
        sizeValue: 0.70,
        sizeUnit: MeasurementUnit.meter,
        isCustom: false,
        createdAt: now,
        updatedAt: now,
      ),
      TargetPreset(
        id: 'preset-vehicle-sedan-width',
        categoryId: vehicleCategoryId,
        name: 'Sedan Width',
        sizeValue: 1.80,
        sizeUnit: MeasurementUnit.meter,
        isCustom: false,
        createdAt: now,
        updatedAt: now,
      ),
      TargetPreset(
        id: 'preset-vehicle-pickup-height',
        categoryId: vehicleCategoryId,
        name: 'Pickup Height',
        sizeValue: 1.90,
        sizeUnit: MeasurementUnit.meter,
        isCustom: false,
        createdAt: now,
        updatedAt: now,
      ),
      TargetPreset(
        id: 'preset-vehicle-atv-width',
        categoryId: vehicleCategoryId,
        name: 'ATV Width',
        sizeValue: 1.20,
        sizeUnit: MeasurementUnit.meter,
        isCustom: false,
        createdAt: now,
        updatedAt: now,
      ),
      TargetPreset(
        id: 'preset-object-standard-door',
        categoryId: objectCategoryId,
        name: 'Standard Door',
        sizeValue: 2.03,
        sizeUnit: MeasurementUnit.meter,
        isCustom: false,
        createdAt: now,
        updatedAt: now,
      ),
      TargetPreset(
        id: 'preset-object-fence-post',
        categoryId: objectCategoryId,
        name: 'Fence Post',
        sizeValue: 1.50,
        sizeUnit: MeasurementUnit.meter,
        isCustom: false,
        createdAt: now,
        updatedAt: now,
      ),
      TargetPreset(
        id: 'preset-object-traffic-cone',
        categoryId: objectCategoryId,
        name: 'Traffic Cone',
        sizeValue: 0.71,
        sizeUnit: MeasurementUnit.meter,
        isCustom: false,
        createdAt: now,
        updatedAt: now,
      ),
      TargetPreset(
        id: 'preset-steel-ten-inch-plate',
        categoryId: steelTargetCategoryId,
        name: '10 in Plate',
        sizeValue: 10,
        sizeUnit: MeasurementUnit.inch,
        isCustom: false,
        createdAt: now,
        updatedAt: now,
      ),
      TargetPreset(
        id: 'preset-steel-twelve-inch-plate',
        categoryId: steelTargetCategoryId,
        name: '12 in Plate',
        sizeValue: 12,
        sizeUnit: MeasurementUnit.inch,
        isCustom: false,
        createdAt: now,
        updatedAt: now,
      ),
      TargetPreset(
        id: 'preset-steel-ipsc-torso',
        categoryId: steelTargetCategoryId,
        name: 'IPSC Torso',
        sizeValue: 0.76,
        sizeUnit: MeasurementUnit.meter,
        isCustom: false,
        createdAt: now,
        updatedAt: now,
      ),
    ];
  }
}
