# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Granulay is a macOS menu bar app that applies a real-time vintage grain effect as a transparent overlay over all screens. It is distributed via the App Store and as a direct download trial. The full app (Bundle ID: `com.granulay.app`) and trial app (Bundle ID: `com.granulay.trial`) are built from the same codebase using build configurations.

## Build Commands

```bash
# Full version (Release)
xcodebuild -project Granulay.xcodeproj -scheme Granulay -configuration Release

# Trial version
./build-trial.sh
# or directly:
xcodebuild -project Granulay.xcodeproj -target Granulay -configuration "Trial Debug" build
```

There are no automated tests (swift test exists in CI but the project does not have a test target). Build configurations are: Debug, Release, Trial Debug.

## Architecture

The app is a SwiftUI + AppKit macOS app with no app window — it lives entirely in the menu bar.

**Entry point:** `GranulayApp.swift` — creates `MenuBarManager` as a `@StateObject` and provides a `Settings` scene.

**Core components:**

- **`MenuBarManager`** — Central `ObservableObject`. Owns the `NSStatusItem`, manages the `GrainOverlayWindow`, opens the settings window, and holds all published state (`isGrainEnabled`, `grainIntensity`, `isGrainAnimated`, `isMatteModeEnabled`, `preserveBrightness`, `showInDock`). Enforces trial limitations on every `didSet`. Settings are persisted via `UserDefaults`.

- **`GrainOverlayWindow`** / **`GrainEffect`** / **`GrainTextureCache`** — Transparent `NSWindow` overlay that renders grain using Core Image and Metal. `GrainEffect` defines parameters like `intensity` and handles two presentation modes: animated vs static (`isGrainAnimated`) and normal vs matte (`isMatteMode`). `GrainTextureCache` is a shared singleton that maintains LRU-cached texture atlases per display, building specific frames for normal grain vs matte grain modes.

- **`TrialConfig`** — Central feature-flag struct. Uses `#if TRIAL_VERSION` compiler flag to gate features. Check `TrialConfig.isTrialVersion`, `allowedGrainStyles`, `canPreserveBrightness`, `isLoFiEnabled`, and `isBehaviorSectionEnabled` before gating any UI or behavior.

- **`LoFiMusicManager`** — Singleton managing AVFoundation playback of 20 royalty-free tracks hosted on S3. Only available in the full version.

- **`PerformanceOptimizer`** — Shared singleton that monitors FPS and adjusts grain rendering.

**Settings UI architecture** (recently refactored into multiple files):

- `SettingsView.swift` — Top-level view; selects which panel to show.
- `SettingsShellView.swift` — Layout shell (sidebar + content area).
- `SettingsState.swift` — `SettingsState` ObservableObject (selected section, loading state, feedback draft) and `SettingsSection` enum with trial-lock logic.
- `SettingsPanels.swift` — Panel views: `AppearanceSettingsPanel`, `BehaviorSettingsPanel`, `LoFiSettingsPanel`, `SupportSettingsPanel`.
- `SettingsComponents.swift` — Reusable UI components: `SettingsCard`, `SettingsSectionHeader`, `SettingsSidebarRow`, `SettingsBadge`, etc.
- `SettingsTheme.swift` — `SettingsTheme` enum (colors, animations) and `SettingsLayoutMetrics` struct (dimensions).

## Localization

All user-facing strings go through `LocalizationKeys` (in `LocalizationHelper.swift`) as dot-notation string constants (e.g., `LocalizationKeys.Settings.Category.appearance`). Strings are resolved with the `.localized` extension on `String`. Localization files are at `Granulay/en.lproj/Localizable.strings` and `Granulay/pt-BR.lproj/Localizable.strings`. Always add new keys to both files.

## Trial vs Full Version

Feature gating is enforced via `TrialConfig`. In the trial build:
- `preserveBrightness` is locked/false.
- `isMatteModeEnabled` is locked/false.
- Lo-Fi station is hidden.
- Behavior settings section is locked (redirects to purchase screen).
- The `purchase` section is visible in the sidebar only for trial.

The `SettingsSection.isLockedInTrial` property and `SettingsSection.visibleSections` computed var control sidebar visibility and lock state.

## Key Conventions

- `MenuBarManager` is the single source of truth for all grain/app state; pass it via `.environmentObject`.
- `SettingsState` is scoped to the settings window only (navigation state, loading, feedback).
- Animations and colors come from `SettingsTheme`; layout dimensions from `SettingsLayoutMetrics` — do not hardcode values.
- Team ID: `TB76NB7VWG`. App Store URL: `https://apps.apple.com/br/app/granulay/id6751862804?mt=12Granulay`.

## Development Workflow

After completing any implementation or bug fix, always run the hot reload script to test the changes immediately:

```bash
./rebuild.sh
```

This script will:
1. Stop the currently running app instance
2. Compile the project with Release configuration
3. Open the updated app automatically

This ensures you can validate changes without opening Xcode.
