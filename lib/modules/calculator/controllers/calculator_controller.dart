import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:milexact/app/routes/app_routes.dart';
import 'package:milexact/data/models/distance_result.dart';
import 'package:milexact/data/models/enums.dart';
import 'package:milexact/data/models/range_card_entry.dart';
import 'package:milexact/data/models/target_category.dart';
import 'package:milexact/data/models/target_preset.dart';
import 'package:milexact/data/repositories/presets_repository.dart';
import 'package:milexact/data/repositories/settings_repository.dart';
import 'package:milexact/services/calculation_service.dart';
import 'package:milexact/shared/utils/id_generator.dart';

class CalculatorController extends GetxController {
  CalculatorController(
    this._presetsRepository,
    this._settingsRepository,
    this._calculationService,
  );

  final PresetsRepository _presetsRepository;
  final SettingsRepository _settingsRepository;
  final CalculationService _calculationService;

  final manualTargetNameController = TextEditingController();
  final manualTargetSizeController = TextEditingController();
  final reticleReadingController = TextEditingController();

  final targetInputMode = TargetInputMode.preset.obs;
  final measurementSystem = MeasurementSystem.metric.obs;
  final selectedCategoryId = RxnString();
  final selectedPresetId = RxnString();
  final manualTargetName = ''.obs;
  final manualTargetSizeInput = ''.obs;
  final reticleReadingInput = ''.obs;
  final selectedTargetUnit = MeasurementUnit.meter.obs;
  final selectedReticleType = ReticleType.mil.obs;
  final outputPreference = DistanceOutputPreference.both.obs;
  final autoCalculateEnabled = true.obs;
  final result = Rxn<DistanceResult>();
  final errorMessage = ''.obs;

  RxList<TargetCategory> get categories => _presetsRepository.categories;

  bool get isPresetMode => targetInputMode.value == TargetInputMode.preset;

  List<TargetPreset> get availablePresets {
    final categoryId = selectedCategoryId.value;
    if (categoryId == null) {
      return const <TargetPreset>[];
    }
    return _presetsRepository.presetsForCategory(categoryId);
  }

  TargetPreset? get selectedPreset {
    final presetId = selectedPresetId.value;
    if (presetId == null) {
      return null;
    }
    return _presetsRepository.presetById(presetId);
  }

  String get activeTargetName {
    if (isPresetMode) {
      return selectedPreset?.name ?? 'Preset Target';
    }

    final label = manualTargetName.value.trim();
    return label.isEmpty ? 'Custom Target' : label;
  }

  MeasurementUnit get activeTargetUnit {
    if (isPresetMode) {
      return selectedPreset?.sizeUnit ?? selectedTargetUnit.value;
    }
    return selectedTargetUnit.value;
  }

  double? get activeTargetSizeValue {
    if (isPresetMode) {
      return selectedPreset?.sizeValue;
    }
    return double.tryParse(manualTargetSizeInput.value.trim());
  }

  double? get parsedReticleReading {
    return double.tryParse(reticleReadingInput.value.trim());
  }

  @override
  void onInit() {
    super.onInit();
    _applyDefaults();
    _bindTextControllers();
    _selectInitialPreset();
  }

  @override
  void onClose() {
    manualTargetNameController.dispose();
    manualTargetSizeController.dispose();
    reticleReadingController.dispose();
    super.onClose();
  }

  void setTargetInputMode(TargetInputMode mode) {
    targetInputMode.value = mode;
    _handleCalculationInputChange();
  }

  void setMeasurementSystem(MeasurementSystem system) {
    measurementSystem.value = system;
    _handleCalculationInputChange();
  }

  void setCategory(String categoryId) {
    selectedCategoryId.value = categoryId;
    final presets = availablePresets;
    selectedPresetId.value = presets.isEmpty ? null : presets.first.id;
    _handleCalculationInputChange();
  }

  void setPreset(String presetId) {
    selectedPresetId.value = presetId;
    _handleCalculationInputChange();
  }

  void setTargetUnit(MeasurementUnit unit) {
    selectedTargetUnit.value = unit;
    _handleCalculationInputChange();
  }

  void setReticleType(ReticleType reticleType) {
    selectedReticleType.value = reticleType;
    _handleCalculationInputChange();
  }

