import 'package:project_model/project_model.dart';
import 'package:timeline_engine/timeline_engine.dart';

/// Deletes a clip from a track, storing its exact index for lossless undo.
class DeleteClipCommand implements Command {
  final String clipId;

  late Clip _deletedClip;
  late int _trackIndex;
  late int _clipIndex;

  DeleteClipCommand({required this.clipId});

  @override
  String get description => 'Delete Clip';

  @override
  Project execute(Project project) {
    for (int tIdx = 0; tIdx < project.tracks.length; tIdx++) {
      final track = project.tracks[tIdx];
      final cIdx = track.clips.indexWhere((c) => c.id == clipId);
      if (cIdx != -1) {
        _trackIndex = tIdx;
        _clipIndex = cIdx;
        _deletedClip = track.clips[cIdx];

        final updatedClips = List<Clip>.from(track.clips)..removeAt(cIdx);
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
    updatedClips.insert(_clipIndex, _deletedClip);

    final updatedTrack = track.copyWith(clips: updatedClips);
    final updatedTracks = List<Track>.from(project.tracks);
    updatedTracks[_trackIndex] = updatedTrack;

    return project.copyWith(tracks: updatedTracks);
  }
}
