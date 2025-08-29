# Focus Wave 🌊

A beautiful, sleek menu bar app for macOS that provides high-quality white noise and ambient sounds to help you focus, relax, and sleep better.

## 🚀 Building and Distribution

### Prerequisites
- macOS 14.0 or later
- Xcode Command Line Tools (for Swift compilation)
- ImageMagick (for icon creation): `brew install imagemagick`

### Build Scripts

#### 1. Build and Create DMG
```bash
./build_focus_wave.sh
```
This script will:
- Build the app using Swift Package Manager
- Create a proper macOS app bundle
- Generate a professional DMG installer
- Clean up old builds and DMG files

**Options:**
- `--clean`: Clean build directory before building
- `--dmg-only`: Only create DMG (skip build)
- `--open`: Automatically open DMG after creation
- `--help`: Show help information

#### 2. Create Custom App Icon
```bash
./create_focus_wave_icon.sh
```
This script will:
- Create a custom yellow background icon with menubar design
- Generate all required icon sizes (16x16 to 1024x1024)
- Set up proper Xcode icon asset structure
- Backup existing icons

### Quick Start
1. **Create the icon:**
   ```bash
   ./create_focus_wave_icon.sh
   ```

2. **Build the app and create DMG:**
   ```bash
   ./build_focus_wave.sh --open
   ```

3. **Test the app:**
   - Open the generated `FocusWave.app`
   - Or install from the DMG by dragging to Applications

### 📥 **For End Users (Simple Installation)**
**Users only need to download the DMG file to use Focus Wave!**

- Download `FocusWave-v1.0.dmg`
- Double-click to mount the DMG
- Drag `FocusWave.app` to the Applications folder
- Eject the DMG
- Launch Focus Wave from Applications

**No technical knowledge required - just drag and drop!**

### Project Structure
- `FocusWave/` - Main app source code
- `Package.swift` - Swift Package configuration
- `build_focus_wave.sh` - Main build script
- `create_focus_wave_icon.sh` - Icon creation script

---

Still in Development...