# PRD - Product Requirements Document
# Granulay - Vintage Grain Effect

## 📋 Product Overview

### Description
Granulay is an application that adds a real-time vintage grain effect to the entire screen, providing a nostalgic and cinematic visual experience. The application operates as a transparent overlay that can be easily toggled on/off via the menu bar.

### Value Proposition
- **Unique Visual Experience**: Transforms any screen into a vintage cinematic experience.
- **Ease of Use**: Simple control via the menu bar.
- **Advanced Customization**: Multiple grain styles and intensities.
- **Lo-Fi Functionality**: Integrated ambient music for a complete experience *(Note: Currently soft-disabled)*.
- **Optimized Performance**: Efficient use of system resources.

### Target Audience
- **Primary**: Content creators, designers, photographers.
- **Secondary**: Vintage aesthetic enthusiasts, users seeking a distinct visual experience.
- **Tertiary**: Professionals working long hours who wish to reduce visual fatigue.

---

## 🎯 Product Goals

### Primary Goals
1. Provide a high-quality vintage grain effect in real time.
2. Maintain optimized performance without significant system impact.
3. Offer an intuitive and non-intrusive interface.
4. Ensure compatibility with multiple monitors.

### Secondary Goals
1. Integrate ambient Lo-Fi music functionality *(Currently soft-disabled)*.
2. Implement an automatic update system.
3. Full localization support (EN/PT-BR).
4. Monetization strategy via a trial version.

---

## ⚙️ Functional Requirements

### FR001 - Grain Effect
**Description**: Apply a real-time vintage grain effect over the entire screen.

**Acceptance Criteria**:
- ✅ Transparent overlay that doesn't interfere with interaction in other apps.
- ✅ Real-time rendering with no noticeable lag.
- ✅ Support for multiple monitors with independent settings.
- ✅ 2 grain modes available: Normal and Matte.
- ✅ Intensity control from 0.1 to 1.0.
- ✅ Option to preserve screen brightness.

### FR002 - Control Interface
**Description**: Interface accessible through the menu bar.

**Acceptance Criteria**:
- ✅ Menu bar icon always visible.
- ✅ Contextual menu with main options.
- ✅ Quick toggle to enable/disable the effect.
- ✅ Direct access to settings.
- ✅ Visual indication of status (active/inactive).

### FR003 - Advanced Settings
**Description**: Comprehensive settings panel.

**Acceptance Criteria**:
- ✅ Modern and responsive SwiftUI interface.
- ✅ Organization by categories (Appearance, Behavior, Lo-Fi, Support).
- ✅ Real-time preview of changes.
- ✅ Automatic saving of settings.
- ✅ Reset option to default settings.

### FR004 - Lo-Fi System *(Soft-disabled)*
**Description**: Playback of ambient Lo-Fi music integrated with royalty-free tracks.

**Acceptance Criteria**:
- ✅ 20 royalty-free Lo-Fi tracks from Pixabay.
- ✅ Playback controls (Play/Pause/Stop/Previous/Next).
- ✅ Shuffle and repeat modes.
- ✅ Independent volume control.
- ✅ Integration with the menu bar.
- ✅ Artist credits accessible.
- ✅ Full commercial licensing.

### FR005 - Update System
**Description**: Checking and automatic installation of updates.

**Acceptance Criteria**:
- ✅ Automatic update checks.
- ✅ Notifications of new versions available.
- ✅ Automatic download and installation (optional).
- ✅ Integrated changelog.
- ✅ Rollback in case of issues.

### FR006 - Localization
**Description**: Full support for multiple languages.

**Acceptance Criteria**:
- ✅ English (EN) as the default language.
- ✅ Brazilian Portuguese (PT-BR).
- ✅ Automatic detection of the system language.
- ✅ All interface strings localized.
- ✅ Appropriate formatting for each language.

---

## 🚫 Non-Functional Requirements

### NFR001 - Performance
- **CPU**: Maximum 5% usage in normal operation.
- **Memory**: Maximum 100MB RAM consumption.
- **GPU**: Efficient use of hardware acceleration when available.
- **Latency**: Instant response (<50ms) for effect toggle.

### NFR002 - Compatibility
- **System**: macOS 13.0 (Ventura) or higher.
- **Architecture**: Apple Silicon (M1/M2/M3) and Intel x86_64.
- **Monitors**: Support for multiple displays up to 8K.
- **Memory**: Minimum 4GB RAM.

### NFR003 - Security
- **Sandbox**: App Sandbox enabled.
- **Permissions**: Only essential permissions requested.
- **Encryption**: HTTPS communication for updates.
- **Signature**: Code signing with Apple Developer certificate.

### NFR004 - Usability
- **Learning Time**: User should be able to use basic functionalities in <2 minutes.
- **Accessibility**: VoiceOver and keyboard navigation support.
- **Visual Feedback**: Clear indications of status and actions.
- **Consistency**: Interface following Apple's Human Interface Guidelines.

