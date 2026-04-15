# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) and other AI agents when working with code in this repository.

## Project Overview

Granulay is a macOS menu bar app that applies a real-time vintage grain effect as a transparent overlay over all screens. It is distributed via the App Store (Bundle ID: `com.granulay.app`).

## Documentation Map

Before making architectural changes or exploring the codebase, please review the following:
- **`ARCHITECTURE.md`**: Start here to understand the execution flow, the `AppKit` + `SwiftUI` hybrid setup, and the core modules rendering the grain effect.
- **`PRD.md`**: Context on product goals, historical decisions (e.g., Trial vs. Full versions), and non-functional requirements.
- **`README.md`**: Quick start, build instructions, and feature overview.

## Build Commands

```bash
xcodebuild -project Granulay.xcodeproj -scheme Granulay -configuration Release
```

There are no automated tests (swift test exists in CI but the project does not have a test target). Build configurations are: `Debug`, `Release`.

## Architecture Overview

*For full details, please refer to `ARCHITECTURE.md`.*

The app is a `SwiftUI` + `AppKit` macOS app with no main application window — it lives entirely in the menu bar.

**Core components summary:**
- **`MenuBarManager`** — Central `ObservableObject`, single source of truth for app state.
- **`GrainOverlayWindow`** & **`GrainEffect`** — Transparent `NSWindow` overlay rendering the grain using Core Image and Metal.
- **`GrainTextureCache`** — Shared singleton for LRU-cached texture atlases.
- **`PerformanceOptimizer`** — Monitors FPS and adjusts grain rendering.
- **`LoFiMusicManager`** — **CURRENTLY SOFT-DISABLED** (S3 bucket lost). Hidden from UI and disabled in code. To re-enable, restore the bucket, add the public read policy, and revert the UI hiding changes. Do not attempt to use this module without explicit user instruction.

## Localization

All user-facing strings go through `LocalizationKeys` (in `LocalizationHelper.swift`) as dot-notation string constants (e.g., `LocalizationKeys.Settings.Category.appearance`). Strings are resolved with the `.localized` extension on `String`. Localization files are at `Granulay/en.lproj/Localizable.strings` and `Granulay/pt-BR.lproj/Localizable.strings`. Always add new keys to both files.

## Key Conventions

- **State Management**: `MenuBarManager` is the single source of truth for all grain/app state. Always pass it via `.environmentObject`.
- **UI State**: `SettingsState` is scoped to the settings window only (navigation state, loading, feedback).
- **Styling**: Animations and colors come from `SettingsTheme`; layout dimensions from `SettingsLayoutMetrics` — do not hardcode these values.
- **Team ID**: `TB76NB7VWG`. 
- **App Store URL**: `https://apps.apple.com/br/app/granulay/id6751862804?mt=12Granulay`.
- **In-code Documentation**: When adding or updating code, ensure public APIs, complex logic, and key configuration structs have clear English documentation explaining their *intent* and *side effects*.