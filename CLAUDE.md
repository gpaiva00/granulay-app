# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Granulay is a macOS menu bar app that applies a real-time vintage grain effect as a transparent overlay over all screens. It is distributed via the App Store (Bundle ID: `com.granulay.app`).

## Build Commands

```bash
xcodebuild -project Granulay.xcodeproj -scheme Granulay -configuration Release
```

There are no automated tests (swift test exists in CI but the project does not have a test target). Build configurations are: Debug, Release.

## Architecture

The app is a SwiftUI + AppKit macOS app with no app window — it lives entirely in the menu bar.

**Entry point:** `GranulayApp.swift` — creates `MenuBarManager` as a `@StateObject` and provides a `Settings` scene.

**Core components:**

- **`MenuBarManager`** — Central `ObservableObject`. Owns the `NSStatusItem`, manages the `GrainOverlayWindow`, opens the settings window, and holds all published state (`isGrainEnabled`, `grainIntensity`, `isGrainAnimated`, `isMatteModeEnabled`, `preserveBrightness`, `showInDock`). Settings are persisted via `UserDefaults`.

- **`GrainOverlayWindow`** / **`GrainEffect`** / **`GrainTextureCache`** — Transparent `NSWindow` overlay that renders grain using Core Image and Metal. `GrainEffect` defines parameters like `intensity` and handles two presentation modes: animated vs static (`isGrainAnimated`) and normal vs matte (`isMatteMode`). `GrainTextureCache` is a shared singleton that maintains LRU-cached texture atlases per display, building specific frames for normal grain vs matte grain modes.

- **`LoFiMusicManager`** — Singleton managing AVFoundation playback of 20 royalty-free tracks hosted on S3. **Currently soft-deleted** (S3 bucket lost): hidden from sidebar (`SettingsState.visibleSections`) and menu bar (`MenuBarManager`). To re-enable, restore the bucket, add the public read policy, and revert those two changes.

- **`PerformanceOptimizer`** — Shared singleton that monitors FPS and adjusts grain rendering.

**Settings UI architecture** (recently refactored into multiple files):

- `SettingsView.swift` — Top-level view; selects which panel to show.
- `SettingsShellView.swift` — Layout shell (sidebar + content area).
- `SettingsState.swift` — `SettingsState` ObservableObject (selected section, loading state, feedback draft) and `SettingsSection` enum.
- `SettingsPanels.swift` — Panel views: `AppearanceSettingsPanel`, `BehaviorSettingsPanel`, `LoFiSettingsPanel`, `SupportSettingsPanel`.
- `SettingsComponents.swift` — Reusable UI components: `SettingsCard`, `SettingsSectionHeader`, `SettingsSidebarRow`, etc.
- `SettingsTheme.swift` — `SettingsTheme` enum (colors, animations) and `SettingsLayoutMetrics` struct (dimensions).

## Localization

All user-facing strings go through `LocalizationKeys` (in `LocalizationHelper.swift`) as dot-notation string constants (e.g., `LocalizationKeys.Settings.Category.appearance`). Strings are resolved with the `.localized` extension on `String`. Localization files are at `Granulay/en.lproj/Localizable.strings` and `Granulay/pt-BR.lproj/Localizable.strings`. Always add new keys to both files.

## Key Conventions

- `MenuBarManager` is the single source of truth for all grain/app state; pass it via `.environmentObject`.
- `SettingsState` is scoped to the settings window only (navigation state, loading, feedback).
- Animations and colors come from `SettingsTheme`; layout dimensions from `SettingsLayoutMetrics` — do not hardcode values.
- Team ID: `TB76NB7VWG`. App Store URL: `https://apps.apple.com/br/app/granulay/id6751862804?mt=12Granulay`.

