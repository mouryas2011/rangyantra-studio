# RangYantra Studio (रंगयंत्र स्टूडियो) — Product Roadmap

**"From Imagination to Cinema" • "कल्पना से सिनेमा तक"**

---

## Roadmap Overview

RangYantra Studio follows a rigorous milestone-driven engineering plan designed to deliver a stable, full-featured mobile video editing and motion graphics suite ready for Google Play Store and Apple App Store distribution.

---

## Milestone Status Summary

| Milestone | Title | Focus Area | Status |
| :--- | :--- | :--- | :--- |
| **Milestone 1** | **Foundation & Core Architecture** | Brand identity, modular monorepo, schema v1, precision timebase, commands, SQLite, dashboard, workspace | **COMPLETED & VERIFIED** |
| **Milestone 2** | **Native Playback & Surface Preview** | Android Media3/SurfaceTexture, iOS AVFoundation/Metal, real-time audio sync, thumbnail strip generation | **NEXT (In Development)** |
| **Milestone 3** | **Motion Graphics & Compositing** | Bezier keyframing, text typography engine, blend modes, vector shapes, sticker/watermark overlays | Scheduled |
| **Milestone 4** | **Color Grading & Audio Studio** | 3-way color wheels, LUT import (.cube), multitrack audio mixer, parametric EQ, noise reduction | Scheduled |
| **Milestone 5** | **On-Device AI Creative Suite** | Silence remover, auto speech-to-text captions (Whisper on-device), beat detection, smart framing | Scheduled |
| **Milestone 6** | **Hardware Export Engine** | Android Media3 Transformer, iOS VideoToolbox, 4K 60fps ProRes/H.264/HEVC, custom bitrate presets | Scheduled |
| **Milestone 7** | **Store Polish & Production Release** | App Store & Google Play metadata, automated CI/CD fastlane, crash reporting, final store bundles | Scheduled |

---

## Detailed Milestone Deliverables

### Milestone 1: Foundation & Core Architecture (COMPLETED)
- [x] Full development environment discovery & alignment (Flutter 3.47.7, Dart 3.13.5, JDK 17, Android SDK 36.0.0).
- [x] Vector brand identity: Primary logo, compact glyph, monochrome variants, Android mipmaps (`mdpi` to `xxxhdpi`), iOS `AppIcon.appiconset`.
- [x] Native splash and launch configurations for Android (`launch_background.xml`) and iOS (`LaunchScreen.storyboard`).
- [x] Schema Version 1 JSON project model with forward migration pipeline (`packages/project_model`).
- [x] Microsecond-accurate rational timebase and SMPTE 12M timecode generator (`packages/timeline_engine`).
- [x] Non-destructive undo/redo command hierarchy with speed-aware duration recalculation (`packages/editing_commands`).
- [x] Native media bridge abstraction and asset import pipeline (`packages/media_bridge`).
- [x] Local SQLite persistence with WAL mode and foreign key integrity (`apps/mobile/lib/data`).
- [x] Home Dashboard screen with search, project CRUD, template loader, and media import.
- [x] Editor Workspace screen with preview canvas, transport bar, multitrack timeline lanes, scrubber, and debounced autosave.
- [x] AI Studio, Template Library (4 starter formats), and Settings & Diagnostics screens.
- [x] 100% automated test coverage across all packages (27/27 unit & widget tests passing).
- [x] 0 analyzer warnings or errors (`flutter analyze` clean).

### Milestone 2: Native Playback & Surface Preview (NEXT)
- [ ] Implement `AndroidMediaEngine` using AndroidX Media3 `ExoPlayer` and `SurfaceProducer` / Flutter `Texture` widget.
- [ ] Implement `IOSMediaEngine` using Apple `AVPlayer` and Metal-backed `FlutterTexture`.
- [ ] Frame-accurate seeking with zero-latency scrubbing preview.
- [ ] Dynamic waveform generator and video thumbnail strip caching pipeline.
- [ ] Real-time audio playback synchronization with variable speed playback ($0.25\times$ to $8.0\times$).

### Milestone 3: Motion Graphics & Compositing
- [ ] Universal Keyframe interpolator supporting Linear, Ease-In, Ease-Out, and custom Cubic Bezier curves.
- [ ] Advanced Text Engine: Google Fonts integration, Hindi/Devanagari font rendering, stroke, shadow, glow, and typewriter animations.
- [ ] Layer compositing with 12 blend modes (Normal, Multiply, Screen, Overlay, Darken, Lighten, Color Dodge, Color Burn, Soft Light, Hard Light, Difference, Exclusion).
- [ ] Vector shape generators (rectangles, circles, stars, callout bubbles, speech arrows).

### Milestone 4: Color Science & Audio Suite
- [ ] Real-time OpenGL ES / Metal shader color grading pipeline.
- [ ] 3-Way Color Wheels for Lift, Gamma, and Gain grading.
- [ ] 3D LUT loader supporting standard `.cube` lookup tables with intensity blend.
- [ ] Multitrack audio mixer with volume faders, stereo panning, mute, and solo.
- [ ] 3-band parametric equalizer and high-pass/low-pass audio filters.

### Milestone 5: On-Device AI Creative Suite
- [ ] On-device voice activity detection (VAD) for automatic silence removal and jump-cut generation.
- [ ] On-device speech recognition (quantized Whisper model) producing synchronized subtitles and animated captions.
- [ ] Audio onset and transient analysis for musical beat detection and marker snapping.
- [ ] Face detection and tracking for automatic vertical (9:16) re-framing of landscape clips.

### Milestone 6: Hardware-Accelerated Export Engine
- [ ] Android Media3 `Transformer` pipeline with hardware `MediaCodec` encoders (AVC/H.264, HEVC/H.265).
- [ ] iOS `AVAssetExportSession` / `AVAssetWriter` pipeline with Apple VideoToolbox.
- [ ] Export presets for YouTube (16:9 4K/1080p), Instagram Reels / TikTok (9:16 1080p), and Cinema Scope (2.39:1).
- [ ] Real-time export progress monitoring with estimated time remaining and background task persistence.

### Milestone 7: Store Polish & Release Engineering
- [ ] Fastlane automation for Android AAB signing and iOS Archive builds.
- [ ] Localized App Store and Google Play Store metadata, promotional screenshots, and preview videos.
- [ ] Privacy Manifest compliance (`PrivacyInfo.xcprivacy` for iOS, Data Safety for Google Play).
- [ ] Final release verification, stress testing on physical devices, and Play Console / App Store Connect submission.
