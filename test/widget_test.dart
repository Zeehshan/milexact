import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:milexact/data/models/enums.dart';
import 'package:milexact/services/calculation_service.dart';
import 'package:milexact/services/reticle_measurement_service.dart';
import 'package:milexact/services/unit_conversion_service.dart';
import 'package:milexact/services/visual_range_card_service.dart';

void main() {
  group('CalculationService', () {
    final service = CalculationService(UnitConversionService());

    test('solves metric workflow in meters and yards', () {
      final result = service.calculateDistance(
        measurementSystem: MeasurementSystem.metric,
        targetSizeValue: 1.0,
        targetUnit: UnitType.meter,
        reticleReading: 2.0,
        reticleType: ReticleType.mil,
        displayPreference: DistanceDisplayPreference.both,
      );

      expect(result.distanceMeters, closeTo(500, 0.0001));
      expect(result.distanceYards, closeTo(546.8066, 0.001));
    });

    test('solves imperial workflow in yards', () {
      final result = service.calculateDistance(
        measurementSystem: MeasurementSystem.imperial,
        targetSizeValue: 36,
        targetUnit: UnitType.inch,
        reticleReading: 4.0,
        reticleType: ReticleType.mrad,
        displayPreference: DistanceDisplayPreference.yards,
      );

      expect(result.distanceYards, closeTo(250, 0.0001));
      expect(result.distanceMeters, closeTo(228.6, 0.001));
    });

    test('throws when reticle reading is zero', () {
      expect(
        () => service.calculateDistance(
          measurementSystem: MeasurementSystem.metric,
          targetSizeValue: 1.0,
          targetUnit: UnitType.meter,
          reticleReading: 0,
          reticleType: ReticleType.mil,
          displayPreference: DistanceDisplayPreference.meters,
        ),
        throwsA(isA<CalculationException>()),
      );
    });
  });

  group('ReticleMeasurementService', () {
    final service = ReticleMeasurementService();

    test('converts reading to handle fraction and back within range', () {
      final fraction = service.handleFractionFromReading(3.2);
      final reading = service.readingFromHandleFraction(fraction);

      expect(fraction, inInclusiveRange(0.04, 0.46));
      expect(reading, closeTo(3.2, 0.2));
    });
  });

  group('VisualRangeCardService', () {
    final service = VisualRangeCardService();

    test('converts marker position to and from offsets in semicircle', () {
      const size = Size(320, 320);
      final marker = service.markerFromOffset(
        id: 'm1',
        label: 'Target',
        localPosition: const Offset(160, 80),
        size: size,
      );
      final offset = service.offsetFromMarker(marker: marker, size: size);

      expect(marker.angle, closeTo(90, 2));
      expect(offset.dx, closeTo(160, 4));
      expect(offset.dy, lessThan(300));
    });
  });
}
