import 'package:get/get.dart';
import 'package:milexact/data/models/enums.dart';
import 'package:milexact/data/models/target_category.dart';
import 'package:milexact/data/models/target_preset.dart';
import 'package:milexact/data/repositories/presets_repository.dart';
import 'package:milexact/shared/utils/id_generator.dart';

class QuickPresetController extends GetxController {
  QuickPresetController(this._repository);

  final PresetsRepository _repository;
  final selectedCategoryId = RxnString();
  final searchQuery = ''.obs;
  final selectionMode = false.obs;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    if (args is Map<String, dynamic>) {
      selectionMode.value = args['selectionMode'] == true;
      selectedCategoryId.value = args['selectedCategoryId'] as String?;
    }
    _ensureCategorySelection();
  }

  RxList<TargetCategory> get categories => _repository.categories;

  TargetCategory? get selectedCategory {
    final id = selectedCategoryId.value;
    if (id == null) {
      return null;
    }
    return _repository.categoryById(id);
  }

  List<TargetPreset> get filteredPresets {
    final categoryId = selectedCategoryId.value;
    if (categoryId == null) {
      return const <TargetPreset>[];
    }

    final query = searchQuery.value.trim().toLowerCase();
    final presets = _repository.presetsForCategory(categoryId);
    if (query.isEmpty) {
      return presets;
    }

    return presets
        .where((preset) {
          return preset.name.toLowerCase().contains(query);
        })
        .toList(growable: false);
  }

  void selectCategory(String categoryId) {
    selectedCategoryId.value = categoryId;
  }

  void setSearchQuery(String value) {
    searchQuery.value = value;
  }

  Future<void> saveCategory({String? categoryId, required String name}) async {
    final trimmed = name.trim();
    if (trimmed.isEmpty) {
      throw ArgumentError('Category name is required.');
    }

    final existing = categoryId == null
        ? null
        : _repository.categoryById(categoryId);
    final now = DateTime.now();
    final category =
        existing?.copyWith(name: trimmed, updatedAt: now) ??
        TargetCategory(
          id: IdGenerator.generate(prefix: 'category'),
          name: trimmed,
          createdAt: now,
          updatedAt: now,
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
    required String heightValue,
    required UnitType heightUnit,
    required String widthValue,
    required UnitType widthUnit,
    required bool supportsMetric,
    required bool supportsImperial,
  }) async {
    final trimmedName = name.trim();
    final parsedHeight = double.tryParse(heightValue.trim());
    final parsedWidth = double.tryParse(widthValue.trim());

    if (trimmedName.isEmpty) {
      throw ArgumentError('Preset name is required.');
    }
    if (parsedHeight == null || parsedHeight <= 0) {
      throw ArgumentError('Enter a valid height.');
    }
    if (parsedWidth == null || parsedWidth <= 0) {
      throw ArgumentError('Enter a valid width.');
    }
    if (!supportsMetric && !supportsImperial) {
      throw ArgumentError('Enable metric, imperial, or both.');
    }

    final existing = presetId == null ? null : _repository.presetById(presetId);
    final now = DateTime.now();
    final preset =
        existing?.copyWith(
          categoryId: categoryId,
          name: trimmedName,
          heightValue: parsedHeight,
          heightUnit: heightUnit,
          widthValue: parsedWidth,
          widthUnit: widthUnit,
          supportsMetric: supportsMetric,
          supportsImperial: supportsImperial,
          isCustom: true,
          updatedAt: now,
        ) ??
        TargetPreset(
          id: IdGenerator.generate(prefix: 'preset'),
          categoryId: categoryId,
          name: trimmedName,
          heightValue: parsedHeight,
          heightUnit: heightUnit,
          widthValue: parsedWidth,
          widthUnit: widthUnit,
          supportsMetric: supportsMetric,
          supportsImperial: supportsImperial,
          isCustom: true,
          createdAt: now,
          updatedAt: now,
        );

    await _repository.upsertPreset(preset);
  }

  Future<void> deletePreset(TargetPreset preset) async {
    await _repository.deletePreset(preset.id);
  }

  void usePreset(TargetPreset preset) {
    Get.back(result: preset);
  }

  void _ensureCategorySelection() {
    if (categories.isEmpty) {
      selectedCategoryId.value = null;
      return;
    }

    final currentId = selectedCategoryId.value;
    if (currentId == null || _repository.categoryById(currentId) == null) {
      selectedCategoryId.value = categories.first.id;
    }
  }
}
