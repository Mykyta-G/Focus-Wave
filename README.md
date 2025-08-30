# FocusWave 🌊

A beautiful, minimalist focus app for macOS that provides ambient sounds and a calming wavy line animation to help you stay focused and productive.

## 🚀 Quick Start (5 seconds!)

1. **Download** the `FocusWave-v1.0.dmg` file from [Releases](https://github.com/Mykyta-G/Focus-Wave/releases)
2. **Double-click** the DMG to mount it
3. **Drag** `FocusWave.app` to Applications
4. **Launch** FocusWave from Applications
5. **Enjoy** your ambient rain sounds!

> **✅ Sound functionality is now fully working!** The app includes the `rain.mp3` file and will play ambient rain sounds when you click the play button.

## ✨ Features

- **Ambient Sound Library**: Rain sounds with more coming soon
- **Beautiful Wavy Animation**: Smooth, responsive wave line that adapts to your audio state
- **Menu Bar App**: Clean, unobtrusive menu bar integration
- **Theme System**: Multiple beautiful color schemes
- **Launch at Login**: Automatically starts when you log in
- **Volume Memory**: Remembers your volume preferences
- **Playback Position**: Resumes audio from where you left off

## 🚀 Getting Started

### Prerequisites

- macOS 14.0 or later
- Xcode 15.0 or later (for development only)
- Valid Apple Developer certificate (for development only)

### Installation

#### Option 1: Download Pre-built Release (Easiest! 🎉)

**Just download and install - no building required!**

1. **Download the DMG file**
   - Go to the [Releases page](https://github.com/Mykyta-G/Focus-Wave/releases)
   - Download the latest `FocusWave-v1.0.dmg` file

2. **Install the app**
   - Double-click the DMG file to mount it
   - Drag `FocusWave.app` to your Applications folder
   - Eject the DMG
   - Launch FocusWave from Applications

**That's it!** The app is ready to use with working sound functionality.

#### Option 2: Build from Source (For Developers)

**Only needed if you want to modify the code or build custom versions**

1. **Clone the repository**
   ```bash
   git clone https://github.com/Mykyta-G/FocusWave.git
   cd Focus-Wave
   ```

2. **Build and Code Sign**
   ```bash
   # Build and test locally (recommended for development)
   ./build_focus_wave.sh --test
   
   # Build and create DMG for distribution
   ./build_focus_wave.sh
   
   # Clean build and create DMG
   ./build_focus_wave.sh --clean
   ```

3. **Install the app**
   ```bash
   # If using --test mode, the app bundle is created locally
   # If building normally, the DMG contains the app bundle
   
   # For local testing:
   open FocusWave.app
   
   # For installation from DMG:
   # 1. Open the DMG file
   # 2. Drag FocusWave.app to Applications folder
   ```

4. **Launch the app**
   - The app will appear in your menu bar
   - Left-click to open the main interface
   - Right-click for context menu options



## 🔨 Build Options

The `build_focus_wave.sh` script provides several build modes:

### Build Modes

- **`./build_focus_wave.sh`** - Full build with DMG creation (default)
- **`./build_focus_wave.sh --test`** - Build and test locally (no DMG)
- **`./build_focus_wave.sh --clean`** - Clean build with DMG creation
- **`./build_focus_wave.sh --dmg-only`** - Create DMG from existing build
- **`./build_focus_wave.sh --open`** - Build, create DMG, and open it

### What Gets Built

The build process:
1. Compiles the Swift code
2. Creates a proper macOS app bundle
3. Copies the `Sounds` folder with audio files
4. Applies code signing (if certificates are available)
5. Creates a professional DMG for distribution

### Sound Files

The app includes:
- `rain.mp3` - Ambient rain sounds
- More sounds coming soon!

## 🔧 Launch at Login Setup

### Why Launch at Login Might Not Work

The launch at login functionality requires:

1. **Proper Code Signing**: The app must be signed with a valid developer certificate
2. **User Permissions**: macOS may require user approval
3. **Entitlements**: The app needs specific entitlements for system integration

### Troubleshooting Launch at Login

#### 1. Check Code Signing
```bash
codesign --verify --verbose /Applications/FocusWave
```

#### 2. Check Entitlements
```bash
codesign -d --entitlements - /Applications/FocusWave
```

#### 3. System Permissions
- Go to **System Preferences > Security & Privacy > Privacy**
- Check **Accessibility** and **Automation** sections
- Ensure FocusWave has the necessary permissions

#### 4. Manual Launch at Login Setup
If automatic setup fails:
1. Go to **System Preferences > Users & Groups**
2. Select your user account
3. Click **Login Items** tab
4. Click **+** and add FocusWave
5. Check the box next to FocusWave

### Manual Testing
1. Enable "Launch at Login" in the app's context menu
2. Restart your Mac
3. Check if FocusWave appears in the menu bar

## 🎨 Customization

### Themes
- **Sunset Serenity**: Warm orange to purple gradient
- **Ocean Depths**: Cool blue to teal gradient
- **Forest Focus**: Natural green to mint gradient
- **Midnight Elegance**: Elegant purple to indigo gradient
- **Aurora Dreams**: Dreamy cyan to pink gradient
- **Fire & Ice**: Dynamic red to orange gradient

### Adding Custom Sounds
1. Place your audio file in the `Sounds` folder
2. Update `AudioManager.swift` to include your sound
3. Rebuild the app

## 🛠️ Development

### Project Structure
```
FocusWave/
├── FocusWaveApp.swift      # Main app delegate and menu bar setup
├── ContentView.swift       # Main UI and wavy line animation
├── AudioManager.swift      # Audio playback and persistence
├── BackgroundManager.swift # Theme management and persistence
├── FocusWave.entitlements # App permissions and entitlements
├── Info.plist             # App configuration
└── Sounds/                # Audio files
    └── rain.mp3
```

### Building for Development
```bash
swift build
swift run
```

### Building for Release
```bash
swift build -c release
```

## 🔒 Security & Permissions

### Required Permissions
- **Accessibility**: For menu bar integration
- **Automation**: For launch at login management
- **Audio**: For sound playback

### Entitlements
The app includes entitlements for:
- Apple Events automation
- File access for user-selected files
- System integration capabilities

## 🐛 Troubleshooting

### Common Issues

#### App Won't Launch
- Check if the app is properly code signed
- Verify entitlements are applied
- Check Console.app for error messages

#### Audio Not Playing
- Ensure audio files are in the correct location
- Check system volume and app volume settings
- Verify audio permissions

#### Launch at Login Not Working
- Ensure proper code signing
- Check system permissions
- Try manual setup in System Preferences

### Debug Mode
Run the app from Terminal to see debug output:
```bash
/Applications/FocusWave
```

## 📱 System Requirements

- **macOS**: 14.0 (Sonoma) or later
- **Architecture**: Intel or Apple Silicon
- **Memory**: 50MB RAM
- **Storage**: 10MB disk space

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- Built with SwiftUI and AppKit
- Uses ServiceManagement framework for launch at login
- Inspired by focus and productivity apps

## 📞 Support

If you encounter issues:
1. Check this README for troubleshooting steps
2. Search existing [Issues](https://github.com/yourusername/Focus-Wave/issues)
3. Create a new issue with detailed information

---

**Happy Focusing! 🌊✨**