  void setOutputPreference(DistanceOutputPreference preference) {
    outputPreference.value = preference;
    if (result.value != null) {
      result.value = result.value!.copyWith(outputPreference: preference);
    }
  }

  void calculate({bool silent = false}) {
    final targetSize = activeTargetSizeValue;
    final reading = parsedReticleReading;

    if (isPresetMode && selectedPreset == null) {
      result.value = null;
      if (!silent) {
        errorMessage.value = 'Select a preset target.';
      }
      return;
    }

    if (targetSize == null || targetSize <= 0) {
      result.value = null;
      if (_shouldShowValidation(
        rawValue: manualTargetSizeInput.value,
        silent: silent,
        allowPresetModeMessage: true,
      )) {
        errorMessage.value = 'Enter a valid target size.';
      }
      return;
    }

    if (reading == null || reading <= 0) {
      result.value = null;
      if (_shouldShowValidation(
        rawValue: reticleReadingInput.value,
        silent: silent,
      )) {
        errorMessage.value = 'Enter a valid reticle reading.';
      }
      return;
    }

    try {
      result.value = _calculationService.calculate(
        measurementSystem: measurementSystem.value,
        targetSizeValue: targetSize,
        targetUnit: activeTargetUnit,
        reticleReading: reading,
        reticleType: selectedReticleType.value,
        outputPreference: outputPreference.value,
      );
      errorMessage.value = '';
    } on CalculationException catch (error) {
      result.value = null;
      if (!silent) {
        errorMessage.value = error.message;
      }
    }
  }

  void addToRangeCard() {
    if (result.value == null) {
      calculate();
    }

    final currentResult = result.value;
    final targetSize = activeTargetSizeValue;
    final reading = parsedReticleReading;

    if (currentResult == null || targetSize == null || reading == null) {
      return;
    }

    final now = DateTime.now();
    final entry = RangeCardEntry(
      id: IdGenerator.generate(prefix: 'range'),
      targetName: activeTargetName,
      targetSizeValue: targetSize,
      targetSizeUnit: activeTargetUnit,
      reticleReading: reading,
      reticleType: selectedReticleType.value,
      outputPreference: outputPreference.value,
      calculatedDistanceMeters: currentResult.distanceMeters,
      calculatedDistanceYards: currentResult.distanceYards,
      dope: '',
      windFull: '',
      windHalf: '',
      windQuarter: '',
      notes: '',
      createdAt: now,
      updatedAt: now,
    );

    Get.toNamed(AppRoutes.rangeCardEdit, arguments: entry);
  }

  void openRangeCard() => Get.toNamed(AppRoutes.rangeCardList);

  void openPresetManager() => Get.toNamed(AppRoutes.presetManager);

  void _applyDefaults() {
    final settings = _settingsRepository.settings.value;
    selectedTargetUnit.value = settings.defaultTargetUnit;
    selectedReticleType.value = settings.defaultReticleType;
    outputPreference.value = settings.defaultOutputPreference;
    autoCalculateEnabled.value = settings.autoCalculateEnabled;
    measurementSystem.value = settings.defaultTargetUnit.isMetric
        ? MeasurementSystem.metric
        : MeasurementSystem.imperial;
  }

  void _bindTextControllers() {
    manualTargetNameController.addListener(() {
      manualTargetName.value = manualTargetNameController.text;
    });
    manualTargetSizeController.addListener(() {
      manualTargetSizeInput.value = manualTargetSizeController.text;
      _handleCalculationInputChange();
    });
    reticleReadingController.addListener(() {
      reticleReadingInput.value = reticleReadingController.text;
      _handleCalculationInputChange();
    });
  }

  void _selectInitialPreset() {
    if (categories.isEmpty) {
      return;
    }

    selectedCategoryId.value = categories.first.id;
    final presets = availablePresets;
    if (presets.isNotEmpty) {
      selectedPresetId.value = presets.first.id;
    }
  }

  void _handleCalculationInputChange() {
    errorMessage.value = '';
    if (autoCalculateEnabled.value) {
      calculate(silent: true);
    } else {
      result.value = null;
    }
  }

  bool _shouldShowValidation({
    required String rawValue,
    required bool silent,
    bool allowPresetModeMessage = false,
  }) {
    if (!silent) {
      return true;
    }

    if (allowPresetModeMessage && isPresetMode) {
      return false;
    }

    return rawValue.trim().isNotEmpty;
  }
}
