# SharpGlass

SharpGlass is a macOS application for generating and rendering 3D Gaussian Splats from single images using Apple's `ml-sharp`. It allows you to create high-quality 3D views from everyday photos, with built-in support for iPhone spatial photos and parallax animation export.

## Features

- **3D Generation**: Convert single JPEG/PNG images into 3D Gaussian Splats.
- **Spatial Photo Support**: Extract depth and stereo pairs from HEIC spatial photos for enhanced reconstruction.
- **Real-time Rendering**: interactive 3D navigation using a high-performance Metal-based splatting renderer.
- **Video Export**: Export cinematic parallax animations as MP4 videos.
- **Optimized Resource Management**: Automatically prunes large datasets and manages memory efficiently for smooth performance.

## Prerequisites

- **macOS 15.0+**
- **Python 3.13+** (Required for `ml-sharp`)
- **Xcode 16.0+** (For building from source)

## Quick Start

1. **Clone the repository**:
   ```bash
   git clone https://github.com/trond/SharpGlass.git
   cd SharpGlass
   ```

2. **Run the setup script**:
   This script creates a Python virtual environment, installs `ml-sharp` and its dependencies, and builds the Swift project.
   ```bash
   chmod +x setup.sh
   ./setup.sh
   ```

3. **Run the application**:
   ```bash
   swift run SharpGlassApp
   ```

## Installation & Setup Details

### Python Environment
SharpGlass uses a Python-based backend (`ml-sharp`) for the initial 3D inference. The `setup.sh` script handles:
- Creating a `venv`
- Installing `ml-sharp` in editable mode from the local directory.
- Ensuring all Python dependencies (Torch, etc.) are available.

### ML Models
On the first run, the application will download the necessary model weights (approx. 1.2GB) required for 3D generation.

## Usage

- **Import**: Drag and drop an image or use the "Open" menu.
- **Navigation**:
  - **Orbit**: Left-click + Drag
  - **Pan**: Right-click + Drag (or Shift + Drag)
  - **Zoom**: Scroll or Option + Click + Drag
  - **Focus**: Press 'F' to center the view on the splat.
- **Export**: Use the "Export Video" button to generate a 3D parallax animation.

## Contributing

Contributions are welcome! Please feel free to submit Pull Requests or open issues.

## License

[MIT License](LICENSE)
