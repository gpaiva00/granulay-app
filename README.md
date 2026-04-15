# Granulay

**Vintage grain effect** - An application that adds a real-time vintage grain effect to your entire screen, providing a nostalgic and cinematic visual experience.

## 🎯 Value Proposition

- **Unique Visual Experience**: Transforms any screen into a vintage cinematic experience.
- **Ease of Use**: Simple controls via the menu bar.
- **Advanced Customization**: Multiple grain styles and intensities.
- **Lo-Fi Functionality**: Integrated ambient music for a complete experience *(Note: Currently soft-disabled)*.
- **Optimized Performance**: Efficient use of system resources.

## Features

- 🎨 **Vintage grain effect** for the entire screen
- ⚙️ **Customizable settings** for intensity and style  
- 🖥️ **Multi-monitor support** with independent settings
- 🔧 **Menu bar integration** for quick access
- 💡 **Brightness preservation option**
- 🎯 **2 grain modes:** Normal and Matte (with fine control over intensity)
- 🎵 **Integrated Lo-Fi Station** for ambient music *(Note: Currently soft-disabled)*
- 🌍 **Full localization** in English and Brazilian Portuguese

## 🗺️ Documentation Map

To help contributors and AI agents understand the project, we maintain the following documentation:

- [**`README.md`**](README.md) - Project overview, features, and setup instructions.
- [**`ARCHITECTURE.md`**](ARCHITECTURE.md) - High-level architecture, module responsibilities, and execution flows.
- [**`PRD.md`**](PRD.md) - Product Requirements Document (historical and current goals).
- [**`CLAUDE.md`**](CLAUDE.md) - Guidelines for AI agents (Claude/Cursor) working in this repository.

## 📦 Installation and Distribution

### App Store (Recommended)
The project is distributed through **App Store Connect** to ensure maximum compatibility and security:

- ✅ **Official App Store** - Reliable and secure distribution
- ✅ **Digital Signature** certified by Apple
- ✅ **Automatic Updates** via the App Store
- ✅ **Simplified Installation** with one click

### Getting Started
1. **Install** the application via the App Store.
2. **Open** Granulay - it will appear in the menu bar.
3. **Click** the icon in the menu bar.
4. **Select** "Enable Effect" to activate the grain effect.
5. **Access** "Settings" to customize your experience.

## Available Versions

### Trial Version
- **Grain Effect**: Limited intensity (0.1-0.3).
- **Features**: Basic interface and essential settings.
- **Lo-Fi Station**: Not available.
- **Advanced Settings**: Limited.

### Full Version
- **Full Intensity**: 0.1 to 1.0 (Weak, Medium, Strong).
- **Matte Mode**: Available.
- **Lo-Fi Station**: 20 royalty-free tracks with advanced controls *(Currently soft-disabled due to S3 bucket unavailability)*.
- **Advanced Settings**: Full access to all options.
- **Brightness Preservation**: Available.

## Project Build

### Trial Build
```bash
./build-trial.sh  # Compiles trial version
```

### Full Build
```bash
# Build via Xcode
xcodebuild -project Granulay.xcodeproj -scheme Granulay -configuration Release
```

## System Requirements

- **Operating System**: macOS 13.0 (Ventura) or higher.
- **Architecture**: Apple Silicon (M1/M2/M3) and Intel x86_64.
- **Memory**: 4GB RAM minimum.
- **Monitors**: Support for multiple displays up to 8K.
- **GPU**: Hardware acceleration recommended.

## Development

### Environment Setup
1. **Xcode 15.0+** with macOS 13.0+ support.
2. **Apple Developer Certificates** configured.
3. **Team ID**: TB76NB7VWG.

### Project Structure
- **SwiftUI + AppKit**: Modern and native interface.
- **Core Image + Metal**: Optimized rendering of the grain effect.
- **AVFoundation**: Lo-Fi audio system.
- **Combine**: Reactivity and state management.

### Available Scripts
- `./build-trial.sh` - Build the trial version.
- `./check-config.sh` - Configuration verification.

### Security and Compliance
- **App Sandbox**: Enabled for maximum security.
- **Code Signing**: Apple Distribution Certificate.
- **Hardened Runtime**: Additional protection against malware.
- **Privacy**: No personal data collected.
- **Team ID**: TB76NB7VWG.

## Technologies Used

- **Swift 5.9+**: Main language.
- **SwiftUI**: Modern user interface.
- **AppKit**: Native system integration.
- **Core Image**: Image processing.
- **Metal**: Graphics acceleration.
- **AVFoundation**: Audio playback.
- **Combine**: Reactive programming.

## Performance and Optimization

- **CPU**: Maximum 5% usage in normal operation.
- **Memory**: Maximum 100MB RAM consumption.
- **GPU**: Efficient use of hardware acceleration.
- **Latency**: Instant response (<50ms) for effect toggle.
- **Availability**: 99.9% uptime.
- **Recovery**: Automatic crash recovery in <5 seconds.
- **Compatibility**: Apple Silicon and Intel x86_64.

## Core Features

### Vintage Grain Effect
- **Real-time rendering** with no noticeable lag.
- **Transparent overlay** that does not interfere with other apps.
- **Multi-monitor support** with independent settings.
- **Normal and Matte styles**.
- **Intensity control**: 0.1 to 1.0 (Weak, Medium, Strong).
- **Brightness preservation**: Maintains original screen luminosity.

### Integrated Lo-Fi Station *(Soft-disabled)*
*Note: This feature is currently disabled in the codebase due to a lost S3 bucket. It can be re-enabled by restoring the bucket and reverting the UI visibility changes.*
- **20 royalty-free tracks** of ambient Lo-Fi music.
- **Full controls**: Play/Pause/Stop/Previous/Next/Shuffle/Repeat.
- **Independent volume** from the system.
- **Menu bar integration** for quick access.
- **Artist credits** accessible in the interface.

**Licensed Music**: Exclusively uses royalty-free tracks from Pixabay. Full license documentation is available in `Pixabay_Music_License_Documentation.md`.

### Interface and Usability
- **Menu bar**: Quick and non-intrusive access.
- **Instant toggle**: Enable/disable with one click.
- **Advanced settings**: Modern SwiftUI interface.
- **Real-time preview**: Immediate visualization of changes.
- **Accessibility**: Full VoiceOver support.

## 🎨 Target Audience

- **Primary**: Content creators, designers, photographers.
- **Secondary**: Vintage aesthetic enthusiasts, users looking for a distinct visual experience.
- **Tertiary**: Professionals who work long hours and want to reduce visual fatigue.

## 🚀 Roadmap

### Future Features
- **New grain styles**: Expansion of the effects library.
- **Customizable presets**: Settings saved by the user.
- **Spotify/Apple Music integration**: External music control.
- **Global keyboard shortcuts**: Control without using the mouse.
- **Automatic dark/light mode**: Adaptation to the system theme.

## 📞 Support

For technical support, questions, or suggestions:
- **Documentation**: Available in the "Help" menu of the application.

## License

All rights reserved © 2025 Gabriel Paiva
