import 'dart:math' as math;

import 'package:get/get.dart';

class ReticleMeasurementService extends GetxService {
  static const double minReading = 0.1;
  static const double maxReading = 20.0;
  static const double maxHandleFraction = 0.46;
  static const double zeroLineFraction = 0.63;
  static const double minPositionFraction = 0.04;
  static const double maxPositionFraction = 0.96;

  double clampReading(double reading) {
    return reading.clamp(minReading, maxReading);
  }

  double readingFromHandleFraction(double handleFraction) {
    final clamped = handleFraction.clamp(0.0, maxHandleFraction);
    return clampReading((clamped / maxHandleFraction) * maxReading);
  }

  double handleFractionFromReading(double reading) {
    final clamped = clampReading(reading);
    return ((clamped / maxReading) * maxHandleFraction).clamp(
      0.0,
      maxHandleFraction,
    );
  }

  double handleFractionFromLocalPosition({
    required double mainAxisPosition,
    required double mainAxisExtent,
    bool oneSidedFromCenter = false,
  }) {
    final normalized = oneSidedFromCenter
        ? _handleFractionFromBaselinePosition(
            mainAxisPosition: mainAxisPosition,
            mainAxisExtent: mainAxisExtent,
          )
        : _handleFractionFromCenteredPosition(
            mainAxisPosition: mainAxisPosition,
            mainAxisExtent: mainAxisExtent,
          );
    return normalized.clamp(0.0, maxHandleFraction);
  }

  double positionFractionFromLocalPosition({
    required double mainAxisPosition,
    required double mainAxisExtent,
  }) {
    if (mainAxisExtent <= 0) {
      return 0.5;
    }
    return (mainAxisPosition / mainAxisExtent).clamp(
      minPositionFraction,
      maxPositionFraction,
    );
  }

  double readingFromPositionFractions({
    required double baselineFraction,
    required double measurementFraction,
  }) {
    final delta = (measurementFraction - baselineFraction).abs();
    return readingFromHandleFraction(delta);
  }

  double measurementFractionFromBaselineAndReading({
    required double baselineFraction,
    required double reading,
    bool preferPositiveDirection = true,
  }) {
    final delta = handleFractionFromReading(reading);
    final forward = (baselineFraction + delta).clamp(
      minPositionFraction,
      maxPositionFraction,
    );
    final backward = (baselineFraction - delta).clamp(
      minPositionFraction,
      maxPositionFraction,
    );

    if (preferPositiveDirection) {
      if ((forward - baselineFraction).abs() >= delta * 0.7) {
        return forward;
      }
      return backward;
    }

    if ((backward - baselineFraction).abs() >= delta * 0.7) {
      return backward;
    }
    return forward;
  }

  double _handleFractionFromCenteredPosition({
    required double mainAxisPosition,
    required double mainAxisExtent,
  }) {
    final center = mainAxisExtent / 2;
    return (mainAxisPosition - center).abs() / mainAxisExtent;
  }

  double _handleFractionFromBaselinePosition({
    required double mainAxisPosition,
    required double mainAxisExtent,
  }) {
    final baseline = mainAxisExtent * zeroLineFraction;
    final availableExtent = (mainAxisExtent - baseline).clamp(
      1.0,
      double.infinity,
    );
    final normalized =
        ((mainAxisPosition - baseline).clamp(0.0, availableExtent) /
            availableExtent) *
        maxHandleFraction;
    return normalized;
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
