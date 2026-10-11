# RangYantra Studio (रंगयंत्र स्टूडियो)

> **"From Imagination to Cinema" • "कल्पना से सिनेमा तक"**

[![License](https://img.shields.io/badge/License-Apache_2.0-blue.svg)](LICENSE)
[![Flutter](https://img.shields.io/badge/Flutter-3.47.7-02569B.svg?logo=flutter)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.13.5-0175C2.svg?logo=dart)](https://dart.dev)
[![Tests](https://img.shields.io/badge/Tests-27%2F27_Passed_(100%25)-success.svg)]()
[![Analysis](https://img.shields.io/badge/Analysis-0_Errors_%7C_0_Warnings-success.svg)]()
[![Privacy](https://img.shields.io/badge/Privacy-100%25_Local--First-orange.svg)](docs/PRIVACY.md)

RangYantra Studio is an industrial-grade, genuinely functional, cross-platform mobile video editing and motion graphics application for Android and iOS. Built with Flutter, pure Dart domain packages, and hardware-accelerated native media pipelines (Android Media3 & Apple AVFoundation/Metal), RangYantra delivers non-linear desktop-class editing precision to mobile creators.

---

## 🎨 Brand Identity & Design System

The name **RangYantra (रंग + यंत्र)** blends color, artistic soul, and mechanical precision:

- **Deep Canvas Dark**: `#080B10` — Pure cinema grade dark background
- **Surface Navy**: `#111923` — Elevated panels and timeline beds
- **Primary Saffron**: `#FF7A00` — High-energy creative accent
- **Electric Cyan**: `#00D9FF` — Technological precision playhead & selection markers
- **Warm Gold**: `#FFC857` — Subtle badges and highlights

Typography is rendered using clean, geometric proportions:
- Display: Rajdhani / Orbitron / Inter
- Hindi Native: Devanagari script integration

---

## 🏛️ Monorepo Architecture

The codebase is organized into decoupled, modular packages:

```
Rangmanchapp/
├── apps/
│   └── mobile/                 # Flutter mobile application shell
│       ├── lib/
│       │   ├── core/           # Colors, typography, theme, and logo widgets
│       │   ├── data/           # SQLite persistence, repository, media import
│       │   └── presentation/   # Splash, Dashboard, Editor Workspace, AI, Templates
│       └── test/               # Widget & SQLite integration tests
├── packages/
│   ├── project_model/          # Schema v1 specification, JSON codec, migration pipeline
│   ├── timeline_engine/        # RationalTime, SMPTE 12M timecodes, snapping, controller
│   ├── editing_commands/       # Non-destructive command pattern (undo/redo stack)
│   └── media_bridge/           # Native platform bridge contracts & asset probing
├── assets/
│   ├── branding/               # Original SVGs (primary, compact, monochrome)
│   └── icons/                  # 1024x1024 and 512x512 master icons
└── docs/                       # Comprehensive architecture, roadmap, testing & privacy specs
```

---

## ✨ Key Features Implemented & Verified

### 1. Frame-Accurate Timebase & Rational Time
- Integer microsecond quantization (`int microseconds`) eliminates floating-point rounding drift.
- SMPTE 12M timecode formatter (`00:00:00:00`) for standard film and broadcast frame rates (24, 25, 29.97, 30, 60 fps).
- Snapping engine aligning playhead and clips to boundary thresholds.

### 2. Non-Destructive Editing Engine
- Transactional Command pattern with an atomic undo/redo history.
- **Split Clip**: Exact microsecond division preserving source in/out offsets and spatial transforms.
- **Trim Clip**: Head and tail trimming clamped to source media duration.
- **Speed Multiplier**: Instant $0.25\times$ to $8.0\times$ speed adjustment with reciprocal duration calculations.
- **Color Grading**: 8 live parameters (Exposure, Contrast, Saturation, Temperature, Tint, Highlights, Shadows, Vibrance).

### 3. Local SQLite Persistence
- Embedded SQLite engine running in WAL mode with foreign key integrity.
- Cross-platform support (`sqflite` on Android/iOS, `sqflite_common_ffi` on Linux/macOS/desktop and automated tests).
- 1,200ms debounced autosave preventing disk thrashing during rapid edits.

### 4. Professional User Interface
- **Home Dashboard**: Project search, aspect ratio filters, project creation modal, media import, duplication, renaming, deletion.
- **Editor Workspace**: Real-time canvas preview, SMPTE transport bar, zoomable multitrack timeline lanes, active clip inspector, editing toolbar.
- **AI Studio**: 100% free on-device tool suite (silence remover, auto-captions, musical beat detector, smart reframing).
- **Template Library**: 4 pre-configured presets (Cinema Scope 2.39:1, Reel 9:16, YouTube 16:9, Square 1:1).
- **Diagnostics**: Real-time SQLite engine probe, storage meter, and hardware codec inspection.

---

## 🧪 Testing & Quality Assurance

RangYantra Studio maintains a 100% passing automated test suite with 0 compiler or analyzer warnings.

### Running Automated Tests
```bash
# Set environment
export PATH="/home/livelihood/.local/tools/flutter/bin:/home/livelihood/.local/tools/jdk17/bin:$PATH"

# Run tests across all packages
(cd packages/project_model && flutter test)
(cd packages/timeline_engine && flutter test)
(cd packages/editing_commands && flutter test)
(cd packages/media_bridge && flutter test)
(cd apps/mobile && flutter test)
```

### Static Analysis
```bash
(cd packages/project_model && flutter analyze)
(cd packages/timeline_engine && flutter analyze)
(cd packages/editing_commands && flutter analyze)
(cd packages/media_bridge && flutter analyze)
(cd apps/mobile && flutter analyze)
```

---

## 🔒 Privacy & Data Sovereignty

RangYantra Studio guarantees **100% local processing**:
- Zero video uploads to remote clouds.
- No user accounts, registration, or tracking SDKs.
- Operates completely offline.
- Read our full [Privacy Policy](docs/PRIVACY.md).

---

## 📚 Documentation

- [System Architecture](docs/ARCHITECTURE.md)
- [Product Roadmap (Milestones 1–7)](docs/ROADMAP.md)
- [Testing Strategy & Test Matrix](docs/TESTING.md)
- [Feature Status Matrix](docs/FEATURE_STATUS.md)
- [Privacy Policy & Guarantee](docs/PRIVACY.md)

---

## 📄 License

Licensed under the Apache License, Version 2.0. See [LICENSE](LICENSE) for details.
