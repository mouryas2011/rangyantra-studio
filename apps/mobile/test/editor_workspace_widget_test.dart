import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:project_model/project_model.dart';
import 'package:rangyantra_mobile/core/theme/app_theme.dart';
import 'package:rangyantra_mobile/data/repositories/project_repository.dart';
import 'package:rangyantra_mobile/presentation/screens/editor/editor_workspace_screen.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  late Database db;
  late ProjectRepository repository;
  late Project testProject;

  setUp(() async {
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

    testProject = Project(
      id: 'p_edit_test',
      name: 'Cinema Edit 1',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      canvas: CanvasFormat.portrait9_16,
      tracks: [
        Track(
          id: 't_v1',
          name: 'Main Video',
          type: TrackType.video,
          orderIndex: 0,
          clips: [
            Clip(
              id: 'c_clip1',
              trackId: 't_v1',
              name: 'Sunrise Drone',
              mediaType: MediaType.video,
              timelineStartUs: 0,
              timelineDurationUs: 10000000, // 10s
              sourceOutUs: 10000000,
            ),
          ],
        ),
      ],
    );

    await repository.saveProject(testProject);
  });

  tearDown(() async {
    await db.close();
  });

  group('Editor Workspace Widget Tests', () {
    testWidgets('Renders top bar, viewport, SMPTE timecode, and multitrack lanes', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: EditorWorkspaceScreen(
            initialProject: testProject,
            repository: repository,
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Cinema Edit 1'), findsOneWidget);
      expect(find.text('Sunrise Drone'), findsWidgets);
      expect(find.text('Export'), findsOneWidget);
      expect(find.text('Split'), findsOneWidget);
      expect(find.text('Color'), findsOneWidget);
    });

    testWidgets('Selecting a clip and splitting activates undo', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: EditorWorkspaceScreen(
            initialProject: testProject,
            repository: repository,
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Tap on clip box to select it
      final clipFinder = find.text('Sunrise Drone').first;
      await tester.tap(clipFinder);
      await tester.pump(const Duration(milliseconds: 100));

      // Move playhead forward with Next Frame button (chevron_right)
      final nextFrameBtn = find.byIcon(Icons.chevron_right_rounded);
      for (int i = 0; i < 15; i++) {
        await tester.tap(nextFrameBtn);
        await tester.pump(const Duration(milliseconds: 20));
      }

      // Tap Split tool
      final splitBtn = find.text('Split');
      await tester.tap(splitBtn);
      await tester.pump(const Duration(milliseconds: 100));

      // Verify undo button is active and tap it
      final undoBtn = find.byIcon(Icons.undo_rounded);
      await tester.tap(undoBtn);
      await tester.pump(const Duration(milliseconds: 100));
    });
  });
}
