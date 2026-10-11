import 'package:project_model/project_model.dart';
import 'package:timeline_engine/timeline_engine.dart';

/// Sets a clip's volume gain (0.0 to 2.0) and mute state.
class VolumeClipCommand implements Command {
  final String clipId;
  final double newVolume;
  final bool? isMuted;

  late double _originalVolume;
  late bool _originalMuted;
  late int _trackIndex;
  late int _clipIndex;

  VolumeClipCommand({
    required this.clipId,
    required this.newVolume,
    this.isMuted,
  });

  @override
  String get description => 'Adjust Volume';

  @override
  Project execute(Project project) {
    for (int tIdx = 0; tIdx < project.tracks.length; tIdx++) {
      final track = project.tracks[tIdx];
      final cIdx = track.clips.indexWhere((c) => c.id == clipId);
      if (cIdx != -1) {
        _trackIndex = tIdx;
        _clipIndex = cIdx;
        final original = track.clips[cIdx];
        _originalVolume = original.volume;
        _originalMuted = original.isMuted;

        final updatedClip = original.copyWith(
          volume: newVolume.clamp(0.0, 2.0),
          isMuted: isMuted ?? original.isMuted,
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
      volume: _originalVolume,
      isMuted: _originalMuted,
    );

    final updatedClips = List<Clip>.from(track.clips);
    updatedClips[_clipIndex] = original;

    final updatedTrack = track.copyWith(clips: updatedClips);
    final updatedTracks = List<Track>.from(project.tracks);
    updatedTracks[_trackIndex] = updatedTrack;

    return project.copyWith(tracks: updatedTracks);
  }
}
