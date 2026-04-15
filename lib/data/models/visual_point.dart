class VisualPoint {
  const VisualPoint({required this.x, required this.y});

  final double x;
  final double y;

  factory VisualPoint.fromJson(Map<String, dynamic> json) {
    return VisualPoint(
      x: (json['x'] as num?)?.toDouble() ?? 0,
      y: (json['y'] as num?)?.toDouble() ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {'x': x, 'y': y};

  VisualPoint copyWith({double? x, double? y}) {
    return VisualPoint(x: x ?? this.x, y: y ?? this.y);
  }
}
