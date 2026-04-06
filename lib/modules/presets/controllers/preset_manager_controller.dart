import 'package:get/get.dart';
import 'package:milexact/data/models/enums.dart';
import 'package:milexact/data/models/target_category.dart';
import 'package:milexact/data/models/target_preset.dart';
import 'package:milexact/data/repositories/presets_repository.dart';
import 'package:milexact/shared/utils/id_generator.dart';

class PresetManagerController extends GetxController {
  PresetManagerController(this._repository);

  final PresetsRepository _repository;
  final selectedCategoryId = RxnString();

  @override
  void onInit() {
    super.onInit();
    _ensureCategorySelection();
  }

  RxList<TargetCategory> get categories => _repository.categories;

  TargetCategory? get selectedCategory {
    final categoryId = selectedCategoryId.value;
    if (categoryId == null) {
      return null;
    }
    return _repository.categoryById(categoryId);
  }

  List<TargetPreset> get categoryPresets {
    final categoryId = selectedCategoryId.value;
    if (categoryId == null) {
      return const <TargetPreset>[];
    }
    return _repository.presetsForCategory(categoryId);
  }

  void selectCategory(String categoryId) {
    selectedCategoryId.value = categoryId;
  }

  Future<void> saveCategory({String? categoryId, required String name}) async {
    final trimmed = name.trim();
    if (trimmed.isEmpty) {
      throw ArgumentError('Category name is required.');
    }

    final existing = categoryId == null
        ? null
        : _repository.categoryById(categoryId);
    final category =
        existing?.copyWith(name: trimmed) ??
        TargetCategory(
          id: IdGenerator.generate(prefix: 'category'),
          name: trimmed,
          createdAt: DateTime.now(),
        );

    await _repository.upsertCategory(category);
    selectedCategoryId.value = category.id;
  }

  Future<void> deleteCategory(TargetCategory category) async {
    await _repository.deleteCategory(category.id);
    _ensureCategorySelection();
  }

  Future<void> savePreset({
    String? presetId,
    required String categoryId,
    required String name,
    required String sizeValue,
    required MeasurementUnit sizeUnit,
  }) async {
    final trimmedName = name.trim();
    final parsedSize = double.tryParse(sizeValue.trim());

    if (trimmedName.isEmpty) {
      throw ArgumentError('Target name is required.');
    }

    if (parsedSize == null || parsedSize <= 0) {
      throw ArgumentError('Enter a valid target size.');
    }

    final existing = presetId == null ? null : _repository.presetById(presetId);
    final now = DateTime.now();
    final preset =
        existing?.copyWith(
          categoryId: categoryId,
          name: trimmedName,
          sizeValue: parsedSize,
          sizeUnit: sizeUnit,
          isCustom: true,
          updatedAt: now,
        ) ??
        TargetPreset(
          id: IdGenerator.generate(prefix: 'preset'),
          categoryId: categoryId,
          name: trimmedName,
          sizeValue: parsedSize,
          sizeUnit: sizeUnit,
          isCustom: true,
          createdAt: now,
          updatedAt: now,
        );

    await _repository.upsertPreset(preset);
  }

  Future<void> deletePreset(TargetPreset preset) async {
    await _repository.deletePreset(preset.id);
  }

  void _ensureCategorySelection() {
    if (categories.isEmpty) {
      selectedCategoryId.value = null;
      return;
    }

    final currentCategoryId = selectedCategoryId.value;
    if (currentCategoryId == null ||
        _repository.categoryById(currentCategoryId) == null) {
      selectedCategoryId.value = categories.first.id;
    }
  }
}
