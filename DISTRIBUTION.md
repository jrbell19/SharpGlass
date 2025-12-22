# SharpGlass Distribution Guide

This guide outlines the build and distribution process for SharpGlass, featuring **Smart Onboarding**.

## Distribution Strategy

SharpGlass uses a **Smart Onboarding** approach to minimize the initial download size while ensuring a robust execution environment.

1.  **Tiny App Bundle**: The main application bundle contains the Swift executable, assets, and the **source code** for the `ml-sharp` backend. It does *not* contain the heavy Python virtual environment or pre-downloaded models.
2.  **On-Demand Installation**: On the first run, the user is guided through an interactive setup screen. The app automatically:
    *   Creates a Python virtual environment in `~/Library/Application Support/com.trond.SharpGlass/venv`.
    *   Installs dependencies from the bundled `ml-sharp` source.
    *   Verifies the installation.

## Requirements

*   **macOS 15.0+** (Sequoia)
*   **Python 3.13**: The user must have Python 3.13 installed and available in their path (e.g., via Homebrew `brew install python@3.13` or python.org). The app will check for this.

## Build Process

### 1. Prepare Resources
Ensure `ml-sharp` source is updated in `Sources/Main/Resources/ml-sharp`.
(This is handled automatically by the project structure, but ensure no junk files like `.git` or `venv` are present in the source folder before release builds to save space).

### Automated Build (Recommended)
Run the included build script to compile the release binary, generate assets, and create the `.app` bundle structure automatically:
```bash
./build_distribution.sh
```
The output will be located at `dist/SharpGlass.app`.

### Signing with Developer ID
To sign with your Apple Developer ID (required for Notarization):
```bash
export SIGNING_IDENTITY="Developer ID Application: Your Name (TEAMID)"
./build_distribution.sh
```

### Manual Build Steps
If you prefer to build manually:
1. **Compile Assets**: Use `actool` to compile `Assets.xcassets`.
2. **Build Binary**: `swift build -c release`
3. **Assemble Bundle**: Create the `SharpGlass.app` directory structure and copy the binary, `Info.plist`, `Assets.car`, and `ml-sharp` source code into `Contents/Resources`.

**Note**: The SwiftPM build automatically bundles `ml-sharp` and `Assets.xcassets` into the bundle structure if run via Xcode or properly configured bundle tool.

## Code Signing & Notarization

For public distribution, sign the app with your Developer ID:

```bash
codesign --force --options runtime --sign "Developer ID Application: Your Name (TEAMID)" SharpGlass.app
```

Then submit for notarization using `xcrun notarytool`.
