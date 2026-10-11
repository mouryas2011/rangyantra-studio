# RangYantra Studio (रंगयंत्र स्टूडियो) — System Architecture

**"From Imagination to Cinema" • "कल्पना से सिनेमा तक"**

---

## 1. Architectural Tenets & Vision

RangYantra Studio is engineered from first principles as an industrial-grade mobile non-linear video editing (NLE) and motion graphics application for Android and iOS. Unlike lightweight consumer video cutters or prototype wrappers, RangYantra is structured around strict professional criteria:

1. **Local-First & Privacy Sovereign**: All assets, databases, timeline state files, and rendered media remain entirely on the user's device. No telemetry, no cloud lock-in, and zero mandatory external network dependencies.
2. **Deterministic, Rational Timebase**: Time is never represented as floating-point seconds. All durations, edit points, transitions, and keyframes are computed using integer microsecond precision and rational frame-fraction math (`RationalTime`), eliminating drift over long timelines and non-integer frame rates (23.976, 29.97, 59.94 fps).
3. **Strict Non-Destructive Editing**: Source media files are immutable. Timeline edits (splits, trims, volume changes, color grades, transforms) are serialized as transactional edit descriptors executed through an undo/redo `Command` hierarchy.
4. **Modular Monorepo Architecture**: Clean separation between pure Dart domain logic (project model, timeline engine, editing commands, native bridge contracts) and the Flutter presentation layer. Packages are decoupled and individually tested.
5. **Native Hardware Acceleration**: High-performance playback, composition, and export are bridged to platform-native media stacks: Android Media3 / Transformer / SurfaceTexture, and Apple AVFoundation / AVVideoComposition / Metal.

---

## 2. Layered Architecture Diagram

```
+-----------------------------------------------------------------------------------+
|                            apps/mobile (Flutter / Dart)                           |
|  +--------------------+  +--------------------+  +-----------------------------+  |
|  |  Splash & Recovery |  |   Home Dashboard   |  |      Editor Workspace       |  |
|  |  Sequence (Sec 4)  |  |  (CRUD / Import)   |  | (Multitrack Canvas, Scrubber)| |
|  +--------------------+  +--------------------+  +-----------------------------+  |
|  +--------------------+  +--------------------+  +-----------------------------+  |
|  |     AI Studio      |  |  Template Library  |  |   Settings & Diagnostics    |  |
|  |  (On-Device Suite) |  |   (Cinema, Reels)  |  |    (FFI, SQLite, System)    |  |
|  +--------------------+  +--------------------+  +-----------------------------+  |
+-----------------------------------------+-----------------------------------------+
                                          |
                      +-------------------+-------------------+
                      |                                       |
+---------------------v-------------------+ +-----------------v---------------------+
|      packages/timeline_engine           | |     packages/editing_commands         |
| - RationalTime (Integer & SMPTE)        | | - Command History (Undo/Redo Stack)   |
| - Snapping & Quantization               | | - SplitClipCommand, TrimClipCommand   |
| - TimelineController (Reactive State)   | | - SpeedClipCommand, MoveClipCommand   |
+---------------------+-------------------+ | - ColorGradingCommand, AddClipCommand |
                      |                     +-----------------+---------------------+
                      |                                       |
+---------------------v---------------------------------------v---------------------+
|                            packages/project_model                                 |
| - Schema Version 1 Specification & Migration Pipeline                             |
| - Project, Track (Video, Audio, Overlay, Text), Clip                              |
| - TransformProperties, ColorGradingProperties, Effects, Keyframes                 |
+-----------------------------------------+-----------------------------------------+
                                          |
+-----------------------------------------v-----------------------------------------+
|                            packages/media_bridge                                  |
| - NativeBridgeContract (MethodChannel & EventChannel interfaces)                  |
| - MediaMetadata inspection, Thumbnail extraction, Hardware codec detection        |
+-----------------------------------------+-----------------------------------------+
                                          |
             +----------------------------+----------------------------+
             |                                                         |
+------------v---------------------------+ +---------------------------v------------+
|         Android Platform               | |             iOS Platform               |
| - Media3 Transformer & ExoPlayer       | | - AVFoundation (AVPlayer, AVAsset)     |
| - SurfaceTexture / OpenGL ES           | | - AVVideoComposition & Metal Shaders   |
| - MediaCodec Hardware Acceleration     | | - VideoToolbox Hardware Encoding       |
+----------------------------------------+ +----------------------------------------+
```

