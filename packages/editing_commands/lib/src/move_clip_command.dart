import 'package:project_model/project_model.dart';
import 'package:timeline_engine/timeline_engine.dart';

/// Moves a clip to a new start position, optionally across tracks.
class MoveClipCommand implements Command {
  final String clipId;
  final int newStartTimelineUs;
  final String? targetTrackId;

  late int _originalStartUs;
  late String _originalTrackId;

  MoveClipCommand({
    required this.clipId,
    required this.newStartTimelineUs,
    this.targetTrackId,
  });

  @override
  String get description => 'Move Clip';

  @override
  Project execute(Project project) {
    int sourceTrackIdx = -1;
    int clipIdx = -1;
    Clip? clipToMove;

    for (int i = 0; i < project.tracks.length; i++) {
      final t = project.tracks[i];
      final idx = t.clips.indexWhere((c) => c.id == clipId);
      if (idx != -1) {
        sourceTrackIdx = i;
        clipIdx = idx;
        clipToMove = t.clips[idx];
        break;
      }
    }

    if (clipToMove == null) {
      throw StateError('Clip $clipId not found in project');
    }

    _originalStartUs = clipToMove.timelineStartUs;
    _originalTrackId = project.tracks[sourceTrackIdx].id;
    final destTrackId = targetTrackId ?? _originalTrackId;

    final updatedClip = clipToMove.copyWith(
      timelineStartUs: newStartTimelineUs < 0 ? 0 : newStartTimelineUs,
      trackId: destTrackId,
    );

    final updatedTracks = List<Track>.from(project.tracks);

    if (destTrackId == _originalTrackId) {
      // Same track move
      final clips = List<Clip>.from(project.tracks[sourceTrackIdx].clips);
      clips[clipIdx] = updatedClip;
      // Sort by timeline start position
      clips.sort((a, b) => a.timelineStartUs.compareTo(b.timelineStartUs));
      updatedTracks[sourceTrackIdx] = project.tracks[sourceTrackIdx].copyWith(clips: clips);
    } else {
      // Move between tracks
      final sourceClips = List<Clip>.from(project.tracks[sourceTrackIdx].clips)..removeAt(clipIdx);
      updatedTracks[sourceTrackIdx] = project.tracks[sourceTrackIdx].copyWith(clips: sourceClips);

      final destIdx = project.tracks.indexWhere((t) => t.id == destTrackId);
      if (destIdx == -1) throw StateError('Destination track $destTrackId not found');

      final destClips = List<Clip>.from(project.tracks[destIdx].clips)..add(updatedClip);
      destClips.sort((a, b) => a.timelineStartUs.compareTo(b.timelineStartUs));
      updatedTracks[destIdx] = project.tracks[destIdx].copyWith(clips: destClips);
    }

    return project.copyWith(tracks: updatedTracks);
  }

  @override
  Project undo(Project project) {
    return MoveClipCommand(
      clipId: clipId,
      newStartTimelineUs: _originalStartUs,
      targetTrackId: _originalTrackId,
    ).execute(project);
  }
}
