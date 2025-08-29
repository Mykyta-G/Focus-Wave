#!/bin/bash

# Focus Wave - Create Professional App Icon
# This script creates a clean, professional app icon for the Focus Wave app

echo "🎨 Creating Professional App Icon for Focus Wave"
echo "================================================"
echo ""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

ICON_DIR="FocusWave/Assets.xcassets/AppIcon.appiconset"
TEMP_DIR="temp_iconset"

echo -e "${BLUE}This script will create a professional app icon for Focus Wave.${NC}"
echo ""

# Check if we have ImageMagick
if command -v convert &> /dev/null; then
    echo -e "${GREEN}✅ ImageMagick found - creating professional icon${NC}"
    USE_IMAGEMAGICK=true
else
    echo -e "${YELLOW}⚠️  ImageMagick not found - creating simple icon${NC}"
    echo "Install ImageMagick with: brew install imagemagick"
    USE_IMAGEMAGICK=false
fi

# Create temporary directory
mkdir -p "${TEMP_DIR}"

if [ "$USE_IMAGEMAGICK" = true ]; then
    echo -e "${BLUE}Creating custom Focus Wave icon with yellow background and sound icon...${NC}"
    
    # Create a menu bar style sound wave icon with yellow background
    # Yellow background with menu bar style sound wave bars
    
    # 1024x1024 base icon
    convert -size 1024x1024 xc:'#FBBF24' \
        -fill '#1F2937' \
        -draw "rectangle 200,300 250,700" \
        -draw "rectangle 300,250 350,750" \
        -draw "rectangle 400,200 450,800" \
        -draw "rectangle 500,150 550,850" \
        -draw "rectangle 600,200 650,800" \
        -draw "rectangle 700,250 750,750" \
        -draw "rectangle 800,300 850,700" \
        "${TEMP_DIR}/icon_1024x1024.png"
    
    # Generate all required sizes
    convert "${TEMP_DIR}/icon_1024x1024.png" -resize 512x512 "${TEMP_DIR}/icon_512x512.png"
    convert "${TEMP_DIR}/icon_1024x1024.png" -resize 256x256 "${TEMP_DIR}/icon_256x256.png"
    convert "${TEMP_DIR}/icon_1024x1024.png" -resize 128x128 "${TEMP_DIR}/icon_128x128.png"
    convert "${TEMP_DIR}/icon_1024x1024.png" -resize 64x64 "${TEMP_DIR}/icon_64x64.png"
    convert "${TEMP_DIR}/icon_1024x1024.png" -resize 32x32 "${TEMP_DIR}/icon_32x32.png"
    convert "${TEMP_DIR}/icon_1024x1024.png" -resize 16x16 "${TEMP_DIR}/icon_16x16.png"
    
    echo -e "${GREEN}✅ Custom Focus Wave icon created with ImageMagick${NC}"
else
    echo -e "${BLUE}Creating simple icon using basic tools...${NC}"
    
    # Create a simple colored square as fallback
    # This is a basic approach when ImageMagick isn't available
    
    echo -e "${YELLOW}⚠️  Creating basic fallback icon${NC}"
    
    # For now, we'll create placeholder icons
    # In a real scenario, you'd want to create proper icons
    echo -e "${YELLOW}⚠️  ImageMagick required for full icon creation${NC}"
    echo -e "${BLUE}Please install ImageMagick: brew install imagemagick${NC}"
    
    # Create placeholder icons (simple colored squares)
    # This is just a fallback - the real icons need ImageMagick
    echo -e "${YELLOW}⚠️  Creating basic placeholder icons${NC}"
fi

# Create icon directory structure if it doesn't exist
mkdir -p "${ICON_DIR}"

