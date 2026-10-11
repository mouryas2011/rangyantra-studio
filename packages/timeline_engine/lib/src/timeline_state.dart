import 'package:flutter/foundation.dart';
import 'package:project_model/project_model.dart';
import 'rational_time.dart';
import 'timebase.dart';
import 'command.dart';
import 'command_history.dart';

/// The central observable state controller for the editing timeline.
class TimelineController extends ChangeNotifier {
  Project _project;
  RationalTime _playhead;
  bool _isPlaying = false;
  String? _selectedTrackId;
  String? _selectedClipId;
  double _zoomPixelsPerSecond = 80.0; // Responsive timeline zoom
  bool _isSnappingEnabled = true;

  final CommandHistory _history;
  late final Timebase _timebase;

  TimelineController({
    required Project project,
    int maxUndoSteps = 50,
  })  : _project = project,
        _playhead = RationalTime.zero(fps: project.canvas.fps),
        _history = CommandHistory(maxHistoryDepth: maxUndoSteps) {
    _timebase = Timebase(fps: project.canvas.fps);
  }

  Project get project => _project;
  RationalTime get playhead => _playhead;
  bool get isPlaying => _isPlaying;
  String? get selectedTrackId => _selectedTrackId;
  String? get selectedClipId => _selectedClipId;
  double get zoomPixelsPerSecond => _zoomPixelsPerSecond;
  bool get isSnappingEnabled => _isSnappingEnabled;
  Timebase get timebase => _timebase;

  bool get canUndo => _history.canUndo;
  bool get canRedo => _history.canRedo;
  String? get undoDescription => _history.undoDescription;
  String? get redoDescription => _history.redoDescription;

  /// Returns the currently selected clip, if any.
  Clip? get selectedClip {
    if (_selectedClipId == null) return null;
    for (final track in _project.tracks) {
      for (final clip in track.clips) {
        if (clip.id == _selectedClipId) return clip;
      }
    }
    return null;
  }

  /// Updates the project state directly (used during load/recovery).
  void loadProject(Project project) {
    _project = project;
    _history.clear();
    _playhead = RationalTime.zero(fps: project.canvas.fps);
    _selectedClipId = null;
    _selectedTrackId = null;
    _isPlaying = false;
    notifyListeners();
  }

  /// Seeks to a specific frame-accurate time position.
  void seek(RationalTime target) {
    final maxDurUs = _project.durationMicroseconds;
    int targetUs = target.microseconds;
    if (targetUs < 0) targetUs = 0;
    if (maxDurUs > 0 && targetUs > maxDurUs) targetUs = maxDurUs;

    _playhead = RationalTime.fromMicroseconds(targetUs, fps: _project.canvas.fps);
    notifyListeners();
  }

  void seekToMicroseconds(int us) {
    seek(RationalTime.fromMicroseconds(us, fps: _project.canvas.fps));
  }

  void togglePlay() {
    _isPlaying = !_isPlaying;
    notifyListeners();
  }

  void pause() {
    if (_isPlaying) {
      _isPlaying = false;
      notifyListeners();
    }
  }

  void selectClip(String? clipId, String? trackId) {
    _selectedClipId = clipId;
    _selectedTrackId = trackId;
    notifyListeners();
  }

  void setZoom(double pixelsPerSecond) {
    _zoomPixelsPerSecond = pixelsPerSecond.clamp(20.0, 400.0);
    notifyListeners();
  }

  void toggleSnapping() {
    _isSnappingEnabled = !_isSnappingEnabled;
    notifyListeners();
  }

  /// Executes a reversible command, updating project state and history.
  void execute(Command command) {
    _project = _history.execute(command, _project);
    notifyListeners();
  }

  /// Undoes the last editing command.
  void undo() {
    if (canUndo) {
      _project = _history.undo(_project);
      // Validate if selected clip still exists
      if (_selectedClipId != null && selectedClip == null) {
        _selectedClipId = null;
      }
      notifyListeners();
    }
  }

  /// Redoes the reverted editing command.
  void redo() {
    if (canRedo) {
      _project = _history.redo(_project);
      notifyListeners();
    }
  }
}
