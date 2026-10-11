import 'package:project_model/project_model.dart';

/// Base command interface for all reversible editing operations.
abstract class Command {
  /// User-readable description (e.g. "Split Clip", "Trim Start", "Change Volume")
  String get description;

  /// Executes the operation on [project] and returns the updated [Project].
  Project execute(Project project);

  /// Reverses the operation on [project] and returns the restored [Project].
  Project undo(Project project);
}
