import 'package:get/get.dart';
import 'package:milexact/data/models/distance_result.dart';
import 'package:milexact/data/models/enums.dart';
import 'package:milexact/services/unit_conversion_service.dart';

class CalculationService extends GetxService {
  CalculationService(this._unitConversionService);

  static const double metricFormulaConstant = 1000.0;
  static const double imperialFormulaConstant = 1000.0;

  final UnitConversionService _unitConversionService;

  DistanceResult calculateDistance({
    required MeasurementSystem measurementSystem,
    required double targetSizeValue,
    required UnitType targetUnit,
    required double reticleReading,
    required ReticleType reticleType,
    required DistanceDisplayPreference displayPreference,
  }) {
    if (targetSizeValue <= 0) {
      throw const CalculationException(
        'Target size must be greater than zero.',
      );
    }

    if (reticleReading <= 0) {
      throw const CalculationException(
        'Reticle reading must be greater than zero.',
      );
    }

    final distanceMeters = switch (measurementSystem) {
      MeasurementSystem.metric => calculateMetricDistance(
        targetSizeValue: targetSizeValue,
        targetUnit: targetUnit,
        reticleReading: reticleReading,
        reticleType: reticleType,
      ),
      MeasurementSystem.imperial => _unitConversionService.yardsToMeters(
        calculateImperialDistance(
          targetSizeValue: targetSizeValue,
          targetUnit: targetUnit,
          reticleReading: reticleReading,
          reticleType: reticleType,
        ),
      ),
    };

    return convertDistanceForDisplay(
      distanceMeters: distanceMeters,
      displayPreference: displayPreference,
      formulaPreview: buildFormulaPreview(
        measurementSystem: measurementSystem,
        targetSizeValue: targetSizeValue,
        targetUnit: targetUnit,
        reticleReading: reticleReading,
        reticleType: reticleType,
      ),
      measurementSystem: measurementSystem,
    );
  }

  double calculateMetricDistance({
    required double targetSizeValue,
    required UnitType targetUnit,
    required double reticleReading,
    required ReticleType reticleType,
  }) {
    final sizeInMeters = _unitConversionService.toMeters(
      targetSizeValue,
      targetUnit,
    );
    return _solveDistance(
      targetSizeBase: sizeInMeters,
      reticleReading: reticleReading,
      formulaConstant: metricFormulaConstant,
      reticleFactor: _reticleFactor(reticleType),
    );
  }

  double calculateImperialDistance({
    required double targetSizeValue,
    required UnitType targetUnit,
    required double reticleReading,
    required ReticleType reticleType,
  }) {
    final sizeInYards = _unitConversionService.toYards(
      targetSizeValue,
      targetUnit,
    );
    return _solveDistance(
      targetSizeBase: sizeInYards,
      reticleReading: reticleReading,
      formulaConstant: imperialFormulaConstant,
      reticleFactor: _reticleFactor(reticleType),
    );
  }

  DistanceResult convertDistanceForDisplay({
    required double distanceMeters,
    required DistanceDisplayPreference displayPreference,
    required String formulaPreview,
    required MeasurementSystem measurementSystem,
  }) {
    return DistanceResult(
      distanceMeters: distanceMeters,
      distanceYards: _unitConversionService.metersToYards(distanceMeters),
      displayPreference: displayPreference,
      formulaPreview: formulaPreview,
      measurementSystem: measurementSystem,
    );
  }

  String buildFormulaPreview({
    required MeasurementSystem measurementSystem,
    required double targetSizeValue,
    required UnitType targetUnit,
    required double reticleReading,
    required ReticleType reticleType,
  }) {
    final constant = switch (measurementSystem) {
      MeasurementSystem.metric => metricFormulaConstant,
      MeasurementSystem.imperial => imperialFormulaConstant,
    };
    final unitLabel = switch (measurementSystem) {
      MeasurementSystem.metric => 'm',
      MeasurementSystem.imperial => 'yd',
    };

    return '(${targetSizeValue.toStringAsFixed(2)} ${targetUnit.shortLabel} × ${constant.toStringAsFixed(0)}) ÷ ${reticleReading.toStringAsFixed(2)} ${reticleType.label} = distance $unitLabel';
  }

  double _solveDistance({
    required double targetSizeBase,
    required double reticleReading,
    required double formulaConstant,
    required double reticleFactor,
  }) {
    return (targetSizeBase * formulaConstant * reticleFactor) / reticleReading;
  }

  double _reticleFactor(ReticleType reticleType) {
    return switch (reticleType) {
      ReticleType.mil => 1.0,
      ReticleType.mrad => 1.0,
    };
  }
}

class CalculationException implements Exception {
  const CalculationException(this.message);

  final String message;

  @override
  String toString() => message;
}
