import 'package:project_model/project_model.dart';
import 'package:timeline_engine/timeline_engine.dart';

/// Appends or inserts a new clip onto a specific track.
class AddClipCommand implements Command {
  final String trackId;
  final Clip clip;
  final int? insertIndex;

  late int _trackIndex;
  late int _actualInsertIndex;

  AddClipCommand({
    required this.trackId,
    required this.clip,
    this.insertIndex,
  });

  @override
  String get description => 'Add Clip "${clip.name}"';

  @override
  Project execute(Project project) {
    final tIdx = project.tracks.indexWhere((t) => t.id == trackId);
    if (tIdx == -1) {
      throw StateError('Track $trackId not found in project');
    }
    _trackIndex = tIdx;
    final track = project.tracks[tIdx];

    final updatedClips = List<Clip>.from(track.clips);
    _actualInsertIndex = insertIndex ?? updatedClips.length;
    if (_actualInsertIndex > updatedClips.length) {
      _actualInsertIndex = updatedClips.length;
    }
    updatedClips.insert(_actualInsertIndex, clip);

    final updatedTrack = track.copyWith(clips: updatedClips);
    final updatedTracks = List<Track>.from(project.tracks);
    updatedTracks[_trackIndex] = updatedTrack;

    return project.copyWith(tracks: updatedTracks);
  }

  @override
  Project undo(Project project) {
    final track = project.tracks[_trackIndex];
    final updatedClips = List<Clip>.from(track.clips)
      ..removeWhere((c) => c.id == clip.id);

    final updatedTrack = track.copyWith(clips: updatedClips);
    final updatedTracks = List<Track>.from(project.tracks);
    updatedTracks[_trackIndex] = updatedTrack;

    return project.copyWith(tracks: updatedTracks);
  }
}