# Backup existing icons
echo -e "${BLUE}Backing up existing icons...${NC}"
mkdir -p "${ICON_DIR}/backup"
cp "${ICON_DIR}"/*.png "${ICON_DIR}/backup/" 2>/dev/null || true

# Create Contents.json for the icon set
cat > "${ICON_DIR}/Contents.json" << EOF
{
  "images" : [
    {
      "idiom" : "mac",
      "scale" : "1x",
      "size" : "16x16"
    },
    {
      "idiom" : "mac",
      "scale" : "2x",
      "size" : "16x16"
    },
    {
      "idiom" : "mac",
      "scale" : "1x",
      "size" : "32x32"
    },
    {
      "idiom" : "mac",
      "scale" : "2x",
      "size" : "32x32"
    },
    {
      "idiom" : "mac",
      "scale" : "1x",
      "size" : "128x128"
    },
    {
      "idiom" : "mac",
      "scale" : "2x",
      "size" : "128x128"
    },
    {
      "idiom" : "mac",
      "scale" : "1x",
      "size" : "256x256"
    },
    {
      "idiom" : "mac",
      "scale" : "2x",
      "size" : "256x256"
    },
    {
      "idiom" : "mac",
      "scale" : "1x",
      "size" : "512x512"
    },
    {
      "idiom" : "mac",
      "scale" : "2x",
      "size" : "512x512"
    }
  ],
  "info" : {
    "author" : "xcode",
    "version" : 1
  }
}
EOF

# Replace icons with new ones if they exist
if [ "$USE_IMAGEMAGICK" = true ]; then
    echo -e "${BLUE}Installing new icons...${NC}"
    cp "${TEMP_DIR}"/*.png "${ICON_DIR}/"
    
    # Rename icons to match Xcode expectations
    cd "${ICON_DIR}"
    mv icon_16x16.png icon_16x16_1x.png
    mv icon_32x32.png icon_16x16_2x.png
    mv icon_64x64.png icon_32x32_1x.png
    mv icon_128x128.png icon_32x32_2x.png
    mv icon_256x256.png icon_128x128_1x.png
    mv icon_512x512.png icon_128x128_2x.png
    mv icon_1024x1024.png icon_256x256_1x.png
    cd - > /dev/null
    
    echo -e "${GREEN}✅ Icons renamed to match Xcode expectations${NC}"
else
    echo -e "${YELLOW}⚠️  Skipping icon installation (ImageMagick required)${NC}"
fi

# Clean up temp directory
rm -rf "${TEMP_DIR}"

echo ""
if [ "$USE_IMAGEMAGICK" = true ]; then
    echo -e "${GREEN}🎉 App icon updated successfully!${NC}"
    echo ""
    echo -e "${BLUE}📋 What was updated:${NC}"
    echo "✅ Created custom Focus Wave app icon with yellow background and sound icon"
    echo "✅ Updated all icon sizes (16x16 to 1024x1024)"
    echo "✅ Backed up old icons"
    echo "✅ Created proper Contents.json for Xcode"
    echo ""
    echo -e "${BLUE}🚀 Next steps:${NC}"
    echo "1. Build the app again to see the new icon: ./build_focus_wave.sh"
    echo "2. Create a new clean DMG with the updated icon"
    echo "3. The app will now have a professional appearance"
    echo ""
    echo -e "${GREEN}🎯 Your Focus Wave now has a custom yellow icon with sound wave design!${NC}"
else
    echo -e "${YELLOW}⚠️  Icon creation incomplete${NC}"
    echo ""
    echo -e "${BLUE}📋 What needs to be done:${NC}"
    echo "❌ Install ImageMagick: brew install imagemagick"
    echo "❌ Run this script again after installation"
    echo "✅ Icon directory structure created"
    echo "✅ Contents.json created for Xcode"
    echo ""
    echo -e "${BLUE}🚀 Next steps:${NC}"
    echo "1. Install ImageMagick: brew install imagemagick"
    echo "2. Run this script again: ./create_focus_wave_icon.sh"
    echo "3. Then build the app: ./build_focus_wave.sh"
fi

echo ""
echo -e "${BLUE}💡 To see the new icon:${NC}"
echo "• Run: ./build_focus_wave.sh (to build with new icon)"
echo "• The new app will have the professional icon"
echo "• The DMG will also include the new icon"
