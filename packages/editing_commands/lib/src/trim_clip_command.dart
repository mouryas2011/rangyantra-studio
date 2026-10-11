import 'package:project_model/project_model.dart';
import 'package:timeline_engine/timeline_engine.dart';

enum TrimEdge {
  inPoint,  // Trims the head of the clip
  outPoint, // Trims the tail of the clip
}

/// Trims a clip's head or tail boundary.
class TrimClipCommand implements Command {
  final String clipId;
  final TrimEdge edge;
  final int newBoundaryTimelineUs;

  late Clip _originalClip;
  late int _trackIndex;
  late int _clipIndex;

  TrimClipCommand({
    required this.clipId,
    required this.edge,
    required this.newBoundaryTimelineUs,
  });

  @override
  String get description => 'Trim Clip ${edge == TrimEdge.inPoint ? "Start" : "End"}';

  @override
  Project execute(Project project) {
    for (int tIdx = 0; tIdx < project.tracks.length; tIdx++) {
      final track = project.tracks[tIdx];
      final cIdx = track.clips.indexWhere((c) => c.id == clipId);
      if (cIdx != -1) {
        _trackIndex = tIdx;
        _clipIndex = cIdx;
        _originalClip = track.clips[cIdx];

        Clip trimmedClip;
        if (edge == TrimEdge.inPoint) {
          // Trimming head: newBoundaryTimelineUs becomes new timelineStartUs
          final deltaTimelineUs = newBoundaryTimelineUs - _originalClip.timelineStartUs;
          final newDurationUs = _originalClip.timelineDurationUs - deltaTimelineUs;
          if (newDurationUs <= 100000) { // Min clip length 0.1s
            throw ArgumentError('Cannot trim clip smaller than 0.1 seconds');
          }
          final deltaSourceUs = (deltaTimelineUs * _originalClip.speed).round();
          final newSourceInUs = _originalClip.sourceInUs + deltaSourceUs;

          trimmedClip = _originalClip.copyWith(
            timelineStartUs: newBoundaryTimelineUs,
            timelineDurationUs: newDurationUs,
            sourceInUs: newSourceInUs,
          );
        } else {
          // Trimming tail: newBoundaryTimelineUs becomes new timelineEndUs
          final newDurationUs = newBoundaryTimelineUs - _originalClip.timelineStartUs;
          if (newDurationUs <= 100000) {
            throw ArgumentError('Cannot trim clip smaller than 0.1 seconds');
          }
          final newSourceOutUs = _originalClip.sourceInUs + (newDurationUs * _originalClip.speed).round();

          trimmedClip = _originalClip.copyWith(
            timelineDurationUs: newDurationUs,
            sourceOutUs: newSourceOutUs,
          );
        }

        final updatedClips = List<Clip>.from(track.clips);
        updatedClips[_clipIndex] = trimmedClip;

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
    updatedClips[_clipIndex] = _originalClip;

    final updatedTrack = track.copyWith(clips: updatedClips);
    final updatedTracks = List<Track>.from(project.tracks);
    updatedTracks[_trackIndex] = updatedTrack;

    return project.copyWith(tracks: updatedTracks);
  }
}
