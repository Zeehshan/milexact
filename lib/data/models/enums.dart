enum UnitType { millimeter, meter, inch, foot, yard }

extension UnitTypeX on UnitType {
  String get label => switch (this) {
    UnitType.millimeter => 'Millimeters',
    UnitType.meter => 'Meters',
    UnitType.inch => 'Inches',
    UnitType.foot => 'Feet',
    UnitType.yard => 'Yards',
  };

  String get shortLabel => switch (this) {
    UnitType.millimeter => 'mm',
    UnitType.meter => 'm',
    UnitType.inch => 'in',
    UnitType.foot => 'ft',
    UnitType.yard => 'yd',
  };

  bool get isMetric => switch (this) {
    UnitType.millimeter || UnitType.meter => true,
    UnitType.inch || UnitType.foot || UnitType.yard => false,
  };

  bool get isImperial => !isMetric;
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

enum ReticleProfile { milDot, christmasTree, duplex, simpleCrosshair }

extension ReticleProfileX on ReticleProfile {
  String get label => switch (this) {
    ReticleProfile.milDot => 'Mil-Dot',
    ReticleProfile.christmasTree => 'Christmas Tree',
    ReticleProfile.duplex => 'Duplex',
    ReticleProfile.simpleCrosshair => 'Simple Crosshair',
  };

  String get description => switch (this) {
    ReticleProfile.milDot => 'Classic military dot reticle',
    ReticleProfile.christmasTree => 'Tree hold pattern with lower stadia',
    ReticleProfile.duplex => 'Thick-to-thin post reticle',
    ReticleProfile.simpleCrosshair => 'Basic fine crosshair',
  };

  String get heightGuide => switch (this) {
    ReticleProfile.milDot => '1, 2, 3, 4, 5',
    ReticleProfile.christmasTree => '2-16 rows',
    ReticleProfile.duplex => 'post gap ~2.5',
    ReticleProfile.simpleCrosshair => '1, 2, 3, 4, 5',
  };

  String get widthGuide => switch (this) {
    ReticleProfile.milDot => '1, 2, 3, 4, 5',
    ReticleProfile.christmasTree => '±1-8.5 dots',
    ReticleProfile.duplex => 'post gap ~2.5',
    ReticleProfile.simpleCrosshair => '1, 2, 3, 4, 5',
  };

  String guideLabel({
    required TargetDimensionType dimension,
    required ReticleType reticleType,
  }) {
    final prefix = dimension == TargetDimensionType.height ? 'H' : 'W';
    final values = dimension == TargetDimensionType.height
        ? heightGuide
        : widthGuide;
    return '$prefix: $values ${reticleType.label}';
  }
}

enum DistanceDisplayPreference { meters, yards, both }

extension DistanceDisplayPreferenceX on DistanceDisplayPreference {
  String get label => switch (this) {
    DistanceDisplayPreference.meters => 'Meters',
    DistanceDisplayPreference.yards => 'Yards',
    DistanceDisplayPreference.both => 'Both',
  };
}

enum WindValueType { none, quarter, half, full }

extension WindValueTypeX on WindValueType {
  String get label => switch (this) {
    WindValueType.none => 'No Value',
    WindValueType.quarter => 'Quarter',
    WindValueType.half => 'Half',
    WindValueType.full => 'Full',
  };
}

enum TerrainType { river, treeline, road, building, other }

extension TerrainTypeX on TerrainType {
  String get label => switch (this) {
    TerrainType.river => 'River',
    TerrainType.treeline => 'Treeline',
    TerrainType.road => 'Road',
    TerrainType.building => 'Building',
    TerrainType.other => 'Other',
  };
}

enum TargetInputMode { preset, manual }

extension TargetInputModeX on TargetInputMode {
  String get label => switch (this) {
    TargetInputMode.preset => 'Quick Preset',
    TargetInputMode.manual => 'Manual',
  };
}

enum TargetDimensionType { height, width }

extension TargetDimensionTypeX on TargetDimensionType {
  String get label => switch (this) {
    TargetDimensionType.height => 'Height',
    TargetDimensionType.width => 'Width',
  };
}

enum VisualEditorMode { marker, river, treeline, road, building, other }

extension VisualEditorModeX on VisualEditorMode {
  String get label => switch (this) {
    VisualEditorMode.marker => 'Marker',
    VisualEditorMode.river => 'River',
    VisualEditorMode.treeline => 'Treeline',
    VisualEditorMode.road => 'Road',
    VisualEditorMode.building => 'Building',
    VisualEditorMode.other => 'Other',
  };

  bool get isTerrain => this != VisualEditorMode.marker;

  TerrainType? get terrainType => switch (this) {
    VisualEditorMode.marker => null,
    VisualEditorMode.river => TerrainType.river,
    VisualEditorMode.treeline => TerrainType.treeline,
    VisualEditorMode.road => TerrainType.road,
    VisualEditorMode.building => TerrainType.building,
    VisualEditorMode.other => TerrainType.other,
  };
}
