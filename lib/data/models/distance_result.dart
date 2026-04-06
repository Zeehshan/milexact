import 'package:milexact/data/models/enums.dart';

class DistanceResult {
  const DistanceResult({
    required this.distanceMeters,
    required this.distanceYards,
    required this.outputPreference,
  });

  final double distanceMeters;
  final double distanceYards;
  final DistanceOutputPreference outputPreference;

  bool get showsMeters => outputPreference != DistanceOutputPreference.yards;
  bool get showsYards => outputPreference != DistanceOutputPreference.meters;

  DistanceResult copyWith({
    double? distanceMeters,
    double? distanceYards,
    DistanceOutputPreference? outputPreference,
  }) {
    return DistanceResult(
      distanceMeters: distanceMeters ?? this.distanceMeters,
      distanceYards: distanceYards ?? this.distanceYards,
      outputPreference: outputPreference ?? this.outputPreference,
    );
  }
}
