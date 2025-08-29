#!/bin/bash

# =============================================================================
# Focus Wave Comprehensive Build Script (Swift Package Version)
# =============================================================================
# This script builds the app using Swift Package Manager, cleans up old builds, 
# and creates a professional DMG
# Usage: ./build_focus_wave.sh [--clean] [--dmg-only] [--help]

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Script configuration
SCRIPT_NAME="build_focus_wave.sh"
PROJECT_NAME="FocusWave"
BUILD_DIR=".build"
RELEASE_DIR=".build/release"
DMG_NAME="${PROJECT_NAME}-v1.0.dmg"
CLEAN_BUILD=false
DMG_ONLY=false
AUTO_OPEN_DMG=false

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_header() {
    echo -e "${PURPLE}================================${NC}"
    echo -e "${PURPLE}  $1${NC}"
    echo -e "${PURPLE}================================${NC}"
}

# Function to show help
show_help() {
    echo "Usage: $SCRIPT_NAME [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  --clean     Clean build directory before building"
    echo "  --dmg-only  Only create DMG (skip build)"
    echo "  --open      Automatically open DMG after creation"
    echo "  --help      Show this help message"
    echo ""
    echo "Examples:"
    echo "  $SCRIPT_NAME           # Full build and DMG creation"
    echo "  $SCRIPT_NAME --clean   # Clean build and DMG creation"
    echo "  $SCRIPT_NAME --dmg-only # Only create DMG from existing build"
    echo "  $SCRIPT_NAME --open    # Build, create DMG, and open it"
}

# Function to parse command line arguments
parse_arguments() {
    while [[ $# -gt 0 ]]; do
        case $1 in
            --clean)
                CLEAN_BUILD=true
                shift
                ;;
            --dmg-only)
                DMG_ONLY=true
                shift
                ;;
            --open)
                AUTO_OPEN_DMG=true
                shift
                ;;
            --help)
                show_help
                exit 0
                ;;
            *)
                print_error "Unknown option: $1"
                show_help
                exit 1
                ;;
        esac
    done
}

# Function to check prerequisites
check_prerequisites() {
    print_status "Checking prerequisites..."
    
    # Check if Swift is installed
    if ! command -v swift &> /dev/null; then
        print_error "Swift not found. Please install Xcode command line tools first."
        exit 1
    fi
    
    # Check if we're in the right directory
    if [[ ! -f "Package.swift" ]]; then
        print_error "This script must be run from the Focus Wave project directory (where Package.swift is located)."
        exit 1
    fi
    
    # Check if Package.swift has the right name
    if ! grep -q "name: \"$PROJECT_NAME\"" Package.swift; then
        print_error "Package.swift doesn't contain the expected project name: $PROJECT_NAME"
        exit 1
    fi
    
    print_success "Prerequisites check passed"
}

# Function to clean build directory
clean_build() {
    if [[ "$CLEAN_BUILD" == true ]]; then
        print_status "Cleaning build directory..."
        if [[ -d "$BUILD_DIR" ]]; then
            rm -rf "$BUILD_DIR"
            print_success "Build directory cleaned"
        else
            print_warning "Build directory doesn't exist, nothing to clean"
        fi
    fi
}

