import 'package:project_model/project_model.dart';
import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';
import '../database/app_database.dart';
import '../database/project_record.dart';

/// Repository managing SQLite persistence, project documents, search, and duplication.
class ProjectRepository {
  final Future<Database> Function() _dbProvider;

  ProjectRepository({Future<Database> Function()? dbProvider})
      : _dbProvider = dbProvider ?? AppDatabase.getInstance;

  /// Retrieves list of recent projects with optional text query filtering.
  Future<List<ProjectRecord>> getRecentProjects({String? query}) async {
    final db = await _dbProvider();
    List<Map<String, dynamic>> results;

    if (query != null && query.trim().isNotEmpty) {
      final sanitized = '%${query.trim()}%';
      results = await db.query(
        'projects',
        columns: [
          'id', 'name', 'schema_version', 'created_at', 'updated_at',
          'aspect_ratio_id', 'width', 'height', 'fps', 'duration_us',
          'clip_count', 'thumbnail_path'
        ],
        where: 'name LIKE ?',
        whereArgs: [sanitized],
        orderBy: 'updated_at DESC',
      );
    } else {
      results = await db.query(
        'projects',
        columns: [
          'id', 'name', 'schema_version', 'created_at', 'updated_at',
          'aspect_ratio_id', 'width', 'height', 'fps', 'duration_us',
          'clip_count', 'thumbnail_path'
        ],
        orderBy: 'updated_at DESC',
      );
    }

    return results.map((m) => ProjectRecord.fromMap(m)).toList();
  }

  /// Loads full editable [Project] document by ID.
  Future<Project> loadProject(String id) async {
    final db = await _dbProvider();
    final results = await db.query(
      'projects',
      columns: ['json_data'],
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );

    if (results.isEmpty) {
      throw StateError('Project with ID "$id" was not found in the local database.');
    }

    final rawJson = results.first['json_data'] as String;
    return ProjectSerializer.deserialize(rawJson);
  }

  /// Inserts or updates a [Project] in SQLite storage.
  Future<void> saveProject(Project project, {String? thumbnailPath}) async {
    final db = await _dbProvider();
    final jsonString = ProjectSerializer.serialize(project, pretty: false);

    final row = <String, dynamic>{
      'id': project.id,
      'name': project.name,
      'schema_version': project.schemaVersion,
      'created_at': project.createdAt.toIso8601String(),
      'updated_at': project.updatedAt.toIso8601String(),
      'aspect_ratio_id': project.canvas.id,
      'width': project.canvas.width,
      'height': project.canvas.height,
      'fps': project.canvas.fps,
      'duration_us': project.durationMicroseconds,
      'clip_count': project.totalClipCount,
      'thumbnail_path': thumbnailPath,
      'json_data': jsonString,
    };

    await db.insert(
      'projects',
      row,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Renames an existing project.
  Future<void> renameProject(String id, String newName) async {
    final project = await loadProject(id);
    final updated = project.copyWith(
      name: newName,
      updatedAt: DateTime.now(),
    );
    await saveProject(updated);
  }

  /// Duplicates an existing project with a new ID and title.
  Future<Project> duplicateProject(String id, String newName) async {
    final sourceProject = await loadProject(id);
    final newId = const Uuid().v4();
    final now = DateTime.now();

    // Deep copy tracks and clips with new IDs
    final duplicatedTracks = sourceProject.tracks.map((track) {
      final newTrackId = '${newId}_${track.id}';
      final duplicatedClips = track.clips.map((clip) {
        return clip.copyWith(
          id: const Uuid().v4(),
          trackId: newTrackId,
        );
      }).toList();

      return track.copyWith(
        id: newTrackId,
        clips: duplicatedClips,
      );
    }).toList();

    final duplicated = sourceProject.copyWith(
      id: newId,
      name: newName,
      createdAt: now,
      updatedAt: now,
      tracks: duplicatedTracks,
    );

    await saveProject(duplicated);
    return duplicated;
  }

  /// Deletes a project from SQLite storage.
  Future<void> deleteProject(String id) async {
    final db = await _dbProvider();
    await db.delete(
      'projects',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Returns total count of projects in local storage.
  Future<int> getProjectCount() async {
    final db = await _dbProvider();
    final count = Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM projects'),
    );
    return count ?? 0;
  }
}
