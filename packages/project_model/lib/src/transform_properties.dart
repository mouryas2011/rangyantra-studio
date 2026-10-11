/// 2D geometric transformation properties for video, image, and text layers.
class TransformProperties {
  final double positionX; // Offset from canvas center in pixels
  final double positionY;
  final double scaleX;    // 1.0 = 100%
  final double scaleY;
  final double rotationDegrees; // 0 to 360
  final double opacity;   // 0.0 to 1.0
  final double anchorX;   // Normalized anchor 0.0 to 1.0 (default 0.5 center)
  final double anchorY;

  const TransformProperties({
    this.positionX = 0.0,
    this.positionY = 0.0,
    this.scaleX = 1.0,
    this.scaleY = 1.0,
    this.rotationDegrees = 0.0,
    this.opacity = 1.0,
    this.anchorX = 0.5,
    this.anchorY = 0.5,
  });

  static const TransformProperties identity = TransformProperties();

  TransformProperties copyWith({
    double? positionX,
    double? positionY,
    double? scaleX,
    double? scaleY,
    double? rotationDegrees,
    double? opacity,
    double? anchorX,
    double? anchorY,
  }) {
    return TransformProperties(
      positionX: positionX ?? this.positionX,
      positionY: positionY ?? this.positionY,
      scaleX: scaleX ?? this.scaleX,
      scaleY: scaleY ?? this.scaleY,
      rotationDegrees: rotationDegrees ?? this.rotationDegrees,
      opacity: opacity ?? this.opacity,
      anchorX: anchorX ?? this.anchorX,
      anchorY: anchorY ?? this.anchorY,
    );
  }

  Map<String, dynamic> toJson() => {
    'positionX': positionX,
    'positionY': positionY,
    'scaleX': scaleX,
    'scaleY': scaleY,
    'rotationDegrees': rotationDegrees,
    'opacity': opacity,
    'anchorX': anchorX,
    'anchorY': anchorY,
  };

  factory TransformProperties.fromJson(Map<String, dynamic> json) =>
      TransformProperties(
        positionX: (json['positionX'] as num?)?.toDouble() ?? 0.0,
        positionY: (json['positionY'] as num?)?.toDouble() ?? 0.0,
        scaleX: (json['scaleX'] as num?)?.toDouble() ?? 1.0,
        scaleY: (json['scaleY'] as num?)?.toDouble() ?? 1.0,
        rotationDegrees: (json['rotationDegrees'] as num?)?.toDouble() ?? 0.0,
        opacity: (json['opacity'] as num?)?.toDouble() ?? 1.0,
        anchorX: (json['anchorX'] as num?)?.toDouble() ?? 0.5,
        anchorY: (json['anchorY'] as num?)?.toDouble() ?? 0.5,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TransformProperties &&
          runtimeType == other.runtimeType &&
          positionX == other.positionX &&
          positionY == other.positionY &&
          scaleX == other.scaleX &&
          scaleY == other.scaleY &&
          rotationDegrees == other.rotationDegrees &&
          opacity == other.opacity &&
          anchorX == other.anchorX &&
          anchorY == other.anchorY;

  @override
  int get hashCode =>
      positionX.hashCode ^
      positionY.hashCode ^
      scaleX.hashCode ^
      scaleY.hashCode ^
      rotationDegrees.hashCode ^
      opacity.hashCode ^
      anchorX.hashCode ^
      anchorY.hashCode;
}
