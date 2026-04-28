import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:milexact/app/routes/app_routes.dart';
import 'package:milexact/data/models/distance_result.dart';
import 'package:milexact/data/models/enums.dart';
import 'package:milexact/data/models/range_card_entry.dart';
import 'package:milexact/data/models/target_category.dart';
import 'package:milexact/data/models/target_preset.dart';
import 'package:milexact/data/repositories/presets_repository.dart';
import 'package:milexact/data/repositories/settings_repository.dart';
import 'package:milexact/modules/app_shell/controllers/app_shell_controller.dart';
import 'package:milexact/services/calculation_service.dart';
import 'package:milexact/services/reticle_measurement_service.dart';
import 'package:milexact/shared/utils/formatters.dart';
import 'package:milexact/shared/utils/id_generator.dart';

class CalculatorController extends GetxController {
  static const double _minimumInteractionFraction = 0.006;
  static const double _minReticleZoom = 0.55;
  static const double _maxReticleZoom = 3.0;

  CalculatorController(
    this._presetsRepository,
    this._settingsRepository,
    this._calculationService,
    this._reticleMeasurementService,
  );

  final PresetsRepository _presetsRepository;
  final SettingsRepository _settingsRepository;
  final CalculationService _calculationService;
  final ReticleMeasurementService _reticleMeasurementService;

  final manualTargetNameController = TextEditingController();
  final manualTargetHeightController = TextEditingController();
  final manualTargetWidthController = TextEditingController();
  final reticleReadingController = TextEditingController();

  final targetInputMode = TargetInputMode.preset.obs;
  final referenceDimension = TargetDimensionType.height.obs;
  final measurementSystem = MeasurementSystem.metric.obs;
  final selectedCategoryId = RxnString();
  final selectedPresetId = RxnString();
  final selectedTargetUnit = UnitType.meter.obs;
  final selectedReticleType = ReticleType.mil.obs;
  final selectedReticleProfile = ReticleProfile.milHash05.obs;
  final displayPreference = DistanceDisplayPreference.both.obs;
  final liveCalculationEnabled = true.obs;
  final isMeasurementModeEnabled = false.obs;
  final reticleLineThickness = 1.2.obs;
  final reticleOverlayOpacity = 1.0.obs;
  final reticleZoom = 1.0.obs;
  final reticleHandleFraction = 0.12.obs;
  final verticalBaselineFraction =
      ReticleMeasurementService.zeroLineFraction.obs;
  final verticalMeasurementFraction =
      (ReticleMeasurementService.zeroLineFraction + 0.12).obs;
  final horizontalBaselineFraction =
      ReticleMeasurementService.zeroLineFraction.obs;
  final horizontalMeasurementFraction =
      (ReticleMeasurementService.zeroLineFraction + 0.12).obs;
  final manualTargetName = ''.obs;
  final manualTargetHeightInput = ''.obs;
  final manualTargetWidthInput = ''.obs;
  final reticleReadingInput = ''.obs;
  final result = Rxn<DistanceResult>();
  final errorMessage = ''.obs;
  final isReticleInteracting = false.obs;

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

  double? get activeHeightValue {
    if (isPresetMode) {
      return selectedPreset?.heightValue;
    }
    return double.tryParse(manualTargetHeightInput.value.trim());
  }

  UnitType get activeHeightUnit {
    if (isPresetMode) {
      return selectedPreset?.heightUnit ?? selectedTargetUnit.value;
    }
    return selectedTargetUnit.value;
  }

  double? get activeWidthValue {
    if (isPresetMode) {
      return selectedPreset?.widthValue;
    }
    return double.tryParse(manualTargetWidthInput.value.trim());
  }

  UnitType get activeWidthUnit {
    if (isPresetMode) {
      return selectedPreset?.widthUnit ?? selectedTargetUnit.value;
    }
    return selectedTargetUnit.value;
  }

  double? get activeTargetDimensionValue {
    return switch (referenceDimension.value) {
      TargetDimensionType.height => activeHeightValue,
      TargetDimensionType.width => activeWidthValue,
    };
  }

  UnitType get activeTargetDimensionUnit {
    return switch (referenceDimension.value) {
      TargetDimensionType.height => activeHeightUnit,
      TargetDimensionType.width => activeWidthUnit,
    };
  }

  bool get canSaveToRangeCard => result.value != null;

