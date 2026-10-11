import 'package:flutter_test/flutter_test.dart';
import 'package:project_model/project_model.dart';
import 'package:rangyantra_mobile/data/repositories/project_repository.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  late Database db;
  late ProjectRepository repository;

  setUp(() async {
    // Fresh in-memory SQLite database for isolated testing
    db = await databaseFactory.openDatabase(
      inMemoryDatabasePath,
      options: OpenDatabaseOptions(
        version: 1,
        onCreate: (d, v) async {
          await d.execute('''
            CREATE TABLE projects (
              id TEXT PRIMARY KEY,
              name TEXT NOT NULL,
              schema_version INTEGER NOT NULL,
              created_at TEXT NOT NULL,
              updated_at TEXT NOT NULL,
              aspect_ratio_id TEXT NOT NULL,
              width INTEGER NOT NULL,
              height INTEGER NOT NULL,
              fps INTEGER NOT NULL,
              duration_us INTEGER NOT NULL,
              clip_count INTEGER NOT NULL,
              thumbnail_path TEXT,
              json_data TEXT NOT NULL
            )
          ''');
        },
      ),
    );

    repository = ProjectRepository(dbProvider: () async => db);
  });

  tearDown(() async {
    await db.close();
  });

  group('SQLite Project Repository Tests', () {
    test('Save and load project preserves complete data integrity', () async {
      final project = Project.create(
        id: 'proj_db_1',
        name: 'Monsoon Cinema',
        canvas: CanvasFormat.landscape16_9,
      );

      await repository.saveProject(project);

      final count = await repository.getProjectCount();
      expect(count, equals(1));

      final loaded = await repository.loadProject('proj_db_1');
      expect(loaded.id, equals('proj_db_1'));
      expect(loaded.name, equals('Monsoon Cinema'));
      expect(loaded.canvas.id, equals('16_9'));
      expect(loaded.tracks.length, equals(3));
    });

    test('Query filtering matches project titles case-insensitively', () async {
      await repository.saveProject(Project.create(id: 'p1', name: 'Delhi Vlog'));
      await repository.saveProject(Project.create(id: 'p2', name: 'Mumbai Sunset'));
      await repository.saveProject(Project.create(id: 'p3', name: 'Delhi Night Drive'));

      final all = await repository.getRecentProjects();
      expect(all.length, equals(3));

      final delhiResults = await repository.getRecentProjects(query: 'delhi');
      expect(delhiResults.length, equals(2));

      final sunsetResults = await repository.getRecentProjects(query: 'sunset');
      expect(sunsetResults.length, equals(1));
      expect(sunsetResults.first.id, equals('p2'));
    });

    test('Rename project updates database and timestamps', () async {
      final project = Project.create(id: 'p_ren', name: 'Original Title');
      await repository.saveProject(project);

      await repository.renameProject('p_ren', 'Updated Title');

      final loaded = await repository.loadProject('p_ren');
      expect(loaded.name, equals('Updated Title'));
    });

    test('Duplicate project creates unique IDs and copies tracks', () async {
      final orig = Project.create(id: 'p_orig', name: 'Source Master');
      await repository.saveProject(orig);

      final dup = await repository.duplicateProject('p_orig', 'Source Master Copy');

      expect(dup.id, isNot(equals('p_orig')));
      expect(dup.name, equals('Source Master Copy'));

      final all = await repository.getRecentProjects();
      expect(all.length, equals(2));
    });

    test('Delete project removes entry from database', () async {
      final project = Project.create(id: 'p_del', name: 'To Be Deleted');
      await repository.saveProject(project);

      expect(await repository.getProjectCount(), equals(1));

      await repository.deleteProject('p_del');

      expect(await repository.getProjectCount(), equals(0));
      expect(() => repository.loadProject('p_del'), throwsA(isA<StateError>()));
    });
  });
}
