import 'package:get/get.dart';
import 'package:milexact/data/local/seed_data.dart';
import 'package:milexact/data/models/target_category.dart';
import 'package:milexact/data/models/target_preset.dart';
import 'package:milexact/services/storage_service.dart';

class PresetsRepository extends GetxService {
  PresetsRepository(this._storage);

  final StorageService _storage;
  final RxList<TargetCategory> categories = <TargetCategory>[].obs;
  final RxList<TargetPreset> presets = <TargetPreset>[].obs;

  Future<PresetsRepository> init() async {
    await _syncBuiltInCategories();
    await _syncBuiltInPresets();

    _reload();
    return this;
  }

  List<TargetPreset> presetsForCategory(String categoryId) {
    final filtered = presets
        .where((preset) => preset.categoryId == categoryId)
        .toList(growable: false);
    filtered.sort(
      (left, right) =>
          left.name.toLowerCase().compareTo(right.name.toLowerCase()),
    );
    return filtered;
  }

  TargetCategory? categoryById(String id) {
    return categories.firstWhereOrNull((category) => category.id == id);
  }

  TargetPreset? presetById(String id) {
    return presets.firstWhereOrNull((preset) => preset.id == id);
  }

  Future<void> upsertCategory(TargetCategory category) async {
    await _storage.categoriesBox.put(category.id, category.toJson());
    _reload();
  }

  Future<void> deleteCategory(String categoryId) async {
    final presetIds = presetsForCategory(
      categoryId,
    ).map((preset) => preset.id).toList(growable: false);

    if (presetIds.isNotEmpty) {
      await _storage.presetsBox.deleteAll(presetIds);
    }

    await _storage.categoriesBox.delete(categoryId);
    _reload();
  }

  Future<void> upsertPreset(TargetPreset preset) async {
    await _storage.presetsBox.put(preset.id, preset.toJson());
    _reload();
  }

  Future<void> deletePreset(String presetId) async {
    await _storage.presetsBox.delete(presetId);
    _reload();
  }

  Future<void> _syncBuiltInCategories() async {
    final existingById = {
      for (final entry in _storage.categoriesBox.toMap().entries)
        entry.key.toString(): TargetCategory.fromJson(
          Map<String, dynamic>.from(entry.value),
        ),
    };

    final writes = <String, Map<String, dynamic>>{};
    for (final category in SeedData.defaultCategories()) {
      final existing = existingById[category.id];
      if (existing == null) {
        writes[category.id] = category.toJson();
        continue;
      }
      if (existing.name == category.name) {
        continue;
      }
      writes[category.id] = category
          .copyWith(createdAt: existing.createdAt, updatedAt: DateTime.now())
          .toJson();
    }

    if (writes.isNotEmpty) {
      await _storage.categoriesBox.putAll(writes);
    }
  }

  Future<void> _syncBuiltInPresets() async {
    final existingById = {
      for (final entry in _storage.presetsBox.toMap().entries)
        entry.key.toString(): TargetPreset.fromJson(
          Map<String, dynamic>.from(entry.value),
        ),
    };
    final seedPresets = SeedData.defaultPresets();
    final seedIds = seedPresets.map((preset) => preset.id).toSet();
    final writes = <String, Map<String, dynamic>>{};

    for (final preset in seedPresets) {
      final existing = existingById[preset.id];
      if (existing == null) {
        writes[preset.id] = preset.toJson();
        continue;
      }
      if (_matchesSeed(existing, preset)) {
        continue;
      }
      writes[preset.id] = preset
          .copyWith(createdAt: existing.createdAt, updatedAt: DateTime.now())
          .toJson();
    }

    final obsoleteBuiltInIds = existingById.entries
        .where((entry) => !entry.value.isCustom && !seedIds.contains(entry.key))
        .map((entry) => entry.key)
        .toList(growable: false);

    if (obsoleteBuiltInIds.isNotEmpty) {
      await _storage.presetsBox.deleteAll(obsoleteBuiltInIds);
    }
    if (writes.isNotEmpty) {
      await _storage.presetsBox.putAll(writes);
    }
  }

  bool _matchesSeed(TargetPreset existing, TargetPreset seed) {
    return existing.categoryId == seed.categoryId &&
        existing.name == seed.name &&
        existing.heightValue == seed.heightValue &&
        existing.heightUnit == seed.heightUnit &&
        existing.widthValue == seed.widthValue &&
        existing.widthUnit == seed.widthUnit &&
        existing.supportsMetric == seed.supportsMetric &&
        existing.supportsImperial == seed.supportsImperial &&
        existing.isCustom == seed.isCustom;
  }

  void _reload() {
    categories.assignAll(
      _storage.categoriesBox.values
          .map((raw) => TargetCategory.fromJson(Map<String, dynamic>.from(raw)))
          .toList()
        ..sort(
          (left, right) =>
              left.name.toLowerCase().compareTo(right.name.toLowerCase()),
        ),
    );
    presets.assignAll(
      _storage.presetsBox.values
          .map((raw) => TargetPreset.fromJson(Map<String, dynamic>.from(raw)))
          .toList(),
    );
  }
}
