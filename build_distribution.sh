#!/bin/bash
set -e

# Configuration
APP_NAME="SharpGlass"
BUILD_DIR=".build/release"
DIST_DIR="dist"
APP_BUNDLE="${DIST_DIR}/${APP_NAME}.app"
SOURCES_DIR="Sources"
RESOURCES_DIR="${SOURCES_DIR}/Main/Resources"

echo "🚀 Starting Distribution Build for ${APP_NAME}..."

# 1. compile Assets.xcassets to Assets.car
echo "🎨 Compiling Assets..."
mkdir -p "${DIST_DIR}"
xcrun actool "${SOURCES_DIR}/Main/Assets.xcassets" --compile "${DIST_DIR}" --platform macosx --minimum-deployment-target 15.0 --app-icon AppIcon --output-partial-info-plist "${DIST_DIR}/assetcatalog_generated_info.plist" > /dev/null

# 2. Build Release Binary
echo "🔨 Building Release Binary..."
swift build -c release --product SharpGlass

# 3. Create App Bundle Structure
echo "📦 Creating App Bundle..."
rm -rf "${APP_BUNDLE}"
mkdir -p "${APP_BUNDLE}/Contents/MacOS"
mkdir -p "${APP_BUNDLE}/Contents/Resources"

# 4. Copy Files
echo "📂 Copying Resources..."
cp "${BUILD_DIR}/${APP_NAME}" "${APP_BUNDLE}/Contents/MacOS/"
cp "${SOURCES_DIR}/Main/Info.plist" "${APP_BUNDLE}/Contents/"
cp "${DIST_DIR}/Assets.car" "${APP_BUNDLE}/Contents/Resources/"
if [ -f "${DIST_DIR}/AppIcon.icns" ]; then
    cp "${DIST_DIR}/AppIcon.icns" "${APP_BUNDLE}/Contents/Resources/"
fi

# Copy ml-sharp backend source (EXCLUDING venv and git)
if [ -d "${RESOURCES_DIR}/ml-sharp" ]; then
    echo "🐍 Bundling ml-sharp backend..."
    mkdir -p "${APP_BUNDLE}/Contents/Resources/ml-sharp"
    rsync -av --exclude 'venv' --exclude '.git' --exclude '__pycache__' "${RESOURCES_DIR}/ml-sharp/" "${APP_BUNDLE}/Contents/Resources/ml-sharp/"
else
    echo "⚠️  Warning: ml-sharp source not found in ${RESOURCES_DIR}. Please check submodule/directory."
fi

# 5. Fix Permissions & Sign
chmod +x "${APP_BUNDLE}/Contents/MacOS/${APP_NAME}"

if [ -z "${SIGNING_IDENTITY}" ]; then
    echo "🔐 Signing (Ad-Hoc)..."
    codesign --force --deep --sign - "${APP_BUNDLE}"
else
    echo "🔐 Signing with Identity: ${SIGNING_IDENTITY}..."
    codesign --force --options runtime --deep --sign "${SIGNING_IDENTITY}" "${APP_BUNDLE}"
fi

echo "✅ Build Complete!"
echo "Find your app at: ${APP_BUNDLE}"