  double get activeBaselineFraction =>
      referenceDimension.value == TargetDimensionType.height
      ? verticalBaselineFraction.value
      : horizontalBaselineFraction.value;

  double get activeMeasurementFraction =>
      referenceDimension.value == TargetDimensionType.height
      ? verticalMeasurementFraction.value
      : horizontalMeasurementFraction.value;

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
    manualTargetHeightController.dispose();
    manualTargetWidthController.dispose();
    reticleReadingController.dispose();
    super.onClose();
  }

  void setTargetInputMode(TargetInputMode mode) {
    targetInputMode.value = mode;
    _syncMeasurementSystemFromActiveDimension();
    _handleCalculationInputChange();
  }

  void setReferenceDimension(TargetDimensionType dimension) {
    referenceDimension.value = dimension;
    _syncMeasurementSystemFromActiveDimension();
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
    _syncMeasurementSystemFromActiveDimension();
    _handleCalculationInputChange();
  }

  void setPreset(String presetId) {
    selectedPresetId.value = presetId;
    _syncMeasurementSystemFromActiveDimension();
    _handleCalculationInputChange();
  }

  void setTargetUnit(UnitType unit) {
    selectedTargetUnit.value = unit;
    measurementSystem.value = unit.isMetric
        ? MeasurementSystem.metric
        : MeasurementSystem.imperial;
    _handleCalculationInputChange();
  }

  void setReticleType(ReticleType reticleType) {
    selectedReticleType.value = reticleType;
    _handleCalculationInputChange();
  }

  void setMeasurementModeEnabled(bool isEnabled) {
    isMeasurementModeEnabled.value = isEnabled;
    if (!isEnabled) {
      isReticleInteracting.value = false;
    }
  }

  void setReticleLineThickness(double value) {
    reticleLineThickness.value = value.clamp(0.8, 3.0);
  }

  void setReticleOverlayOpacity(double value) {
    reticleOverlayOpacity.value = value.clamp(0.2, 1.0);
  }

  void adjustReticleOverlayOpacity(double delta) {
    setReticleOverlayOpacity(reticleOverlayOpacity.value + delta);
  }

  void setReticleZoom(double value) {
    reticleZoom.value = value.clamp(_minReticleZoom, _maxReticleZoom);
  }

  void adjustReticleZoom(double delta) {
    setReticleZoom(reticleZoom.value + delta);
  }

  void resetReticleMeasurement() {
    verticalBaselineFraction.value = ReticleMeasurementService.zeroLineFraction;
    horizontalBaselineFraction.value =
        ReticleMeasurementService.zeroLineFraction;

    const defaultReading = 1.0;
    final initialHandle = _reticleMeasurementService.handleFractionFromReading(
      defaultReading,
    );
    reticleHandleFraction.value = initialHandle;
    verticalMeasurementFraction.value =
        (verticalBaselineFraction.value + initialHandle).clamp(
          ReticleMeasurementService.minPositionFraction,
          ReticleMeasurementService.maxPositionFraction,
        );
    horizontalMeasurementFraction.value =
        (horizontalBaselineFraction.value + initialHandle).clamp(
          ReticleMeasurementService.minPositionFraction,
          ReticleMeasurementService.maxPositionFraction,
        );
    reticleReadingController.value = TextEditingValue(
      text: AppFormatters.number(defaultReading),
      selection: TextSelection.collapsed(
        offset: AppFormatters.number(defaultReading).length,
      ),
    );
    _handleCalculationInputChange();
  }

  void setReticleProfile(ReticleProfile profile) {
    selectedReticleProfile.value = profile;
  }

  void setDisplayPreference(DistanceDisplayPreference preference) {
    displayPreference.value = preference;
    if (result.value != null) {
      result.value = result.value!.copyWith(displayPreference: preference);
    }
  }

  Future<void> openQuickPresets() async {
    final selected = await Get.toNamed(
      AppRoutes.quickPresets,
      arguments: <String, dynamic>{
        'selectionMode': true,
        'selectedCategoryId': selectedCategoryId.value,
      },
    );

    if (selected is TargetPreset) {
      targetInputMode.value = TargetInputMode.preset;
      selectedCategoryId.value = selected.categoryId;
      selectedPresetId.value = selected.id;
      _syncMeasurementSystemFromActiveDimension();
      _handleCalculationInputChange();
    }
  }

  void openRangeCard() => _openShellTab(AppRoutes.rangeCardList);

  void openDopeProfiles() => _openShellTab(AppRoutes.dopeProfiles);

  void openVisualRangeCard() => _openShellTab(AppRoutes.visualRangeCard);

  void beginReticleInteraction({
    required Offset localPosition,
    required Size canvasSize,
  }) {
    updateReticleFromLocalPosition(
      localPosition: localPosition,
      canvasSize: canvasSize,
    );
  }

  void updateReticleBaselineFromLocalPosition({
    required Offset localPosition,
    required Size canvasSize,
  }) {
    if (referenceDimension.value == TargetDimensionType.height) {
      verticalBaselineFraction.value =
          ReticleMeasurementService.zeroLineFraction;
    } else {
      horizontalBaselineFraction.value =
          ReticleMeasurementService.zeroLineFraction;
    }
    updateReticleFromLocalPosition(
      localPosition: localPosition,
      canvasSize: canvasSize,
    );
  }

  void updateReticleFromLocalPosition({
    required Offset localPosition,
    required Size canvasSize,
  }) {
    final mainAxisPosition =
        referenceDimension.value == TargetDimensionType.height
        ? localPosition.dy
        : localPosition.dx;
    final mainAxisExtent =
        referenceDimension.value == TargetDimensionType.height
        ? canvasSize.height
        : canvasSize.width;

    final measurementFraction = _reticleMeasurementService
        .positionFractionFromLocalPosition(
          mainAxisPosition: mainAxisPosition,
          mainAxisExtent: mainAxisExtent,
        );

    if (referenceDimension.value == TargetDimensionType.height) {
      verticalMeasurementFraction.value = measurementFraction;
    } else {
      horizontalMeasurementFraction.value = measurementFraction;
    }

    final handleFraction = _reticleMeasurementService
        .handleFractionFromPositionFractions(
          baselineFraction: activeBaselineFraction,
          measurementFraction: measurementFraction,
        );
    if (handleFraction < _minimumInteractionFraction) {
      reticleHandleFraction.value = 0;
      reticleReadingController.value = const TextEditingValue(
        text: '',
        selection: TextSelection.collapsed(offset: 0),
      );
      return;
    }

    final reading = _reticleMeasurementService.readingFromPositionFractions(
      baselineFraction: activeBaselineFraction,
      measurementFraction: measurementFraction,
    );

    reticleHandleFraction.value = handleFraction;
    reticleReadingController.value = TextEditingValue(
      text: AppFormatters.number(reading),
      selection: TextSelection.collapsed(
        offset: AppFormatters.number(reading).length,
      ),
    );
  }

  void calculate({bool silent = false}) {
    final selectedDimensionValue = activeTargetDimensionValue;
    final reticleReading = double.tryParse(reticleReadingInput.value.trim());

    if (isPresetMode && selectedPreset == null) {
      result.value = null;
      if (!silent) {
        errorMessage.value = 'Select a quick preset.';
      }
      return;
    }

    if (selectedDimensionValue == null || selectedDimensionValue <= 0) {
      result.value = null;
      if (!silent || !_inputIsEmptyForSelectedDimension()) {
        errorMessage.value =
            'Enter a valid ${referenceDimension.value.label.toLowerCase()} value.';
      }
      return;
    }

    if (reticleReading == null || reticleReading <= 0) {
      result.value = null;
      if (!silent || reticleReadingInput.value.trim().isNotEmpty) {
        errorMessage.value = 'Enter a valid reticle reading.';
      }
      return;
    }

    try {
      result.value = _calculationService.calculateDistance(
        measurementSystem: measurementSystem.value,
        targetSizeValue: selectedDimensionValue,
        targetUnit: activeTargetDimensionUnit,
        reticleReading: reticleReading,
        reticleType: selectedReticleType.value,
        displayPreference: displayPreference.value,
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
    final height = activeHeightValue;
    final width = activeWidthValue;
    final reading = double.tryParse(reticleReadingInput.value.trim());

    if (currentResult == null ||
        height == null ||
        width == null ||
        reading == null) {
      return;
    }

    final now = DateTime.now();
    final entry = RangeCardEntry(
      id: IdGenerator.generate(prefix: 'range'),
      targetName: activeTargetName,
      targetHeightValue: height,
      targetHeightUnit: activeHeightUnit,
      targetWidthValue: width,
      targetWidthUnit: activeWidthUnit,
      reticleReading: reading,
      reticleType: selectedReticleType.value,
      displayPreference: displayPreference.value,
      distanceMeters: currentResult.distanceMeters,
      distanceYards: currentResult.distanceYards,
      dopeValue: '',
      selectedDopeProfileId: null,
      windValueType: WindValueType.none,
      windDirectionClock: '12',
      targetPlacementAngle: 90,
      targetPlacementLabel: '',
      terrainNotes: '',
      createdAt: now,
      updatedAt: now,
    );

    Get.toNamed(AppRoutes.rangeCardEdit, arguments: entry);
  }

  void _applyDefaults() {
    final settings = _settingsRepository.settings.value;
    selectedTargetUnit.value = settings.defaultTargetUnit;
    selectedReticleType.value = settings.defaultReticleType;
    displayPreference.value = settings.defaultDisplayUnit;
    liveCalculationEnabled.value = settings.liveCalculationEnabled;
    measurementSystem.value = settings.defaultTargetUnit.isMetric
        ? MeasurementSystem.metric
        : MeasurementSystem.imperial;
    reticleReadingController.text = '1.0';
    final initialHandle = _reticleMeasurementService.handleFractionFromReading(
      1.0,
    );
    reticleHandleFraction.value = initialHandle;
    verticalMeasurementFraction.value =
        (verticalBaselineFraction.value + initialHandle).clamp(
          ReticleMeasurementService.minPositionFraction,
          ReticleMeasurementService.maxPositionFraction,
        );
    horizontalMeasurementFraction.value =
        (horizontalBaselineFraction.value + initialHandle).clamp(
          ReticleMeasurementService.minPositionFraction,
          ReticleMeasurementService.maxPositionFraction,
        );
  }

  void _bindTextControllers() {
    manualTargetNameController.addListener(() {
      manualTargetName.value = manualTargetNameController.text;
    });
    manualTargetHeightController.addListener(() {
      manualTargetHeightInput.value = manualTargetHeightController.text;
      _handleCalculationInputChange();
    });
    manualTargetWidthController.addListener(() {
      manualTargetWidthInput.value = manualTargetWidthController.text;
      _handleCalculationInputChange();
    });
    reticleReadingController.addListener(() {
      reticleReadingInput.value = reticleReadingController.text;
      final reading = double.tryParse(reticleReadingInput.value.trim());
      if (reading != null && reading > 0) {
        reticleHandleFraction.value = _reticleMeasurementService
            .handleFractionFromReading(reading);
        _syncMeasurementFractionFromReading(reading);
      }
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

  void _syncMeasurementSystemFromActiveDimension() {
    measurementSystem.value = activeTargetDimensionUnit.isMetric
        ? MeasurementSystem.metric
        : MeasurementSystem.imperial;
  }

  void _handleCalculationInputChange() {
    errorMessage.value = '';
    if (liveCalculationEnabled.value) {
      calculate(silent: true);
    } else {
      result.value = null;
    }
  }

  void _syncMeasurementFractionFromReading(double reading) {
    final measurementFraction = _reticleMeasurementService
        .measurementFractionFromBaselineAndReading(
          baselineFraction: activeBaselineFraction,
          reading: reading,
          preferPositiveDirection:
              activeMeasurementFraction >= activeBaselineFraction,
        );

    if (referenceDimension.value == TargetDimensionType.height) {
      verticalMeasurementFraction.value = measurementFraction;
    } else {
      horizontalMeasurementFraction.value = measurementFraction;
    }
  }

  bool _inputIsEmptyForSelectedDimension() {
    return switch (referenceDimension.value) {
      TargetDimensionType.height =>
        manualTargetHeightInput.value.trim().isEmpty,
      TargetDimensionType.width => manualTargetWidthInput.value.trim().isEmpty,
    };
  }

  void setReticleInteractionActive(bool isActive) {
    if (!isMeasurementModeEnabled.value && isActive) {
      return;
    }
    if (isReticleInteracting.value == isActive) {
      return;
    }
    isReticleInteracting.value = isActive;
  }

  void _openShellTab(String route) {
    if (Get.isRegistered<AppShellController>()) {
      Get.find<AppShellController>().selectRoute(route);
      return;
    }
    Get.toNamed(AppRoutes.home, arguments: route);
  }
}
