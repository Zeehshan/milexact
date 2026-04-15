import 'package:milexact/data/models/enums.dart';

class AppSettings {
  const AppSettings({
    required this.defaultDisplayUnit,
    required this.defaultTargetUnit,
    required this.defaultReticleType,
    required this.liveCalculationEnabled,
  });

  final DistanceDisplayPreference defaultDisplayUnit;
  final UnitType defaultTargetUnit;
  final ReticleType defaultReticleType;
  final bool liveCalculationEnabled;

  factory AppSettings.defaults() {
    return const AppSettings(
      defaultDisplayUnit: DistanceDisplayPreference.both,
      defaultTargetUnit: UnitType.meter,
      defaultReticleType: ReticleType.mil,
      liveCalculationEnabled: true,
    );
  }

  factory AppSettings.fromJson(Map<String, dynamic> json) {
    final rawDisplayPreference =
        json['defaultDisplayUnit'] ?? json['defaultOutputPreference'];
    final rawTargetUnit = json['defaultTargetUnit'];
    final rawReticleType = json['defaultReticleType'];
    final rawLiveCalculation =
        json['liveCalculationEnabled'] ?? json['autoCalculateEnabled'];

    return AppSettings(
      defaultDisplayUnit: rawDisplayPreference is String
          ? DistanceDisplayPreference.values.byName(rawDisplayPreference)
          : DistanceDisplayPreference.both,
      defaultTargetUnit: rawTargetUnit is String
          ? UnitType.values.byName(rawTargetUnit)
          : UnitType.meter,
      defaultReticleType: rawReticleType is String
          ? ReticleType.values.byName(rawReticleType)
          : ReticleType.mil,
      liveCalculationEnabled: rawLiveCalculation is bool
          ? rawLiveCalculation
          : true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'defaultDisplayUnit': defaultDisplayUnit.name,
      'defaultTargetUnit': defaultTargetUnit.name,
      'defaultReticleType': defaultReticleType.name,
      'liveCalculationEnabled': liveCalculationEnabled,
    };
  }

  AppSettings copyWith({
    DistanceDisplayPreference? defaultDisplayUnit,
    UnitType? defaultTargetUnit,
    ReticleType? defaultReticleType,
    bool? liveCalculationEnabled,
  }) {
    return AppSettings(
      defaultDisplayUnit: defaultDisplayUnit ?? this.defaultDisplayUnit,
      defaultTargetUnit: defaultTargetUnit ?? this.defaultTargetUnit,
      defaultReticleType: defaultReticleType ?? this.defaultReticleType,
      liveCalculationEnabled:
          liveCalculationEnabled ?? this.liveCalculationEnabled,
    );
  }
}
