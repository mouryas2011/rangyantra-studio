import 'command.dart';
import 'package:project_model/project_model.dart';

/// Manages undo and redo stacks with configurable depth.
class CommandHistory {
  final int maxHistoryDepth;
  final List<Command> _undoStack = [];
  final List<Command> _redoStack = [];

  CommandHistory({this.maxHistoryDepth = 50});

  bool get canUndo => _undoStack.isNotEmpty;
  bool get canRedo => _redoStack.isNotEmpty;

  String? get undoDescription => _undoStack.isNotEmpty ? _undoStack.last.description : null;
  String? get redoDescription => _redoStack.isNotEmpty ? _redoStack.last.description : null;

  /// Executes [command] on [currentProject], pushes it to undo stack, and clears redo stack.
  Project execute(Command command, Project currentProject) {
    final updated = command.execute(currentProject);
    _undoStack.add(command);
    if (_undoStack.length > maxHistoryDepth) {
      _undoStack.removeAt(0);
    }
    _redoStack.clear();
    return updated.copyWith(updatedAt: DateTime.now());
  }

  /// Reverts the most recent command on [currentProject].
  Project undo(Project currentProject) {
    if (!canUndo) return currentProject;
    final cmd = _undoStack.removeLast();
    final reverted = cmd.undo(currentProject);
    _redoStack.add(cmd);
    return reverted.copyWith(updatedAt: DateTime.now());
  }

  /// Re-applies the most recently reverted command on [currentProject].
  Project redo(Project currentProject) {
    if (!canRedo) return currentProject;
    final cmd = _redoStack.removeLast();
    final updated = cmd.execute(currentProject);
    _undoStack.add(cmd);
    return updated.copyWith(updatedAt: DateTime.now());
  }

  /// Clears both undo and redo histories (e.g. on new project load).
  void clear() {
    _undoStack.clear();
    _redoStack.clear();
  }
}
