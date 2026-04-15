//
//  LocalizationHelper.swift
//  Granulay
//
//  Created by Granulay Team
//

import Foundation

// MARK: - String Extension for Localization
extension String {
    /// Returns the localized string for the current key
    var localized: String {
        return NSLocalizedString(self, comment: "")
    }

    /// Returns the localized string with arguments
    func localized(with arguments: CVarArg...) -> String {
        return String(format: NSLocalizedString(self, comment: ""), arguments: arguments)
    }
}

// MARK: - Localization Keys
struct LocalizationKeys {

    // MARK: - App Info
    struct App {
        static let name = "app.name"
        static let tagline = "app.tagline"
        static let beta = "app.beta"
    }

    // MARK: - Menu Bar
    struct Menu {
        static let enableEffect = "menu.enable_effect"
        static let disableEffect = "menu.disable_effect"
        static let lofiStation = "menu.lofi_station"
        static let settings = "menu.settings"

        static let quit = "menu.quit"
    }

    // MARK: - Settings
    struct Settings {
        static let windowTitle = "settings.window_title"
        static let shellSubtitle = "settings.shell.subtitle"
        static let title = "settings.title"
        static let enableEffect = "settings.enable_effect"
        static let intensity = "settings.intensity"
        static let preserveBrightness = "settings.preserve_brightness"
        static let preserveBrightnessDescription = "settings.preserve_brightness.description"
        static let advanced = "settings.advanced"
        static let saveAutomatically = "settings.save_automatically"
        static let saveAutomaticallyDescription = "settings.save_automatically.description"
        static let showInDock = "settings.show_in_dock"
        static let showInDockDescription = "settings.show_in_dock.description"

        static let reset = "settings.reset"
        static let resetDescription = "settings.reset.description"
        static let export = "settings.export"
        static let exportDescription = "settings.export.description"
        static let importSettings = "settings.import"
        static let importDescription = "settings.import.description"

        // MARK: - Categories
        struct Category {
            static let appearance = "settings.category.appearance"
            static let behavior = "settings.category.behavior"
            static let lofi = "settings.category.lofi"
            static let purchase = "settings.category.purchase"
        }

        // MARK: - Section Titles and Descriptions
        struct Appearance {
            static let title = "settings.appearance.title"
            static let description = "settings.appearance.description"
            static let motionTitle = "settings.appearance.motion_title"
            static let motionMoving = "settings.appearance.motion_moving"
            static let motionStatic = "settings.appearance.motion_static"
            static let matteMode = "settings.appearance.matte_mode"
            static let matteModeDescription = "settings.appearance.matte_mode.description"
            static let grainTitle = "settings.appearance.grain_section_title"
            static let matteTitle = "settings.appearance.matte_section_title"
            static let matteSectionDescription = "settings.appearance.matte_section_description"
        }

        struct Behavior {
            static let title = "settings.behavior.title"
            static let description = "settings.behavior.description"
            static let resetTitle = "settings.behavior.reset_title"
            static let resetDescription = "settings.behavior.reset_description"
        }



        struct LoFiSection {
            static let title = "settings.lofi.title"
            static let description = "settings.lofi.description"
        }

        // MARK: - Intensity
        struct Intensity {
            static let weak = "settings.intensity.weak"
            static let medium = "settings.intensity.medium"
            static let strong = "settings.intensity.strong"
        }

    }

    // MARK: - Loading
    struct Loading {
        static let applyingChanges = "loading.applying_changes"
        static let resetting = "loading.resetting"
        static let exporting = "loading.exporting"
        static let importing = "loading.importing"
    }

    // MARK: - Alerts
    struct Alert {
        struct Reset {
            static let title = "alert.reset.title"
            static let message = "alert.reset.message"
            static let confirm = "alert.reset.confirm"
            static let cancel = "alert.reset.cancel"
        }

        struct Export {
            static let success = "alert.export.success"
        }

        struct Import {
            static let success = "alert.import.success"
            static let error = "alert.import.error"
        }
    }

    // MARK: - Lo-Fi Music
    struct LoFi {
        static let title = "lofi.title"
        static let playing = "lofi.playing"
        static let stopped = "lofi.stopped"
        static let volume = "lofi.volume"
        static let station = "lofi.station"
        static let play = "lofi.play"
        static let pause = "lofi.pause"
        static let stop = "lofi.stop"
        static let previousStation = "lofi.previous_station"
        static let nextStation = "lofi.next_station"
    }

    // MARK: - File Operations
    struct File {
        struct Export {
            static let title = "file.export.title"
        }

        struct Import {
            static let title = "file.import.title"
        }

        struct Settings {
            static let fileExtension = "file.settings.extension"
        }
    }
}
