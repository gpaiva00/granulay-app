# Documentation Update Summary

## Overview
This update fundamentally overhauls Granulay's technical and product documentation, aligning it with the latest codebase realities. All project-level markdown documents have been translated from Portuguese to English to support international development, and critical Swift modules now include clear, intent-focused inline documentation.

## Project-Level Markdown Changes

1. **`README.md`**
   - Translated fully to English.
   - Added a "Documentation Map" section indicating where contributors should look for specific information.
   - Clarified the soft-disabled status of the Lo-Fi feature.
   - Updated the Technology stack, metrics, and architecture references.

2. **`PRD.md`**
   - Translated fully to English.
   - Realigned the feature list, user flows, and acceptance criteria to match the current product boundaries (e.g., Trial vs. Full).
   - Documented the current status of each phase.

3. **`CLAUDE.md`**
   - Updated the guidance rules for AI agents.
   - Explicitly highlighted the missing S3 bucket issue and the soft-disabled state of the Lo-Fi player.
   - Added a redirect to the new architecture document for deep structural analysis.

4. **`ARCHITECTURE.md` (NEW)**
   - Created a comprehensive architectural document.
   - Included a Mermaid sequence diagram showing the execution flow from application startup to pixel rendering.
   - Documented the core AppKit/SwiftUI separation of concerns (no main window, pure Menu Bar execution).
   - Detailed the procedural noise generation and LRU texture caching strategy.
   - Added a dedicated section explaining how the Lo-Fi module works and how to re-enable it.

## Code-Level Enhancements (Swift Files)

Intent-based documentation and module-level descriptions were added to the following core files:

1. **`MenuBarManager.swift`**
   - Documented its role as the central `ObservableObject` and single source of truth.
   - Explained debouncing mechanisms and state sync handling.
2. **`GrainOverlayWindow.swift`**
   - Documented the lifecycle management of `NSWindow` overlays across `NSScreen` instances.
   - Clarified the non-intrusive attributes (e.g., ignoring mouse events).
3. **`GrainEffect.swift`**
   - Documented the `GrainRenderTuning` configuration.
   - Added explanations for `GrainTextureCache` and its LRU policy.
   - Documented the procedural generation functions: `createFineGrainFrame` (spatial correlation) vs. `createMatteGrainFrame` (haze with sparkles).
   - Documented `GrainLayerView` and its temporal jitter implementation.
4. **`PerformanceOptimizer.swift`**
   - Documented the FPS monitoring loop and how it dynamically dials down rendering frequency under load.
5. **`LoFiMusicManager.swift`**
   - Added a clear header explicitly declaring the feature "SOFT-DISABLED" and outlined the 3 steps required to restore it.
6. **Settings Views**
   - Added module-level docstrings to `SettingsState.swift`, `SettingsPanels.swift`, and `SettingsShellView.swift` to clarify their specific UI responsibilities separate from the core `MenuBarManager`.

## Open Documentation Gaps & Required Decisions
- **Lo-Fi Feature Resolution**: The project owner needs to decide whether to restore the S3 bucket, switch to local bundled files, or permanently remove the `LoFiMusicManager` to clean up the codebase.
- **Trial Distribution Mechanism**: While the PRD mentions a Trial version, the actual build flow might need technical validation if Gumroad is still the primary distribution platform compared to the App Store.