---

## 3. Package Structure & Separation of Concerns

The workspace is organized into a modular monorepo:

### `packages/project_model`
- **Purpose**: Defines the authoritative schema for RangYantra Studio projects (`.rangyantra` JSON format).
- **Dependencies**: Pure Dart (`json_annotation`, `uuid`). Zero Flutter framework coupling.
- **Key Classes**:
  - `Project`: Root entity with project metadata, dimensions, framerate, sample rate, and track list.
  - `Track`: Multitrack lane container (`video`, `audio`, `overlay`, `text`) with mute/solo/lock flags.
  - `Clip`: Individual timeline segment with source media reference, in/out points, timeline placement, speed multiplier, transforms, and color grading.
  - `TransformProperties`: Position (x, y), scale (x, y), rotation (degrees), opacity, and blend modes.
  - `ColorGradingProperties`: Exposure, contrast, saturation, temperature, tint, highlights, shadows, vibrance.
  - `ProjectSerializer`: JSON encoder/decoder with schema validation and version migrations.

### `packages/timeline_engine`
- **Purpose**: High-precision timeline math, snapping rules, and reactive playback state management.
- **Key Classes**:
  - `RationalTime`: Microsecond-accurate time representation with frame quantization and SMPTE 12M timecode formatting (`HH:MM:SS:FF`).
  - `Timebase`: Configurable snapping engine supporting head/tail alignment, playhead snapping, and split snapping within threshold boundaries.
  - `TimelineController`: `ChangeNotifier` coordinating current playhead position, active track/clip selections, playback status, and zoom level (`pixelsPerSecond`).

### `packages/editing_commands`
- **Purpose**: Reversible, non-destructive editing operations following the Command Pattern.
- **Key Classes**:
  - `Command`: Abstract base with `execute()` and `undo()` contracts.
  - `SplitClipCommand`: Divides a clip at an exact microsecond boundary, computing source in/out offsets and preserving transforms and grading.
  - `TrimClipCommand`: Head or tail trimming with clamp constraints and source duration validation.
  - `DeleteClipCommand` & `DuplicateClipCommand`: Track item removal and duplication.
  - `MoveClipCommand`: Temporal shifting and cross-track movement.
  - `SpeedClipCommand`: Speed multiplier adjustment with reciprocal duration calculations.
  - `ColorGradingCommand`: Live parameter modification with previous state caching.

### `packages/media_bridge`
- **Purpose**: Abstraction bridge between Dart code and native platform video processing engines.
- **Key Classes**:
  - `NativeMediaBridge`: Abstract interface defining `probeMedia()`, `generateThumbnail()`, `startExport()`, and `cancelExport()`.
  - `MediaItem`: Ingested asset descriptor with file path, format, MIME type, dimensions, duration, and audio channel count.
  - `MediaImportHandler`: File integrity validation, existence checks, and asset entity generation.

### `apps/mobile`
- **Purpose**: Cross-platform application shell, UI components, local SQLite persistence, and state orchestration.
- **Key Modules**:
  - `core/`: Exact brand design system (`AppColors`, `AppTypography`, `AppTheme`).
  - `data/`: Local SQLite persistence (`AppDatabase`, `ProjectRepository`, `MediaImportService`).
  - `presentation/`:
    - `screens/splash/`: Brand animation sequence (Saffron ring, Cyan sweep, title reveal, system recovery).
    - `screens/home/`: Project listing, search, project creation modal, media import, duplication, renaming, deletion.
    - `screens/editor/`: Full-featured NLE workspace with viewport, transport bar, multitrack timeline lanes, playhead scrubber, editing toolbar, and autosave.
    - `screens/ai_studio/`: Free-first on-device AI features (silence remover, auto-captions, beat detection, smart framing, color match).
    - `screens/templates/`: 4 pre-built cinema and social templates (Cinema Scope 2.39:1, Reel / Short 9:16, YouTube 16:9 4K, Square 1:1).
    - `screens/settings/`: Diagnostics, hardware probe, project export defaults, storage statistics.

