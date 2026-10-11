import 'clip.dart';

enum TrackType {
  video,
  audio,
  text,
  overlay,
}

/// Represents a distinct media lane on the multitrack editing timeline.
class Track {
  final String id;
  final String name;
  final TrackType type;
  final bool isMuted;
  final bool isLocked;
  final bool isVisible;
  final double volume; // 0.0 to 2.0
  final int orderIndex;
  final List<Clip> clips;

  const Track({
    required this.id,
    required this.name,
    required this.type,
    this.isMuted = false,
    this.isLocked = false,
    this.isVisible = true,
    this.volume = 1.0,
    required this.orderIndex,
    this.clips = const [],
  });

  /// Total duration of this track in microseconds (highest clip endpoint).
  int get durationUs {
    if (clips.isEmpty) return 0;
    int maxEnd = 0;
    for (final clip in clips) {
      if (clip.timelineEndUs > maxEnd) {
        maxEnd = clip.timelineEndUs;
      }
    }
    return maxEnd;
  }

  Track copyWith({
    String? id,
    String? name,
    TrackType? type,
    bool? isMuted,
    bool? isLocked,
    bool? isVisible,
    double? volume,
    int? orderIndex,
    List<Clip>? clips,
  }) {
    return Track(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      isMuted: isMuted ?? this.isMuted,
      isLocked: isLocked ?? this.isLocked,
      isVisible: isVisible ?? this.isVisible,
      volume: volume ?? this.volume,
      orderIndex: orderIndex ?? this.orderIndex,
      clips: clips ?? this.clips,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'type': type.name,
    'isMuted': isMuted,
    'isLocked': isLocked,
    'isVisible': isVisible,
    'volume': volume,
    'orderIndex': orderIndex,
    'clips': clips.map((c) => c.toJson()).toList(),
  };

  factory Track.fromJson(Map<String, dynamic> json) => Track(
    id: json['id'] as String,
    name: json['name'] as String? ?? 'Track',
    type: TrackType.values.firstWhere(
      (t) => t.name == json['type'],
      orElse: () => TrackType.video,
    ),
    isMuted: json['isMuted'] as bool? ?? false,
    isLocked: json['isLocked'] as bool? ?? false,
    isVisible: json['isVisible'] as bool? ?? true,
    volume: (json['volume'] as num?)?.toDouble() ?? 1.0,
    orderIndex: (json['orderIndex'] as num?)?.toInt() ?? 0,
    clips: (json['clips'] as List?)
            ?.map((c) => Clip.fromJson(c as Map<String, dynamic>))
            .toList() ??
        const [],
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Track &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name &&
          type == other.type &&
          isMuted == other.isMuted &&
          isLocked == other.isLocked &&
          isVisible == other.isVisible &&
          volume == other.volume &&
          orderIndex == other.orderIndex;

  @override
  int get hashCode =>
      id.hashCode ^
      name.hashCode ^
      type.hashCode ^
      isMuted.hashCode ^
      isLocked.hashCode ^
      isVisible.hashCode ^
      orderIndex.hashCode;

  @override
  String toString() => 'Track(id: $id, name: $name, type: ${type.name}, clips: ${clips.length})';
}
