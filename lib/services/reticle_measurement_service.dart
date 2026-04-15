import 'dart:math' as math;

import 'package:get/get.dart';

class ReticleMeasurementService extends GetxService {
  static const double minReading = 0.1;
  static const double maxReading = 20.0;

  double clampReading(double reading) {
    return reading.clamp(minReading, maxReading);
  }

  double readingFromHandleFraction(double handleFraction) {
    final clamped = handleFraction.clamp(0.04, 0.46);
    return clampReading(clamped * maxReading * 2.2);
  }

  double handleFractionFromReading(double reading) {
    final clamped = clampReading(reading);
    return (clamped / (maxReading * 2.2)).clamp(0.04, 0.46);
  }

  double handleFractionFromLocalPosition({
    required double mainAxisPosition,
    required double mainAxisExtent,
  }) {
    final center = mainAxisExtent / 2;
    final distanceFromCenter = (mainAxisPosition - center).abs();
    final normalized = distanceFromCenter / mainAxisExtent;
    return normalized.clamp(0.04, 0.46);
  }

  double markerHitDistance({
    required double x1,
    required double y1,
    required double x2,
    required double y2,
  }) {
    final dx = x1 - x2;
    final dy = y1 - y2;
    return math.sqrt((dx * dx) + (dy * dy));
  }
}
