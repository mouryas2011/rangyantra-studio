/// Represents common and custom video aspect ratios and canvas geometries.
class CanvasFormat {
  final String id;
  final String displayName;
  final int width;
  final int height;
  final int fps;

  const CanvasFormat({
    required this.id,
    required this.displayName,
    required this.width,
    required this.height,
    this.fps = 30,
  });

  double get aspectRatio => width / height;

  static const CanvasFormat landscape16_9 = CanvasFormat(
    id: '16_9',
    displayName: '16:9 Landscape (YouTube, Cinema)',
    width: 1920,
    height: 1080,
    fps: 30,
  );

  static const CanvasFormat portrait9_16 = CanvasFormat(
    id: '9_16',
    displayName: '9:16 Portrait (Reels, Shorts, TikTok)',
    width: 1080,
    height: 1920,
    fps: 30,
  );

  static const CanvasFormat square1_1 = CanvasFormat(
    id: '1_1',
    displayName: '1:1 Square (Instagram, Post)',
    width: 1080,
    height: 1080,
    fps: 30,
  );

  static const CanvasFormat portrait4_5 = CanvasFormat(
    id: '4_5',
    displayName: '4:5 Vertical (Instagram Feed)',
    width: 1080,
    height: 1350,
    fps: 30,
  );

  static const List<CanvasFormat> standardPresets = [
    portrait9_16,
    landscape16_9,
    square1_1,
    portrait4_5,
  ];

  static CanvasFormat fromId(String id, {int customW = 1080, int customH = 1920, int fps = 30}) {
    switch (id) {
      case '16_9':
        return landscape16_9.copyWith(fps: fps);
      case '9_16':
        return portrait9_16.copyWith(fps: fps);
      case '1_1':
        return square1_1.copyWith(fps: fps);
      case '4_5':
        return portrait4_5.copyWith(fps: fps);
      default:
        return CanvasFormat(
          id: id,
          displayName: 'Custom ($customW x $customH)',
          width: customW,
          height: customH,
          fps: fps,
        );
    }
  }

  CanvasFormat copyWith({
    String? id,
    String? displayName,
    int? width,
    int? height,
    int? fps,
  }) {
    return CanvasFormat(
      id: id ?? this.id,
      displayName: displayName ?? this.displayName,
      width: width ?? this.width,
      height: height ?? this.height,
      fps: fps ?? this.fps,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'displayName': displayName,
    'width': width,
    'height': height,
    'fps': fps,
  };

  factory CanvasFormat.fromJson(Map<String, dynamic> json) => CanvasFormat(
    id: json['id'] as String? ?? '9_16',
    displayName: json['displayName'] as String? ?? '9:16 Portrait',
    width: (json['width'] as num?)?.toInt() ?? 1080,
    height: (json['height'] as num?)?.toInt() ?? 1920,
    fps: (json['fps'] as num?)?.toInt() ?? 30,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CanvasFormat &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          width == other.width &&
          height == other.height &&
          fps == other.fps;

  @override
  int get hashCode => id.hashCode ^ width.hashCode ^ height.hashCode ^ fps.hashCode;

  @override
  String toString() => 'CanvasFormat($displayName, ${width}x$height, ${fps}fps)';
}
