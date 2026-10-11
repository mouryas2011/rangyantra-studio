import 'package:project_model/project_model.dart';
import 'package:timeline_engine/timeline_engine.dart';
import 'package:uuid/uuid.dart';

/// Duplicates a clip and inserts it adjacent to the original on the timeline.
class DuplicateClipCommand implements Command {
  final String clipId;
  final String newClipId;

  late int _trackIndex;
  late int _insertIndex;

  DuplicateClipCommand({
    required this.clipId,
    String? newClipId,
  }) : newClipId = newClipId ?? const Uuid().v4();

  @override
  String get description => 'Duplicate Clip';

  @override
  Project execute(Project project) {
    for (int tIdx = 0; tIdx < project.tracks.length; tIdx++) {
      final track = project.tracks[tIdx];
      final cIdx = track.clips.indexWhere((c) => c.id == clipId);
      if (cIdx != -1) {
        _trackIndex = tIdx;
        _insertIndex = cIdx + 1;
        final original = track.clips[cIdx];

        final duplicate = original.copyWith(
          id: newClipId,
          name: '${original.name} (Copy)',
          timelineStartUs: original.timelineEndUs,
        );

        final updatedClips = List<Clip>.from(track.clips);
        updatedClips.insert(_insertIndex, duplicate);

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
    final updatedClips = List<Clip>.from(track.clips)
      ..removeWhere((c) => c.id == newClipId);

    final updatedTrack = track.copyWith(clips: updatedClips);
    final updatedTracks = List<Track>.from(project.tracks);
    updatedTracks[_trackIndex] = updatedTrack;

    return project.copyWith(tracks: updatedTracks);
  }
}
