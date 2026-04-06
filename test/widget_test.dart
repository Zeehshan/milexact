import 'package:flutter_test/flutter_test.dart';
import 'package:milexact/data/models/enums.dart';
import 'package:milexact/services/calculation_service.dart';
import 'package:milexact/services/unit_conversion_service.dart';

void main() {
  group('CalculationService', () {
    final service = CalculationService(UnitConversionService());

    test('solves metric workflow in meters and yards', () {
      final result = service.calculate(
        measurementSystem: MeasurementSystem.metric,
        targetSizeValue: 1.0,
        targetUnit: MeasurementUnit.meter,
        reticleReading: 2.0,
        reticleType: ReticleType.mil,
        outputPreference: DistanceOutputPreference.both,
      );

      expect(result.distanceMeters, closeTo(500, 0.0001));
      expect(result.distanceYards, closeTo(546.8066, 0.001));
    });

    test('solves imperial workflow in yards', () {
      final result = service.calculate(
        measurementSystem: MeasurementSystem.imperial,
        targetSizeValue: 36,
        targetUnit: MeasurementUnit.inch,
        reticleReading: 4.0,
        reticleType: ReticleType.mrad,
        outputPreference: DistanceOutputPreference.yards,
      );

      expect(result.distanceYards, closeTo(250, 0.0001));
      expect(result.distanceMeters, closeTo(228.6, 0.001));
    });

    test('throws when reticle reading is zero', () {
      expect(
        () => service.calculate(
          measurementSystem: MeasurementSystem.metric,
          targetSizeValue: 1.0,
          targetUnit: MeasurementUnit.meter,
          reticleReading: 0,
          reticleType: ReticleType.mil,
          outputPreference: DistanceOutputPreference.meters,
        ),
        throwsA(isA<CalculationException>()),
      );
    });
  });
}
