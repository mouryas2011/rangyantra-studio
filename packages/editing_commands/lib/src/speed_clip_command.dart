import 'package:project_model/project_model.dart';
import 'package:timeline_engine/timeline_engine.dart';

/// Changes a clip's playback speed (0.25x to 8.0x) and adjusts its timeline duration.
class SpeedClipCommand implements Command {
  final String clipId;
  final double newSpeed;

  late double _originalSpeed;
  late int _originalDurationUs;
  late int _trackIndex;
  late int _clipIndex;

  SpeedClipCommand({
    required this.clipId,
    required this.newSpeed,
  });

  @override
  String get description => 'Change Speed to ${newSpeed.toStringAsFixed(2)}x';

  @override
  Project execute(Project project) {
    if (newSpeed < 0.1 || newSpeed > 16.0) {
      throw ArgumentError('Speed must be between 0.1x and 16.0x');
    }

    for (int tIdx = 0; tIdx < project.tracks.length; tIdx++) {
      final track = project.tracks[tIdx];
      final cIdx = track.clips.indexWhere((c) => c.id == clipId);
      if (cIdx != -1) {
        _trackIndex = tIdx;
        _clipIndex = cIdx;
        final original = track.clips[cIdx];
        _originalSpeed = original.speed;
        _originalDurationUs = original.timelineDurationUs;

        final sourceSpanUs = original.sourceOutUs - original.sourceInUs;
        final newDurationUs = (sourceSpanUs / newSpeed).round();

        final updatedClip = original.copyWith(
          speed: newSpeed,
          timelineDurationUs: newDurationUs,
        );

        final updatedClips = List<Clip>.from(track.clips);
        updatedClips[_clipIndex] = updatedClip;

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
    final original = track.clips[_clipIndex].copyWith(
      speed: _originalSpeed,
      timelineDurationUs: _originalDurationUs,
    );

    final updatedClips = List<Clip>.from(track.clips);
    updatedClips[_clipIndex] = original;

    final updatedTrack = track.copyWith(clips: updatedClips);
    final updatedTracks = List<Track>.from(project.tracks);
    updatedTracks[_trackIndex] = updatedTrack;

    return project.copyWith(tracks: updatedTracks);
  }
}
