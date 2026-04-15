class TargetMarker {
  const TargetMarker({
    required this.id,
    required this.label,
    required this.angle,
    required this.distance,
    required this.linkedRangeCardEntryId,
    required this.iconType,
    required this.notes,
  });

  final String id;
  final String label;
  final double angle;
  final double distance;
  final String? linkedRangeCardEntryId;
  final String iconType;
  final String notes;

  factory TargetMarker.fromJson(Map<String, dynamic> json) {
    return TargetMarker(
      id: json['id'] as String,
      label: json['label'] as String? ?? '',
      angle: (json['angle'] as num?)?.toDouble() ?? 90,
      distance: (json['distance'] as num?)?.toDouble() ?? 0,
      linkedRangeCardEntryId: json['linkedRangeCardEntryId'] as String?,
      iconType: json['iconType'] as String? ?? 'target',
      notes: json['notes'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'label': label,
      'angle': angle,
      'distance': distance,
      'linkedRangeCardEntryId': linkedRangeCardEntryId,
      'iconType': iconType,
      'notes': notes,
    };
  }

  TargetMarker copyWith({
    String? id,
    String? label,
    double? angle,
    double? distance,
    String? linkedRangeCardEntryId,
    String? iconType,
    String? notes,
  }) {
    return TargetMarker(
      id: id ?? this.id,
      label: label ?? this.label,
      angle: angle ?? this.angle,
      distance: distance ?? this.distance,
      linkedRangeCardEntryId:
          linkedRangeCardEntryId ?? this.linkedRangeCardEntryId,
      iconType: iconType ?? this.iconType,
      notes: notes ?? this.notes,
    );
  }
}