### NFR005 - Reliability
- **Availability**: 99.9% uptime (excluding scheduled maintenance).
- **Recovery**: Automatic crash recovery in <5 seconds.
- **Backup**: Settings saved automatically.
- **Logs**: Logging system for diagnostics.

---

## 🔄 Main User Flows

### Flow 1: First Use
```
1. User installs and opens the application.
2. System requests necessary permissions.
3. Application appears in the menu bar.
4. User clicks the menu bar icon.
5. Contextual menu is displayed.
6. User selects "Enable Effect".
7. Grain effect is applied immediately.
8. User can adjust settings via "Settings".
```

### Flow 2: Daily Use
```
1. User clicks the menu bar icon.
2. Quick toggle to enable/disable the effect.
3. Quick intensity adjustment (if necessary).
4. Settings persist between sessions.
```

### Flow 3: Advanced Configuration
```
1. User accesses "Settings" in the menu.
2. Settings window opens.
3. Tab navigation: Appearance, Behavior, Lo-Fi (if enabled), Support.
4. Changes applied in real time.
5. Settings saved automatically.
6. User closes the window, settings persist.
```

---

## 🎭 Trial Version Specifications

### Monetization Strategy
The trial version serves as a demonstration of the product's capabilities, encouraging the purchase of the full version through strategic limitations that do not compromise the basic experience.

### Implemented Limitations

#### L001 - Grain Effect
- **Intensity**: Limited from 0.1 to 0.3 (only "Weak").
- **Preserve Brightness**: Always disabled.
- **Justification**: Allows basic experience while maintaining an incentive for upgrade.

#### L002 - Features
- **Lo-Fi Station**: Completely disabled (menu hidden).
- **Behavior Section**: Disabled in settings.
- **Advanced Settings**: Limited access.
- **Justification**: Premium features reserved for the paid version.

#### L003 - Interface
- **App Name**: "Granulay Trial" (clear differentiation).
- **Bundle ID**: `com.granulay.trial` (technical separation).
- **Purchase Button**: Prominent in settings.
- **Version**: "1.0.0-trial" (clear identification).

### Technical Configuration

#### Build Configurations
- **Trial Debug**: For development and testing of the trial version.
- **Debug**: Full version for development.
- **Release**: Full version for production.

#### Compilation
```bash
# Full Version (Release)
xcodebuild -project Granulay.xcodeproj -target Granulay -configuration Release
```

### Trial User Experience

#### Onboarding
1. Simple installation via direct download.
2. First execution clearly shows limitations.
3. Basic experience functional immediately.
4. Call-to-action for upgrade well-positioned.

#### Visible Limitations
- Clear interface regarding trial status.
- Disabled sections with explanation.
- Purchase button always accessible.
- Trial vs. Full comparison on the purchase screen.

#### Conversion
- **Purchase URL**: `https://gabrielpaiva5.gumroad.com/l/granulay`
- **Price**: Lifetime access.
- **Proposition**: "💎 Full and lifetime access"

---

## 🚀 Full Version Specifications

### Unlocked Features

#### F001 - Full Grain Effect
- **Full Intensity**: 0.1 to 1.0 (Weak, Medium, Strong).
- **Preserve Brightness**: Option available.
- **Matte Mode**: Option available.
- **Advanced Settings**: Full access.

#### F002 - Full Lo-Fi System *(Soft-disabled)*
- **20 Royalty-Free Tracks**: High-quality Lo-Fi music from Pixabay.
- **Licensed Artists**: FASSounds, DELOSound, FreeMusicForVideo, Mikhail Smusev, and others.
- **Legal Compliance**: Full license documentation available in `Pixabay_Music_License_Documentation.md`.
- **Full Controls**: Play/Pause/Stop/Previous/Next/Shuffle/Repeat.
- **Volume Control**: 0-100%.
- **Menu Integration**: Full submenu in the bar.
- **Credits**: Full artist attribution in the interface.
- **Quality**: High-quality MP3 tracks hosted on S3.

#### F003 - Advanced Settings
- **Behavior Section**: Fully accessible.
- **Performance Settings**: Optimizations available.
- **Multiple Monitors**: Independent configuration.

#### F004 - Premium Updates
- **Automatic Updates**: No limitations.
- **Beta Access**: Early test versions.
- **Priority Support**: Direct channel with the developer.

### Technical Differentiation

#### Bundle Configuration
- **Bundle ID**: `com.granulay.app`
- **Name**: "Granulay"
- **Version**: Obtained from Bundle (`CFBundleShortVersionString`).

#### Feature Detection
```swift
// Intensity range
static var allowedIntensityRange: ClosedRange<Double> {
    return 0.1...1.0 // Full intensity
}

// Features
static var isLoFiEnabled: Bool {
    return true // Lo-Fi enabled
}
```

---

## 🏗️ Technical Architecture

