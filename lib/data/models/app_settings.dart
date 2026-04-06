import 'package:milexact/data/models/enums.dart';

class AppSettings {
  const AppSettings({
    required this.defaultOutputPreference,
    required this.defaultTargetUnit,
    required this.defaultReticleType,
    required this.autoCalculateEnabled,
  });

  final DistanceOutputPreference defaultOutputPreference;
  final MeasurementUnit defaultTargetUnit;
  final ReticleType defaultReticleType;
  final bool autoCalculateEnabled;

  factory AppSettings.defaults() {
    return const AppSettings(
      defaultOutputPreference: DistanceOutputPreference.both,
      defaultTargetUnit: MeasurementUnit.meter,
      defaultReticleType: ReticleType.mil,
      autoCalculateEnabled: true,
    );
  }

  factory AppSettings.fromJson(Map<String, dynamic> json) {
    return AppSettings(
      defaultOutputPreference: DistanceOutputPreference.values.byName(
        json['defaultOutputPreference'] as String,
      ),
      defaultTargetUnit: MeasurementUnit.values.byName(
        json['defaultTargetUnit'] as String,
      ),
      defaultReticleType: ReticleType.values.byName(
        json['defaultReticleType'] as String,
      ),
      autoCalculateEnabled: json['autoCalculateEnabled'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'defaultOutputPreference': defaultOutputPreference.name,
      'defaultTargetUnit': defaultTargetUnit.name,
      'defaultReticleType': defaultReticleType.name,
      'autoCalculateEnabled': autoCalculateEnabled,
    };
  }

  AppSettings copyWith({
    DistanceOutputPreference? defaultOutputPreference,
    MeasurementUnit? defaultTargetUnit,
    ReticleType? defaultReticleType,
    bool? autoCalculateEnabled,
  }) {
    return AppSettings(
      defaultOutputPreference:
          defaultOutputPreference ?? this.defaultOutputPreference,
      defaultTargetUnit: defaultTargetUnit ?? this.defaultTargetUnit,
      defaultReticleType: defaultReticleType ?? this.defaultReticleType,
      autoCalculateEnabled: autoCalculateEnabled ?? this.autoCalculateEnabled,
    );
  }
}