# Function to clean old DMG files
clean_old_dmgs() {
    print_status "Cleaning old DMG files..."
    
    # Find all DMG files in current directory
    local old_dmgs=($(find . -maxdepth 1 -name "*.dmg" -type f))
    
    if [[ ${#old_dmgs[@]} -gt 0 ]]; then
        print_status "Found ${#old_dmgs[@]} old DMG file(s):"
        for dmg in "${old_dmgs[@]}"; do
            local dmg_name=$(basename "$dmg")
            print_status "  - $dmg_name"
        done
        
        # Remove old DMGs
        for dmg in "${old_dmgs[@]}"; do
            rm "$dmg"
            local dmg_name=$(basename "$dmg")
            print_success "Removed: $dmg_name"
        done
        print_success "All old DMG files cleaned"
    else
        print_warning "No old DMG files found to clean"
    fi
}

# Function to build the app
build_app() {
    if [[ "$DMG_ONLY" == true ]]; then
        print_status "Skipping build (DMG-only mode)"
        return
    fi
    
    print_header "Building $PROJECT_NAME with Swift Package Manager"
    
    print_status "Starting build process..."
    
    # Build the app using Swift Package Manager
    swift build -c release
    
    if [[ $? -eq 0 ]]; then
        print_success "Build completed successfully"
    else
        print_error "Build failed"
        exit 1
    fi
    
    # Check if the executable was built
    if [[ ! -f "$RELEASE_DIR/$PROJECT_NAME" ]]; then
        print_error "Built executable not found in expected location: $RELEASE_DIR/$PROJECT_NAME"
        exit 1
    fi
    
    print_success "Executable built: $RELEASE_DIR/$PROJECT_NAME"
}

# Function to create app bundle
create_app_bundle() {
    print_status "Creating app bundle..."
    
    # Remove existing app bundle
    if [[ -d "$PROJECT_NAME.app" ]]; then
        rm -rf "$PROJECT_NAME.app"
    fi
    
    # Create app bundle structure
    mkdir -p "$PROJECT_NAME.app/Contents/MacOS"
    mkdir -p "$PROJECT_NAME.app/Contents/Resources"
    
    # Copy executable
    cp "$RELEASE_DIR/$PROJECT_NAME" "$PROJECT_NAME.app/Contents/MacOS/$PROJECT_NAME"
    
    # Create Info.plist
    cat > "$PROJECT_NAME.app/Contents/Info.plist" << EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleExecutable</key>
    <string>$PROJECT_NAME</string>
    <key>CFBundleIdentifier</key>
    <string>com.focuswave.app</string>
    <key>CFBundleName</key>
    <string>$PROJECT_NAME</string>
    <key>CFBundlePackageType</key>
    <string>APPL</string>
    <key>CFBundleShortVersionString</key>
    <string>1.0</string>
    <key>CFBundleVersion</key>
    <string>1</string>
    <key>LSMinimumSystemVersion</key>
    <string>14.0</string>
    <key>NSHighResolutionCapable</key>
    <true/>
    <key>LSUIElement</key>
    <false/>
    <key>CFBundleIconFile</key>
    <string>AppIcon.png</string>
</dict>
</plist>
EOF
    
    # Copy icon if it exists
    if [[ -f "FocusWave/Assets.xcassets/AppIcon.appiconset/icon_256x256_1x.png" ]]; then
        # Copy the PNG icon directly - macOS can handle PNG icons in Resources
        cp "FocusWave/Assets.xcassets/AppIcon.appiconset/icon_256x256_1x.png" "$PROJECT_NAME.app/Contents/Resources/AppIcon.png"
        print_success "Icon copied to app bundle"
    fi
    
    # Make executable
    chmod +x "$PROJECT_NAME.app/Contents/MacOS/$PROJECT_NAME"
    
    print_success "App bundle created: $PROJECT_NAME.app"
}

# Function to create DMG
create_dmg() {
    print_header "Creating Professional DMG"
    
    # Remove existing DMG
    if [[ -f "$DMG_NAME" ]]; then
        print_status "Removing existing DMG..."
        rm "$DMG_NAME"
    fi
    
    print_status "Creating professional DMG with Applications folder shortcut..."
    
    # Create a temporary directory for DMG contents
    local temp_dmg_dir="temp_dmg_$(date +%s)"
    mkdir -p "$temp_dmg_dir"
    
    # Copy the app to temp directory
    cp -R "$PROJECT_NAME.app" "$temp_dmg_dir/"
    
    # Create Applications folder shortcut
    ln -s /Applications "$temp_dmg_dir/Applications"
    
    # Create DMG using hdiutil with proper layout
    hdiutil create \
        -volname "$PROJECT_NAME" \
        -srcfolder "$temp_dmg_dir" \
        -ov \
        -format UDZO \
        "$DMG_NAME"
    
    if [[ $? -eq 0 ]]; then
        print_success "DMG created successfully: $DMG_NAME"
        
        # Show DMG information
        DMG_SIZE=$(du -h "$DMG_NAME" | cut -f1)
        print_status "DMG size: $DMG_SIZE"
        
        # Verify DMG contents
        print_status "Verifying DMG contents..."
        hdiutil verify "$DMG_NAME" > /dev/null 2>&1
        if [[ $? -eq 0 ]]; then
            print_success "DMG verification passed"
        else
            print_warning "DMG verification failed, but DMG was created"
        fi
        
        # Clean up temp directory
        rm -rf "$temp_dmg_dir"
        print_success "Temporary files cleaned up"
    else
        print_error "Failed to create DMG"
        # Clean up temp directory on failure
        rm -rf "$temp_dmg_dir"
        exit 1
    fi
}

# Function to open DMG
open_dmg() {
    if [[ "$AUTO_OPEN_DMG" == true ]]; then
        print_status "Opening DMG automatically..."
        if [[ -f "$DMG_NAME" ]]; then
            open "$DMG_NAME"
            print_success "DMG opened: $DMG_NAME"
        else
            print_error "DMG file not found: $DMG_NAME"
        fi
    fi
}

# Function to show final summary
show_summary() {
    print_header "Build Summary"
    
    echo -e "${GREEN}✅ Build completed successfully!${NC}"
    echo ""
    echo -e "${CYAN}📱 App:${NC} $PROJECT_NAME.app"
    echo -e "${CYAN}📦 DMG:${NC} $DMG_NAME"
    echo -e "${CYAN}📁 Build Directory:${NC} $BUILD_DIR"
    echo ""
    echo -e "${YELLOW}🚀 Next steps:${NC}"
    echo "1. Test the app: open $PROJECT_NAME.app"
    echo "2. Distribute the DMG: $DMG_NAME"
    echo "3. Users can drag the app to Applications folder from the DMG"
    echo "4. Clean up build files: rm -rf $BUILD_DIR (optional)"
    echo ""
    if [[ "$AUTO_OPEN_DMG" == true ]]; then
        echo -e "${GREEN}🎯 DMG will open automatically!${NC}"
    fi
    echo ""
    echo -e "${PURPLE}🎉 Your $PROJECT_NAME is ready!${NC}"
}

# Main execution
main() {
    print_header "$PROJECT_NAME Build Script (Swift Package)"
    echo "Version: 1.0"
    echo "Date: $(date)"
    echo ""
    
    # Parse command line arguments
    parse_arguments "$@"
    
    # Check prerequisites
    check_prerequisites
    
    # Clean build if requested
    clean_build
    
    # Clean old DMG files
    clean_old_dmgs
    
    # Build the app
    build_app
    
    # Create app bundle
    create_app_bundle
    
    # Create DMG
    create_dmg
    
    # Open DMG if requested
    open_dmg
    
    # Show summary
    show_summary
}

# Run main function with all arguments
main "$@"
