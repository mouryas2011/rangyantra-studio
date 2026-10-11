enum InterpolationCurve {
  linear,
  easeIn,
  easeOut,
  easeInOut,
}

/// A keyframe on a specific clip transform or effect parameter.
class Keyframe {
  final String id;
  final String property; // e.g. 'positionX', 'scale', 'opacity', 'rotation'
  final int timestampMicroseconds; // Offset relative to clip start
  final double value;
  final InterpolationCurve curve;

  const Keyframe({
    required this.id,
    required this.property,
    required this.timestampMicroseconds,
    required this.value,
    this.curve = InterpolationCurve.linear,
  });

  Keyframe copyWith({
    String? id,
    String? property,
    int? timestampMicroseconds,
    double? value,
    InterpolationCurve? curve,
  }) {
    return Keyframe(
      id: id ?? this.id,
      property: property ?? this.property,
      timestampMicroseconds: timestampMicroseconds ?? this.timestampMicroseconds,
      value: value ?? this.value,
      curve: curve ?? this.curve,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'property': property,
    'timestampMicroseconds': timestampMicroseconds,
    'value': value,
    'curve': curve.name,
  };

  factory Keyframe.fromJson(Map<String, dynamic> json) => Keyframe(
    id: json['id'] as String,
    property: json['property'] as String,
    timestampMicroseconds: (json['timestampMicroseconds'] as num).toInt(),
    value: (json['value'] as num).toDouble(),
    curve: InterpolationCurve.values.firstWhere(
      (c) => c.name == json['curve'],
      orElse: () => InterpolationCurve.linear,
    ),
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Keyframe &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          property == other.property &&
          timestampMicroseconds == other.timestampMicroseconds &&
          value == other.value &&
          curve == other.curve;

  @override
  int get hashCode =>
      id.hashCode ^
      property.hashCode ^
      timestampMicroseconds.hashCode ^
      value.hashCode ^
      curve.hashCode;
}
