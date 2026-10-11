# RangYantra Studio (रंगयंत्र स्टूडियो) — Privacy Policy & Local-First Guarantee

**"From Imagination to Cinema" • "कल्पना से सिनेमा तक"**

**Last Updated:** October 2026  
**Applicability:** RangYantra Studio for Android and iOS

---

## 1. Core Commitment: 100% Local-First Sovereignty

RangYantra Studio is built on an uncompromising commitment to creative privacy and digital sovereignty. We believe that your video footage, audio recordings, creative drafts, and personal media belong entirely to you.

- **No Remote Video Uploads**: RangYantra Studio never uploads, streams, or transfers your video or audio files to any remote server or cloud infrastructure.
- **No Account Mandatory**: The application requires no sign-up, email registration, phone verification, or identity tracking to operate.
- **No Telemetry or Tracking**: There are no analytics SDKs, behavioral tracking beacons, or telemetry agents embedded within RangYantra Studio.
- **Offline Functionality**: All editing, trimming, color grading, audio mixing, project serialization, and video export operations execute 100% offline on your device hardware.

---

## 2. On-Device Data Storage

All data created or imported within RangYantra Studio is stored within the application's secure on-device sandboxed directories:
- **Project Database (`rangyantra_studio.db`)**: Local SQLite database storing project metadata, track configurations, and edit lists.
- **Exported Videos**: Rendered files are saved directly to your device's local gallery or user-chosen export directory.
- **Cache & Temporary Files**: Temporary preview frames and waveforms reside strictly in temporary cache storage and can be cleared at any time via **Settings > Storage**.

---

## 3. Device Permissions & Transparent Usage

RangYantra Studio requests only the minimal permissions required to provide video editing capabilities:

### Android Permissions
- `READ_MEDIA_VIDEO`: Required to browse and import video files from your device storage.
- `READ_MEDIA_AUDIO`: Required to import music, voiceovers, and sound effects from your device storage.
- `READ_MEDIA_IMAGES`: Required to import photos, logos, and graphic overlays.
- `RECORD_AUDIO`: Optional; requested only if you record live voiceovers directly within the editor.
- `CAMERA`: Optional; requested only if you record video directly into the timeline.

### iOS Permissions
- `NSPhotoLibraryUsageDescription`: "RangYantra Studio requires access to your photo library to import video clips, photos, and music for editing, and to save rendered video exports to your camera roll."
- `NSCameraUsageDescription`: "RangYantra Studio requires camera access if you choose to record video directly into your editing project."
- `NSMicrophoneUsageDescription`: "RangYantra Studio requires microphone access if you record voiceover audio or capture video with live sound."

---

## 4. On-Device AI Privacy

Tools in the AI Studio (such as automated silence removal, caption generation, and smart reframing) are designed to execute using on-device machine learning models (CoreML on iOS, NNAPI/TFLite/MediaPipe on Android). No speech or image data is sent to external API endpoints.

---

## 5. Contact & Support

For privacy inquiries or technical verification of our open-source architecture:
- **Repository**: [https://github.com/vfxartistarun/Rangmanchapp](https://github.com/vfxartistarun/Rangmanchapp)
- **License**: Apache License 2.0 (Open Source)
