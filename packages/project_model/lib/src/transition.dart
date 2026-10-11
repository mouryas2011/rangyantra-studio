enum TransitionType {
  crossDissolve,
  fadeIn,
  fadeOut,
  wipeRight,
  slideLeft,
  zoomIn,
}

/// Video and audio transition model.
class Transition {
  final String id;
  final TransitionType type;
  final int durationMicroseconds; // standard 500,000us = 0.5s

  const Transition({
    required this.id,
    required this.type,
    this.durationMicroseconds = 500000,
  });

  Transition copyWith({
    String? id,
    TransitionType? type,
    int? durationMicroseconds,
  }) {
    return Transition(
      id: id ?? this.id,
      type: type ?? this.type,
      durationMicroseconds: durationMicroseconds ?? this.durationMicroseconds,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'type': type.name,
    'durationMicroseconds': durationMicroseconds,
  };

  factory Transition.fromJson(Map<String, dynamic> json) => Transition(
    id: json['id'] as String,
    type: TransitionType.values.firstWhere(
      (t) => t.name == json['type'],
      orElse: () => TransitionType.crossDissolve,
    ),
    durationMicroseconds: (json['durationMicroseconds'] as num?)?.toInt() ?? 500000,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Transition &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          type == other.type &&
          durationMicroseconds == other.durationMicroseconds;

  @override
  int get hashCode => id.hashCode ^ type.hashCode ^ durationMicroseconds.hashCode;
}
