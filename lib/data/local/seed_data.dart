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
      _category(humanCategoryId, 'Human', now),
      _category(animalsCategoryId, 'Animals', now),
      _category(vehiclesCategoryId, 'Vehicles', now),
      _category(targetsCategoryId, 'Targets', now),
      _category(militaryCategoryId, 'Military', now),
      _category(objectsCategoryId, 'Objects', now),
    ];
  }

  static List<TargetPreset> defaultPresets() {
    final now = DateTime.now();

    return [
      ..._presetGroup(
        categoryId: humanCategoryId,
        now: now,
        definitions: const [
          _SeedPresetDefinition('Standing Person', 1.80, 0.45),
          _SeedPresetDefinition('Seated Person', 1.20, 0.45),
          _SeedPresetDefinition('Torso', 0.60, 0.45),
          _SeedPresetDefinition('Head', 0.25, 0.20),
          _SeedPresetDefinition('Helmet', 0.25, 0.28),
        ],
      ),
      ..._presetGroup(
        categoryId: animalsCategoryId,
        now: now,
        definitions: const [
          _SeedPresetDefinition('Deer', 0.90, 1.50),
          _SeedPresetDefinition('Blacktail Deer', 0.85, 1.30),
          _SeedPresetDefinition('Mule Deer', 1.00, 1.50),
          _SeedPresetDefinition('Whitetail', 0.90, 1.20),
          _SeedPresetDefinition('Pronghorn', 0.87, 1.40),
          _SeedPresetDefinition('Elk', 1.40, 2.00),
          _SeedPresetDefinition('Moose', 1.80, 2.50),
          _SeedPresetDefinition('Black Bear', 0.90, 1.50),
          _SeedPresetDefinition('Brown Bear', 1.20, 1.80),
          _SeedPresetDefinition('Grizzly Bear', 1.20, 1.80),
          _SeedPresetDefinition('Mountain Lion', 0.65, 1.60),
          _SeedPresetDefinition('Mountain Goat', 0.90, 1.40),
          _SeedPresetDefinition('Bighorn Sheep', 0.90, 1.50),
          _SeedPresetDefinition('Bobcat', 0.45, 0.80),
          _SeedPresetDefinition('Coyote', 0.60, 0.75),
          _SeedPresetDefinition('Squirrel', 0.20, 0.25),
          _SeedPresetDefinition('Turkey', 1.00, 0.50),
          _SeedPresetDefinition('Hog', 0.70, 1.00),
          _SeedPresetDefinition('Cow', 1.40, 2.20),
          _SeedPresetDefinition('Horse', 1.60, 2.40),
        ],
      ),
      ..._presetGroup(
        categoryId: vehiclesCategoryId,
        now: now,
        definitions: const [
          _SeedPresetDefinition('Car', 1.40, 1.80),
          _SeedPresetDefinition('Pickup Truck', 1.80, 2.00),
          _SeedPresetDefinition('SUV', 1.70, 2.00),
          _SeedPresetDefinition('Semi Truck', 4.00, 2.60),
          _SeedPresetDefinition('Motorcycle', 1.10, 0.80),
          _SeedPresetDefinition('Golf Cart', 1.80, 1.20),
          _SeedPresetDefinition('ATV', 1.20, 1.20),
          _SeedPresetDefinition('Lawn Mower', 1.10, 0.53),
          _SeedPresetDefinition('Fire Truck', 3.20, 2.50),
        ],
      ),
      ..._presetGroup(
        categoryId: targetsCategoryId,
        now: now,
        definitions: const [
          _SeedPresetDefinition('IPSC A-Zone', 0.300, 0.180),
          _SeedPresetDefinition('IPSC Full Target', 0.750, 0.450),
          _SeedPresetDefinition('12" Steel', 0.305, 0.305),
          _SeedPresetDefinition('18" Steel', 0.457, 0.457),
          _SeedPresetDefinition('24" Steel', 0.610, 0.610),
          _SeedPresetDefinition('IDPA Target', 0.600, 0.450),
          _SeedPresetDefinition('B27 Full Target', 0.760, 0.560),
        ],
      ),
      ..._presetGroup(
        categoryId: militaryCategoryId,
        now: now,
        definitions: const [
          _SeedPresetDefinition('NATO Silhouette', 1.80, 0.45),
          _SeedPresetDefinition('Doorway', 2.00, 0.90),
          _SeedPresetDefinition('Window', 1.20, 1.00),
          _SeedPresetDefinition('Humvee', 1.80, 2.20),
          _SeedPresetDefinition('APC', 2.70, 3.00),
          _SeedPresetDefinition('Tank', 2.40, 3.60),
          _SeedPresetDefinition('Artillery', 1.80, 6.00),
          _SeedPresetDefinition('Mortar', 1.20, 0.30),
          _SeedPresetDefinition('Helicopter', 3.80, 14.00),
          _SeedPresetDefinition('Fighter Jet', 4.50, 11.00),
          _SeedPresetDefinition('Transport Plane', 12.50, 50.00),
          _SeedPresetDefinition('Drone (small)', 0.30, 1.00),
          _SeedPresetDefinition('Drone (large)', 2.10, 14.00),
          _SeedPresetDefinition('Missile', 0.50, 5.00),
        ],
      ),
      ..._presetGroup(
        categoryId: objectsCategoryId,
        now: now,
        definitions: const [
          _SeedPresetDefinition('License Plate', 0.152, 0.305),
          _SeedPresetDefinition('Stop Sign', 0.760, 0.760),
          _SeedPresetDefinition('Traffic Cone', 0.710, 0.360),
          _SeedPresetDefinition('Fire Hydrant', 0.640, 0.230),
          _SeedPresetDefinition('Mailbox', 0.460, 0.200),
          _SeedPresetDefinition('5 Gal Bucket', 0.370, 0.290),
          _SeedPresetDefinition('Barrel (55 gal)', 0.880, 0.570),
          _SeedPresetDefinition('20 lb Propane Tank', 0.460, 0.300),
          _SeedPresetDefinition('30 lb Propane Tank', 0.560, 0.310),
          _SeedPresetDefinition('Wheel Rim', 0.430, 0.430),
          _SeedPresetDefinition('Bicycle Rim', 0.660, 0.660),
          _SeedPresetDefinition('Air Conditioner', 0.430, 0.660),
          _SeedPresetDefinition('Street Light Signal', 1.070, 0.330),
          _SeedPresetDefinition('Outhouse', 2.100, 1.200),
          _SeedPresetDefinition('Garage Door', 2.130, 2.440),
          _SeedPresetDefinition('Shipping Container 20ft', 2.590, 6.060),
          _SeedPresetDefinition('Shipping Container 40ft', 2.590, 12.19),
        ],
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

  static TargetCategory _category(String id, String name, DateTime now) {
    return TargetCategory(id: id, name: name, createdAt: now, updatedAt: now);
  }

  static List<TargetPreset> _presetGroup({
    required String categoryId,
    required DateTime now,
    required List<_SeedPresetDefinition> definitions,
  }) {
    return definitions
        .map(
          (definition) => _preset(
            id: _builtInPresetId(categoryId, definition.label),
            categoryId: categoryId,
            name: definition.label,
            heightValue: definition.height,
            heightUnit: UnitType.meter,
            widthValue: definition.width,
            widthUnit: UnitType.meter,
            now: now,
          ),
        )
        .toList(growable: false);
  }

  static String _builtInPresetId(String categoryId, String label) {
    final categorySlug = categoryId.replaceFirst('category-', '');
    final labelSlug = label
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9]+'), '-')
        .replaceAll(RegExp(r'^-+|-+$'), '');
    return 'preset-$categorySlug-$labelSlug';
  }

  static TargetPreset _preset({
    required String id,
    required String categoryId,
    required String name,
    required double heightValue,
    required UnitType heightUnit,
    required double widthValue,
    required UnitType widthUnit,
    required DateTime now,
  }) {
    return TargetPreset(
      id: id,
      categoryId: categoryId,
      name: name,
      heightValue: heightValue,
      heightUnit: heightUnit,
      widthValue: widthValue,
      widthUnit: widthUnit,
      supportsMetric: true,
      supportsImperial: true,
      isCustom: false,
      createdAt: now,
      updatedAt: now,
    );
  }
}

final class _SeedPresetDefinition {
  const _SeedPresetDefinition(this.label, this.height, this.width);

  final String label;
  final double height;
  final double width;
}
