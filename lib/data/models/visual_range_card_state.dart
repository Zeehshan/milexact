import 'package:milexact/data/models/target_marker.dart';
import 'package:milexact/data/models/terrain_item.dart';

class VisualRangeCardState {
  const VisualRangeCardState({
    required this.id,
    required this.linkedRangeCardEntryId,
    required this.arcLinesEnabled,
    required this.terrainItems,
    required this.targetMarkers,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String? linkedRangeCardEntryId;
  final bool arcLinesEnabled;
  final List<TerrainItem> terrainItems;
  final List<TargetMarker> targetMarkers;
  final DateTime createdAt;
  final DateTime updatedAt;

  factory VisualRangeCardState.fromJson(Map<String, dynamic> json) {
    final createdAt = DateTime.fromMillisecondsSinceEpoch(
      (json['createdAt'] as num?)?.toInt() ??
          DateTime.now().millisecondsSinceEpoch,
    );

    return VisualRangeCardState(
      id: json['id'] as String,
      linkedRangeCardEntryId: json['linkedRangeCardEntryId'] as String?,
      arcLinesEnabled: json['arcLinesEnabled'] as bool? ?? true,
      terrainItems: ((json['terrainItems'] as List?) ?? const <dynamic>[])
          .map(
            (raw) =>
                TerrainItem.fromJson(Map<String, dynamic>.from(raw as Map)),
          )
          .toList(growable: false),
      targetMarkers: ((json['targetMarkers'] as List?) ?? const <dynamic>[])
          .map(
            (raw) =>
                TargetMarker.fromJson(Map<String, dynamic>.from(raw as Map)),
          )
          .toList(growable: false),
      createdAt: createdAt,
      updatedAt: DateTime.fromMillisecondsSinceEpoch(
        (json['updatedAt'] as num?)?.toInt() ??
            createdAt.millisecondsSinceEpoch,
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'linkedRangeCardEntryId': linkedRangeCardEntryId,
      'arcLinesEnabled': arcLinesEnabled,
      'terrainItems': terrainItems
          .map((item) => item.toJson())
          .toList(growable: false),
      'targetMarkers': targetMarkers
          .map((marker) => marker.toJson())
          .toList(growable: false),
      'createdAt': createdAt.millisecondsSinceEpoch,
      'updatedAt': updatedAt.millisecondsSinceEpoch,
    };
  }

  VisualRangeCardState copyWith({
    String? id,
    String? linkedRangeCardEntryId,
    bool? arcLinesEnabled,
    List<TerrainItem>? terrainItems,
    List<TargetMarker>? targetMarkers,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return VisualRangeCardState(
      id: id ?? this.id,
      linkedRangeCardEntryId:
          linkedRangeCardEntryId ?? this.linkedRangeCardEntryId,
      arcLinesEnabled: arcLinesEnabled ?? this.arcLinesEnabled,
      terrainItems: terrainItems ?? this.terrainItems,
      targetMarkers: targetMarkers ?? this.targetMarkers,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
