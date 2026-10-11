import 'package:project_model/project_model.dart';
import 'package:timeline_engine/timeline_engine.dart';
import 'package:uuid/uuid.dart';

/// Splits a clip at [splitTimeUs] into two distinct, independently editable clips.
class SplitClipCommand implements Command {
  final String clipId;
  final int splitTimeUs;
  final String newClipId;

  late Clip _originalClip;
  late int _trackIndex;
  late int _clipIndex;

  SplitClipCommand({
    required this.clipId,
    required this.splitTimeUs,
    String? newClipId,
  }) : newClipId = newClipId ?? const Uuid().v4();

  @override
  String get description => 'Split Clip at ${(splitTimeUs / 1000000).toStringAsFixed(2)}s';

  @override
  Project execute(Project project) {
    // Find track and clip
    for (int tIdx = 0; tIdx < project.tracks.length; tIdx++) {
      final track = project.tracks[tIdx];
      final cIdx = track.clips.indexWhere((c) => c.id == clipId);
      if (cIdx != -1) {
        _trackIndex = tIdx;
        _clipIndex = cIdx;
        _originalClip = track.clips[cIdx];

        // Validate split point is strictly inside clip
        if (splitTimeUs <= _originalClip.timelineStartUs ||
            splitTimeUs >= _originalClip.timelineEndUs) {
          throw ArgumentError(
            'Split point $splitTimeUs is outside clip bounds [${_originalClip.timelineStartUs}, ${_originalClip.timelineEndUs}]',
          );
        }

        final relativeTimelineUs = splitTimeUs - _originalClip.timelineStartUs;
        final sourceSplitOffsetUs = (relativeTimelineUs * _originalClip.speed).round();
        final sourceSplitUs = _originalClip.sourceInUs + sourceSplitOffsetUs;

        // Clip 1 (First half)
        final clipA = _originalClip.copyWith(
          timelineDurationUs: relativeTimelineUs,
          sourceOutUs: sourceSplitUs,
        );

        // Clip 2 (Second half)
        final clipB = _originalClip.copyWith(
          id: newClipId,
          name: '${_originalClip.name} (Part 2)',
          timelineStartUs: splitTimeUs,
          timelineDurationUs: _originalClip.timelineDurationUs - relativeTimelineUs,
          sourceInUs: sourceSplitUs,
          sourceOutUs: _originalClip.sourceOutUs,
          clearTransitionIn: true, // transition in stays on clip A
        );

        final updatedClips = List<Clip>.from(track.clips);
        updatedClips[_clipIndex] = clipA;
        updatedClips.insert(_clipIndex + 1, clipB);

        final updatedTrack = track.copyWith(clips: updatedClips);
        final updatedTracks = List<Track>.from(project.tracks);
        updatedTracks[_trackIndex] = updatedTrack;

        return project.copyWith(tracks: updatedTracks);
      }
    }

    throw StateError('Clip $clipId not found in project');
  }

  @override
  Project undo(Project project) {
    final track = project.tracks[_trackIndex];
    final updatedClips = List<Clip>.from(track.clips);

    // Remove Clip B
    updatedClips.removeWhere((c) => c.id == newClipId);

    // Restore Clip A to original state
    final idx = updatedClips.indexWhere((c) => c.id == clipId);
    if (idx != -1) {
      updatedClips[idx] = _originalClip;
    } else {
      updatedClips.insert(_clipIndex, _originalClip);
    }

    final updatedTrack = track.copyWith(clips: updatedClips);
    final updatedTracks = List<Track>.from(project.tracks);
    updatedTracks[_trackIndex] = updatedTrack;

    return project.copyWith(tracks: updatedTracks);
  }
}
