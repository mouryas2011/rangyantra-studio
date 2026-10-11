import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:project_model/project_model.dart';
import 'package:rangyantra_mobile/core/theme/app_theme.dart';
import 'package:rangyantra_mobile/data/repositories/project_repository.dart';
import 'package:rangyantra_mobile/presentation/screens/home/home_dashboard_screen.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  late Database db;
  late ProjectRepository repository;

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
  });

  tearDown(() async {
    await db.close();
  });

  group('Home Dashboard Widget Tests', () {
    testWidgets('Displays brand header and empty state when no projects exist', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: HomeDashboardScreen(repository: repository),
        ),
      );

      await tester.runAsync(() async {
        await Future.delayed(const Duration(milliseconds: 200));
      });
      await tester.pump();

      expect(find.text('RANG'), findsOneWidget);
      expect(find.text('YANTRA'), findsOneWidget);
      expect(find.text('STUDIO'), findsOneWidget);
      expect(find.text('No Projects Yet'), findsOneWidget);
      expect(find.text('New Project'), findsWidgets);
    });

    testWidgets('Renders project cards and responds to search filtering', (tester) async {
      // Seed two projects using runAsync for FFI SQLite execution
      await tester.runAsync(() async {
        await repository.saveProject(
          Project.create(id: 'p_kashmir', name: 'Kashmir Expedition'),
        );
        await repository.saveProject(
          Project.create(id: 'p_goa', name: 'Goa Golden Hour'),
        );
      });

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: HomeDashboardScreen(repository: repository),
        ),
      );

      await tester.runAsync(() async {
        await Future.delayed(const Duration(milliseconds: 200));
      });
      await tester.pump();

      expect(find.text('Kashmir Expedition'), findsOneWidget);
      expect(find.text('Goa Golden Hour'), findsOneWidget);

      // Filter search
      final searchField = find.byType(TextField).first;
      await tester.enterText(searchField, 'Goa');
      FocusManager.instance.primaryFocus?.unfocus();

      await tester.runAsync(() async {
        await Future.delayed(const Duration(milliseconds: 200));
      });
      await tester.pump();

      expect(find.text('Goa Golden Hour'), findsOneWidget);
      expect(find.text('Kashmir Expedition'), findsNothing);
    });
  });
}
