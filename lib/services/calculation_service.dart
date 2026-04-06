import 'package:get/get.dart';
import 'package:milexact/data/models/distance_result.dart';
import 'package:milexact/data/models/enums.dart';
import 'package:milexact/services/unit_conversion_service.dart';

class CalculationService extends GetxService {
  CalculationService(this._unitConversionService);

  static const double metricFormulaConstant = 1000.0;
  static const double imperialFormulaConstant = 1000.0;

  final UnitConversionService _unitConversionService;

  DistanceResult calculate({
    required MeasurementSystem measurementSystem,
    required double targetSizeValue,
    required MeasurementUnit targetUnit,
    required double reticleReading,
    required ReticleType reticleType,
    required DistanceOutputPreference outputPreference,
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

    return convertDistanceOutput(
      distanceMeters: distanceMeters,
      outputPreference: outputPreference,
    );
  }

  double calculateMetricDistance({
    required double targetSizeValue,
    required MeasurementUnit targetUnit,
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
    required MeasurementUnit targetUnit,
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

  DistanceResult convertDistanceOutput({
    required double distanceMeters,
    required DistanceOutputPreference outputPreference,
  }) {
    return DistanceResult(
      distanceMeters: distanceMeters,
      distanceYards: _unitConversionService.metersToYards(distanceMeters),
      outputPreference: outputPreference,
    );
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
