import 'package:milexact/data/models/enums.dart';
import 'package:milexact/data/models/visual_point.dart';

class TerrainItem {
  const TerrainItem({
    required this.id,
    required this.type,
    required this.points,
    required this.label,
    required this.styleToken,
  });

  final String id;
  final TerrainType type;
  final List<VisualPoint> points;
  final String label;
  final String styleToken;

  factory TerrainItem.fromJson(Map<String, dynamic> json) {
    return TerrainItem(
      id: json['id'] as String,
      type: TerrainType.values.byName(
        (json['type'] as String?) ?? TerrainType.other.name,
      ),
      points: ((json['points'] as List?) ?? const <dynamic>[])
          .map(
            (raw) =>
                VisualPoint.fromJson(Map<String, dynamic>.from(raw as Map)),
          )
          .toList(growable: false),
      label: json['label'] as String? ?? '',
      styleToken: json['styleToken'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.name,
      'points': points.map((point) => point.toJson()).toList(growable: false),
      'label': label,
      'styleToken': styleToken,
    };
  }

  TerrainItem copyWith({
    String? id,
    TerrainType? type,
    List<VisualPoint>? points,
    String? label,
    String? styleToken,
  }) {
    return TerrainItem(
      id: id ?? this.id,
      type: type ?? this.type,
      points: points ?? this.points,
      label: label ?? this.label,
      styleToken: styleToken ?? this.styleToken,
    );
  }
}