---

## 4. Timebase & Non-Destructive Editing Model

### Integer Microsecond Quantization
Video timelines suffer from floating-point accumulation errors when represented as IEEE 754 `double`. RangYantra Studio enforces integer microseconds (`int microseconds`) across all timeline calculations:
- `1 second = 1,000,000 microseconds`
- `At 30 FPS: 1 frame = 33,333.33 microseconds`
- `RationalTime` maps microseconds to integer frames:
  ```dart
  int getFrame(double fps) => (microseconds * fps / 1000000.0).round();
  ```
- SMPTE 12M timecodes (`00:00:00:00`) are derived deterministically:
  ```dart
  String toSmpte(double fps); // e.g. "01:14:22:18"
  ```

### Reversible Command Architecture
Every timeline modification is an atomic command pushed onto `CommandHistory`:
```dart
abstract class Command {
  Project execute(Project project);
  Project undo(Project project);
}
```
If an operation fails, the timeline state is preserved. Undoing restores the previous immutable `Project` snapshot without re-reading from disk.

---

## 5. Storage & Persistence Engine

### SQLite Database Architecture
Project metadata, project manifests, and asset links are persisted in an on-device SQLite database (`rangyantra_studio.db`):
- **WAL Mode (`PRAGMA journal_mode=WAL;`)**: Enables concurrent readers without blocking background writes.
- **Foreign Key Constraints (`PRAGMA foreign_keys = ON;`)**: Ensures referential integrity between projects, tracks, and clips.
- **Cross-Platform Compatibility**: Automatically initializes `sqflite_common_ffi` on Linux/macOS/Windows desktop platforms and unit test runners, while leveraging native Android and iOS SQLite drivers in mobile builds.

### Debounced Autosave
To prevent I/O thrashing during continuous scrubber dragging or rapid color grading slider adjustments, the Editor Workspace employs an asynchronous debounced autosave:
- Every state mutation triggers a 1,200ms debounce timer.
- Unsaved changes are marked with an indicator in the editor title bar.
- Navigation away or app lifecycle suspension triggers immediate synchronous flush.

---

## 6. Color Science & Visual Pipeline

RangYantra Studio implements a cinema-grade color processing model:
- **Exposure**: $-3.0$ to $+3.0$ EV stops.
- **Contrast**: $0.5$ to $2.0$ contrast ratio.
- **Saturation**: $0.0$ (monochrome) to $2.0$ (super-saturated).
- **Color Temperature**: $2000\text{ K}$ to $10000\text{ K}$ Kelvin shift.
- **Highlights & Shadows**: Dual-curve selective tonal range adjustments.
- **Vibrance**: Non-linear skin-tone preserving saturation boost.

Live preview renders via GPU-accelerated shader matrices, preserving raw clip frames intact for pristine export.

---

## 7. Security, Privacy & App Store Compliance

1. **Zero External Data Transmission**: No video, audio, title, or project metadata is ever uploaded to a remote server.
2. **Explicit Android & iOS Permissions**:
   - `android.permission.READ_MEDIA_VIDEO`, `READ_MEDIA_AUDIO`, `READ_MEDIA_IMAGES` (scoped storage).
   - `NSPhotoLibraryUsageDescription`, `NSCameraUsageDescription`, `NSMicrophoneUsageDescription` with clear, transparent purpose explanations.
3. **No Hidden Cloud Subscriptions or Key Dependencies**: Features described in the AI Studio are designed around on-device inference (ONNX Runtime / MediaPipe / CoreML) ensuring longevity and reliability without API fee paywalls.
