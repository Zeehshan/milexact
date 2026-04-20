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
    await _mergeBuiltInCategories();
    await _mergeBuiltInPresets();

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

  Future<void> _mergeBuiltInCategories() async {
    final existingIds = _storage.categoriesBox.keys
        .map((key) => key.toString())
        .toSet();
    final missing = {
      for (final category in SeedData.defaultCategories())
        if (!existingIds.contains(category.id)) category.id: category.toJson(),
    };
    if (missing.isNotEmpty) {
      await _storage.categoriesBox.putAll(missing);
    }
  }

  Future<void> _mergeBuiltInPresets() async {
    final existingIds = _storage.presetsBox.keys
        .map((key) => key.toString())
        .toSet();
    final missing = {
      for (final preset in SeedData.defaultPresets())
        if (!existingIds.contains(preset.id)) preset.id: preset.toJson(),
    };
    if (missing.isNotEmpty) {
      await _storage.presetsBox.putAll(missing);
    }
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
