enum MeasurementUnit { millimeter, meter, inch, foot, yard }

extension MeasurementUnitX on MeasurementUnit {
  String get label => switch (this) {
    MeasurementUnit.millimeter => 'Millimeters',
    MeasurementUnit.meter => 'Meters',
    MeasurementUnit.inch => 'Inches',
    MeasurementUnit.foot => 'Feet',
    MeasurementUnit.yard => 'Yards',
  };

  String get shortLabel => switch (this) {
    MeasurementUnit.millimeter => 'mm',
    MeasurementUnit.meter => 'm',
    MeasurementUnit.inch => 'in',
    MeasurementUnit.foot => 'ft',
    MeasurementUnit.yard => 'yd',
  };

  bool get isMetric => switch (this) {
    MeasurementUnit.millimeter || MeasurementUnit.meter => true,
    MeasurementUnit.inch ||
    MeasurementUnit.foot ||
    MeasurementUnit.yard => false,
  };
}

enum MeasurementSystem { metric, imperial }

extension MeasurementSystemX on MeasurementSystem {
  String get label => switch (this) {
    MeasurementSystem.metric => 'Metric',
    MeasurementSystem.imperial => 'Imperial',
  };
}

enum ReticleType { mil, mrad }

extension ReticleTypeX on ReticleType {
  String get label => switch (this) {
    ReticleType.mil => 'MIL',
    ReticleType.mrad => 'MRAD',
  };
}

enum DistanceOutputPreference { meters, yards, both }

extension DistanceOutputPreferenceX on DistanceOutputPreference {
  String get label => switch (this) {
    DistanceOutputPreference.meters => 'Meters',
    DistanceOutputPreference.yards => 'Yards',
    DistanceOutputPreference.both => 'Both',
  };
}

enum TargetInputMode { preset, manual }

extension TargetInputModeX on TargetInputMode {
  String get label => switch (this) {
    TargetInputMode.preset => 'Preset',
    TargetInputMode.manual => 'Manual',
  };
}
