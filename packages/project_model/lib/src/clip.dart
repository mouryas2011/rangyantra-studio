import 'transform_properties.dart';
import 'color_grading.dart';
import 'effect.dart';
import 'transition.dart';
import 'keyframe.dart';
import 'text_properties.dart';

enum MediaType {
  video,
  audio,
  image,
  text,
  colorSolid,
}

/// Represents an editable segment on a timeline track.
class Clip {
  final String id;
  final String trackId;
  final String name;
  final String mediaPath; // File path, uri, or asset identifier (empty for text/solid)
  final MediaType mediaType;

  // Frame-aware / microsecond time placement
  final int timelineStartUs;    // Placement on track (microseconds)
  final int timelineDurationUs; // Duration on track (microseconds)
  final int sourceInUs;         // In-point within source media
  final int sourceOutUs;        // Out-point within source media

  final double speed;           // 0.25 to 8.0x
  final double volume;          // 0.0 to 2.0 (1.0 = 100%)
  final bool isMuted;

  final TransformProperties transform;
  final ColorGradingProperties colorGrading;
  final List<VisualEffect> effects;
  final Transition? transitionIn;
  final Transition? transitionOut;
  final TextProperties? textProperties;
  final List<Keyframe> keyframes;

  const Clip({
    required this.id,
    required this.trackId,
    required this.name,
    this.mediaPath = '',
    required this.mediaType,
    required this.timelineStartUs,
    required this.timelineDurationUs,
    this.sourceInUs = 0,
    required this.sourceOutUs,
    this.speed = 1.0,
    this.volume = 1.0,
    this.isMuted = false,
    this.transform = TransformProperties.identity,
    this.colorGrading = ColorGradingProperties.neutral,
    this.effects = const [],
    this.transitionIn,
    this.transitionOut,
    this.textProperties,
    this.keyframes = const [],
  });

  int get timelineEndUs => timelineStartUs + timelineDurationUs;

  Clip copyWith({
    String? id,
    String? trackId,
    String? name,
    String? mediaPath,
    MediaType? mediaType,
    int? timelineStartUs,
    int? timelineDurationUs,
    int? sourceInUs,
    int? sourceOutUs,
    double? speed,
    double? volume,
    bool? isMuted,
    TransformProperties? transform,
    ColorGradingProperties? colorGrading,
    List<VisualEffect>? effects,
    Transition? transitionIn,
    bool clearTransitionIn = false,
    Transition? transitionOut,
    bool clearTransitionOut = false,
    TextProperties? textProperties,
    List<Keyframe>? keyframes,
  }) {
    return Clip(
      id: id ?? this.id,
      trackId: trackId ?? this.trackId,
      name: name ?? this.name,
      mediaPath: mediaPath ?? this.mediaPath,
      mediaType: mediaType ?? this.mediaType,
      timelineStartUs: timelineStartUs ?? this.timelineStartUs,
      timelineDurationUs: timelineDurationUs ?? this.timelineDurationUs,
      sourceInUs: sourceInUs ?? this.sourceInUs,
      sourceOutUs: sourceOutUs ?? this.sourceOutUs,
      speed: speed ?? this.speed,
      volume: volume ?? this.volume,
      isMuted: isMuted ?? this.isMuted,
      transform: transform ?? this.transform,
      colorGrading: colorGrading ?? this.colorGrading,
      effects: effects ?? this.effects,
      transitionIn: clearTransitionIn ? null : (transitionIn ?? this.transitionIn),
      transitionOut: clearTransitionOut ? null : (transitionOut ?? this.transitionOut),
      textProperties: textProperties ?? this.textProperties,
      keyframes: keyframes ?? this.keyframes,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'trackId': trackId,
    'name': name,
    'mediaPath': mediaPath,
    'mediaType': mediaType.name,
    'timelineStartUs': timelineStartUs,
    'timelineDurationUs': timelineDurationUs,
    'sourceInUs': sourceInUs,
    'sourceOutUs': sourceOutUs,
    'speed': speed,
    'volume': volume,
    'isMuted': isMuted,
    'transform': transform.toJson(),
    'colorGrading': colorGrading.toJson(),
    'effects': effects.map((e) => e.toJson()).toList(),
    'transitionIn': transitionIn?.toJson(),
    'transitionOut': transitionOut?.toJson(),
    'textProperties': textProperties?.toJson(),
    'keyframes': keyframes.map((k) => k.toJson()).toList(),
  };

  factory Clip.fromJson(Map<String, dynamic> json) => Clip(
    id: json['id'] as String,
    trackId: json['trackId'] as String? ?? '',
    name: json['name'] as String? ?? 'Clip',
    mediaPath: json['mediaPath'] as String? ?? '',
    mediaType: MediaType.values.firstWhere(
      (m) => m.name == json['mediaType'],
      orElse: () => MediaType.video,
    ),
    timelineStartUs: (json['timelineStartUs'] as num).toInt(),
    timelineDurationUs: (json['timelineDurationUs'] as num).toInt(),
    sourceInUs: (json['sourceInUs'] as num?)?.toInt() ?? 0,
    sourceOutUs: (json['sourceOutUs'] as num?)?.toInt() ?? (json['timelineDurationUs'] as num).toInt(),
    speed: (json['speed'] as num?)?.toDouble() ?? 1.0,
    volume: (json['volume'] as num?)?.toDouble() ?? 1.0,
    isMuted: json['isMuted'] as bool? ?? false,
    transform: json['transform'] != null
        ? TransformProperties.fromJson(json['transform'] as Map<String, dynamic>)
        : TransformProperties.identity,
    colorGrading: json['colorGrading'] != null
        ? ColorGradingProperties.fromJson(json['colorGrading'] as Map<String, dynamic>)
        : ColorGradingProperties.neutral,
    effects: (json['effects'] as List?)
            ?.map((e) => VisualEffect.fromJson(e as Map<String, dynamic>))
            .toList() ??
        const [],
    transitionIn: json['transitionIn'] != null
        ? Transition.fromJson(json['transitionIn'] as Map<String, dynamic>)
        : null,
    transitionOut: json['transitionOut'] != null
        ? Transition.fromJson(json['transitionOut'] as Map<String, dynamic>)
        : null,
    textProperties: json['textProperties'] != null
        ? TextProperties.fromJson(json['textProperties'] as Map<String, dynamic>)
        : null,
    keyframes: (json['keyframes'] as List?)
            ?.map((k) => Keyframe.fromJson(k as Map<String, dynamic>))
            .toList() ??
        const [],
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Clip &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          timelineStartUs == other.timelineStartUs &&
          timelineDurationUs == other.timelineDurationUs &&
          sourceInUs == other.sourceInUs &&
          sourceOutUs == other.sourceOutUs &&
          speed == other.speed &&
          volume == other.volume &&
          isMuted == other.isMuted;

  @override
  int get hashCode =>
      id.hashCode ^
      timelineStartUs.hashCode ^
      timelineDurationUs.hashCode ^
      sourceInUs.hashCode ^
      sourceOutUs.hashCode;

  @override
  String toString() =>
      'Clip(id: $id, name: $name, type: ${mediaType.name}, start: ${timelineStartUs}us, dur: ${timelineDurationUs}us)';
}
