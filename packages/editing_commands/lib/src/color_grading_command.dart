import 'package:project_model/project_model.dart';
import 'package:timeline_engine/timeline_engine.dart';

/// Applies color grading adjustments to a clip.
class ColorGradingCommand implements Command {
  final String clipId;
  final ColorGradingProperties newGrading;

  late ColorGradingProperties _originalGrading;
  late int _trackIndex;
  late int _clipIndex;

  ColorGradingCommand({
    required this.clipId,
    required this.newGrading,
  });

  @override
  String get description => 'Apply Color Grading';

  @override
  Project execute(Project project) {
    for (int tIdx = 0; tIdx < project.tracks.length; tIdx++) {
      final track = project.tracks[tIdx];
      final cIdx = track.clips.indexWhere((c) => c.id == clipId);
      if (cIdx != -1) {
        _trackIndex = tIdx;
        _clipIndex = cIdx;
        final original = track.clips[cIdx];
        _originalGrading = original.colorGrading;

        final updatedClip = original.copyWith(colorGrading: newGrading);

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
    final original = track.clips[_clipIndex].copyWith(colorGrading: _originalGrading);

    final updatedClips = List<Clip>.from(track.clips);
    updatedClips[_clipIndex] = original;

    final updatedTrack = track.copyWith(clips: updatedClips);
    final updatedTracks = List<Track>.from(project.tracks);
    updatedTracks[_trackIndex] = updatedTrack;

    return project.copyWith(tracks: updatedTracks);
  }
}
