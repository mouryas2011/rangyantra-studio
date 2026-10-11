# RangYantra Studio (रंगयंत्र स्टूडियो) — Testing Strategy & Verification

**"From Imagination to Cinema" • "कल्पना से सिनेमा तक"**

---

## 1. Testing Philosophy

In RangYantra Studio, testability is treated as a fundamental architectural requirement. Video editors manipulate high-dimensional state machines with temporal constraints; bugs in timeline calculations lead to frame drift, audio de-synchronization, and corrupt project files. 

Our testing strategy follows a tiered pyramid:
1. **Domain Unit Tests**: Pure Dart package tests with zero UI coupling, verifying math, serialization, schema validation, and commands.
2. **Database Integration Tests**: In-memory and disk-backed SQLite tests using SQLite FFI to verify query performance, foreign key cascades, and transactional integrity.
3. **Widget Component Tests**: Flutter test binding tests verifying UI layout, interaction handling, undo/redo triggers, transport operations, and search filtering.
4. **Platform Bridge Unit Tests**: Mock bridge testing validating contract behavior across MethodChannels and EventChannels.

---

## 2. Test Suite Breakdown

All 27 automated tests are currently implemented and passing at 100%:

| Package / Module | Test File | Test Cases | Status |
| :--- | :--- | :---: | :---: |
| `packages/project_model` | `test/project_model_test.dart` | 4 | **PASSED** |
| `packages/timeline_engine` | `test/timeline_engine_test.dart` | 4 | **PASSED** |
| `packages/editing_commands` | `test/editing_commands_test.dart` | 6 | **PASSED** |
| `packages/media_bridge` | `test/media_bridge_test.dart` | 4 | **PASSED** |
| `apps/mobile` (Database) | `test/project_database_test.dart` | 5 | **PASSED** |
| `apps/mobile` (Dashboard) | `test/dashboard_widget_test.dart` | 2 | **PASSED** |
| `apps/mobile` (Editor) | `test/editor_workspace_widget_test.dart` | 2 | **PASSED** |
| **Total** | | **27** | **100% PASS** |

---

## 3. How to Execute Tests

Ensure Flutter and Dart are in your active PATH before running tests:

```bash
export PATH="/home/livelihood/.local/tools/flutter/bin:/home/livelihood/.local/tools/jdk17/bin:$PATH"
export JAVA_HOME="/home/livelihood/.local/tools/jdk17"
export ANDROID_HOME="/home/livelihood/android-sdk"
```

### Run All Unit and Widget Tests Across Workspace
```bash
(cd packages/project_model && flutter test) && \
(cd packages/timeline_engine && flutter test) && \
(cd packages/editing_commands && flutter test) && \
(cd packages/media_bridge && flutter test) && \
(cd apps/mobile && flutter test)
```

### Run Static Analysis Across All Packages
```bash
(cd packages/project_model && flutter analyze) && \
(cd packages/timeline_engine && flutter analyze) && \
(cd packages/editing_commands && flutter analyze) && \
(cd packages/media_bridge && flutter analyze) && \
(cd apps/mobile && flutter analyze)
```

---

## 4. Key Testing Insights & Resolutions

### SQLite FFI in Widget Tests
Because desktop and test runners do not run on Android/iOS native SQLite C libraries, tests employ `sqflite_common_ffi`:
- `sqfliteFfiInit()` and `databaseFactory = databaseFactoryFfi;` are called in test harnesses.
- SQLite FFI operations interact with native C worker threads. In Flutter's `testWidgets`, running FFI operations directly in the fake-async zone causes deadlock assertions. All repository queries within widget tests are explicitly executed inside `await tester.runAsync(...)`.

### Persistent Cursor Blink Timers in TextFields
In Flutter widget tests, focusing a `TextField` activates a periodic `_cursorBlinkTimer`. Calling `await tester.pumpAndSettle()` while the cursor timer is active causes a test timeout. To avoid this, our test harness calls `FocusManager.instance.primaryFocus?.unfocus();` prior to settling.