See `ARCHITECTURE.md` for a comprehensive overview of the application architecture, data flow, and module responsibilities.

### Technological Stack
- **Framework**: SwiftUI + AppKit.
- **Language**: Swift 5.9+.
- **Minimum Deployment**: macOS 13.0.
- **Graphics**: Core Image + Metal.
- **Audio**: AVFoundation.
- **Networking**: URLSession.
- **Storage**: UserDefaults.

---

## 📊 Metrics and KPIs

### Product Metrics
- **Trial→Paid Conversion Rate**: Target 15-25%.
- **Daily Usage Time**: Target 2-4 hours.
- **D7 Retention**: Target 60%.
- **D30 Retention**: Target 40%.
- **NPS (Net Promoter Score)**: Target >50.

### Technical Metrics
- **Crash Rate**: <0.1%.
- **Startup Time**: <2 seconds.
- **CPU Usage**: <5% in normal operation.
- **Memory Usage**: <100MB.
- **UI Response Time**: <50ms.

---

## 🚀 Development Roadmap

### Phase 1: MVP (Completed) ✅
- [x] Basic grain effect
- [x] Menu bar interface
- [x] Basic settings
- [x] Trial/Full system

### Phase 2: Advanced Features (Completed) ✅
- [x] Lo-Fi system *(Currently soft-disabled)*
- [x] Multiple grain styles (Normal and Matte)
- [x] Advanced settings
- [x] Update system
- [x] PT-BR localization

### Phase 3: Polish and Launch (In Progress) 🔄
- [x] Performance optimizations
- [x] Extensive testing
- [x] App Store preparation
- [ ] Marketing and launch
- [ ] Initial feedback collection

### Phase 4: Expansion (Planned) 📋
- [ ] Customizable presets
- [ ] Spotify/Apple Music integration
- [ ] Global keyboard shortcuts
- [ ] Automatic dark/light mode

---

## 🎨 Design Specifications

### Visual Identity
- **Primary Colors**: System (adapts to native theme).
- **Icon**: Minimalist, represents grain/texture.
- **Typography**: SF Pro (native system).
- **Style**: Modern, clean, non-intrusive.

### Interface Guidelines
- **Principle**: Follow Apple's Human Interface Guidelines.
- **Accessibility**: Full VoiceOver support.
- **Responsiveness**: Adaptation to different screen sizes.
- **Consistency**: Consistent visual patterns throughout the app.

### UI Components
- **Menu Bar**: Discreet icon, intuitive contextual menu.
- **Settings Window**: Tabbed layout, native controls.
- **Sliders**: Real-time visual feedback.
- **Buttons**: Clear states (normal, hover, pressed, disabled).

---

## 🔒 Security Considerations

### App Sandbox
- **Status**: Enabled for App Store.
- **Permissions**: Only essential ones.
- **Network**: HTTPS only for updates and Lo-Fi.
- **File System**: Limited access to settings.

### Code Signing
- **Certificate**: Apple Distribution Certificate.
- **Team ID**: TB76NB7VWG.
- **Notarization**: Mandatory for distribution.
- **Hardened Runtime**: Enabled.

### Privacy
- **Data Collected**: No personal data.
- **Analytics**: Only anonymous technical metrics.
- **Permissions**: Full transparency on usage.
- **GDPR**: Full compliance.

---

## 📋 Final Acceptance Criteria

### Functionality
- [x] All functional requirements implemented.
- [x] Trial version with correct limitations.
- [x] Full version with all features.
- [x] Update system working.
- [x] Full EN/PT-BR localization.

### Performance
- [x] CPU usage <5% in normal operation.
- [x] Memory usage <100MB.
- [x] Response time <50ms.
- [x] No memory leaks.
- [x] Stability in prolonged use.

### Quality
- [x] Zero crashes in extensive tests.
- [x] Responsive and intuitive interface.
- [x] Compatibility with multiple monitors.
- [x] Support for different resolutions.
- [x] Full accessibility.

### Distribution
- [x] App Store build approved.
- [x] Valid certificates and signatures.
- [x] Metadata and screenshots prepared.
- [ ] Analytics system implemented.
- [x] Complete documentation.

---

## 📞 Contacts and Responsibilities

### Development
- **Lead Developer**: Gabriel Paiva
- **Responsibilities**: Architecture, implementation, testing.
- **Contact**: Via GitHub Issues.

---

## 📚 Related Documentation

- `README.md` - Overview and basic instructions.
- `ARCHITECTURE.md` - Architecture, execution flows, and module responsibilities.
- `CLAUDE.md` - Guidelines for AI agents working on the codebase.
- `Pixabay_Music_License_Documentation.md` - Lo-Fi music licensing info.
- `CHANGELOG` - Version history.

---

**Document Version**: 1.1  
**Date**: April 2026  
**Author**: Gabriel Paiva  
**Status**: Approved for Development