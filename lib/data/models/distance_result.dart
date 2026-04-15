import 'package:milexact/data/models/enums.dart';

class DistanceResult {
  const DistanceResult({
    required this.distanceMeters,
    required this.distanceYards,
    required this.displayPreference,
    required this.formulaPreview,
    required this.measurementSystem,
  });

  final double distanceMeters;
  final double distanceYards;
  final DistanceDisplayPreference displayPreference;
  final String formulaPreview;
  final MeasurementSystem measurementSystem;

  bool get showsMeters => displayPreference != DistanceDisplayPreference.yards;
  bool get showsYards => displayPreference != DistanceDisplayPreference.meters;

  DistanceResult copyWith({
    double? distanceMeters,
    double? distanceYards,
    DistanceDisplayPreference? displayPreference,
    String? formulaPreview,
    MeasurementSystem? measurementSystem,
  }) {
    return DistanceResult(
      distanceMeters: distanceMeters ?? this.distanceMeters,
      distanceYards: distanceYards ?? this.distanceYards,
      displayPreference: displayPreference ?? this.displayPreference,
      formulaPreview: formulaPreview ?? this.formulaPreview,
      measurementSystem: measurementSystem ?? this.measurementSystem,
    );
  }
}
