import SwiftUI

public struct MainView: View {
    public init() {}
    @StateObject private var viewModel = SharpViewModel()
    @State private var isDragging = false
    
    // Gesture base states to prevent jumping
    @State private var baseYaw: Double = 0
    @State private var basePitch: Double = 0
    @State private var baseZoom: Double = 0
    
    public var body: some View {
        ZStack {
            // ---------------------------------------------------------
            // 1. CONTENT LAYER
            // ---------------------------------------------------------
            ZStack {
                // Backgrounds
                Color.black.ignoresSafeArea()
                LiquidBackground()
                
                Group {
                    if let _ = viewModel.gaussians {
                        // 3D Viewport
                        TimelineView(.animation) { timeline in
                            ZStack {
                                MetalSplatView(
                                    gaussians: viewModel.gaussians,
                                    camera: viewModel.camera,
                                    viewModel: viewModel
                                )
                                .edgesIgnoringSafeArea(.all)
                                
                                // View Cube (Top Right)
                                VStack {
                                    HStack {
                                        Spacer()
                                        ViewCube(rotation: viewModel.camera.viewMatrix()) { theta, phi, dist in
                                            viewModel.snapCamera(theta: theta, phi: phi, distance: dist)
                                        }
                                        .padding(.trailing, 24)
                                        .padding(.top, 60)
                                    }
                                    Spacer()
                                }
                            }
                            .onChange(of: timeline.date) { _, newDate in
                                viewModel.updateCamera(time: newDate.timeIntervalSinceReferenceDate)
                            }
                        }
                        .overlay(
                            InputOverlay(
                                onMouseDown: { viewModel.isNavigating = true },
                                onMouseUp: { viewModel.isNavigating = false },
                                onDrag: { delta, button, mods in
                                    viewModel.handleDrag(delta: delta, button: button, modifiers: mods)
                                },
                                onScroll: { delta, position, mods in
                                    viewModel.handleScroll(delta: delta, position: position, modifiers: mods)
                                },
                                onKeyDown: viewModel.handleKeyDown,
                                onKeyUp: viewModel.handleKeyUp
                            )
                        )
                    } else if let original = viewModel.selectedImage {
                        // Full Bleed Image - Constrained to Window Size
                        // GeometryReader ensures we fill the window but NEVER exceed it.
                        GeometryReader { proxy in
                            Image(nsImage: original)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: proxy.size.width, height: proxy.size.height)
                                .clipped()
                        }
                    } else {
                        // Empty State
                        VStack(spacing: 16) {
                            Image(systemName: "photo.on.rectangle.angled")
                                .font(.system(size: 40, weight: .ultraLight))
                                .foregroundStyle(.white.opacity(0.15))
                            Text("Drop an image to begin")
                                .font(.system(size: 13, weight: .regular))
                                .foregroundStyle(.white.opacity(0.3))
                        }
                    }
                }
                
                // Drop Overlay
                if isDragging {
                    Rectangle()
                        .fill(.ultraThinMaterial)
                        .overlay(
                            VStack(spacing: 12) {
                                Image(systemName: "arrow.down.circle")
                                    .font(.system(size: 32, weight: .light))
                                Text("Release to open")
                                    .font(.system(size: 13, weight: .medium))
                            }
                            .foregroundStyle(.white.opacity(0.7))
                        )
                        .transition(.opacity.animation(.easeInOut(duration: 0.2)))
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            // Handle Drops on the Content Layer
            .onDrop(of: ["public.file-url"], isTargeted: $isDragging) { providers in
                guard let item = providers.first else { return false }
                _ = item.loadObject(ofClass: URL.self) { url, error in
                    if let url = url {
                        // Defer import to next run loop to ensure drop completes
                        DispatchQueue.main.async {
                            // Add a small delay to ensure drag session is fully released
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                viewModel.importFile(url: url)
                            }
                        }
                    }
                }
                return true
            }
            .loadingOverlay(isPresented: $viewModel.isProcessing)
            .ignoresSafeArea()
            
            // ---------------------------------------------------------
            // 2. CHROME LAYER (UI)
            // ---------------------------------------------------------
            VStack {
                // Title Bar (Centered)
                Text("SharpGlass")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(.white.opacity(0.6))
                    .padding(.top, 12)
                
                Spacer()
                
                // Bottom Area (Stats + Pill)
                ZStack(alignment: .bottom) {
                    // Stats (Bottom Left)
                    if let g = viewModel.gaussians {
                        HStack {
                            Text("\(g.pointCount.formatted()) splats")
                                .font(.system(size: 10, weight: .medium, design: .monospaced))
                                .foregroundStyle(.white.opacity(0.35))
                            Spacer()
                        }
                        .padding(.leading, 16)
                        .padding(.bottom, 16)
                    }
                    
                    // Liquid Glass Floating Pill Menu (Bottom Center)
                    LiquidGlassPillMenu(
                        canOpen: true,
                        canGenerate: viewModel.selectedImage != nil && viewModel.gaussians == nil && viewModel.isAvailable,
                        canSave: viewModel.gaussians != nil,
                        onOpen: viewModel.loadImage,
                        onGenerate: viewModel.generate3D,
                        onSave: {
                            let panel = NSSavePanel()
                            panel.allowedContentTypes = [.init(filenameExtension: "ply")!]
                            panel.nameFieldStringValue = "scene.ply"
                            if panel.runModal() == .OK, let url = panel.url {
                                viewModel.saveSplat(to: url)
                            }
                        }
                    )
                    .padding(.bottom, 30)
                }
            }
            .ignoresSafeArea()
        }
    }
}

// MARK: - Liquid Glass Pill Menu (Tahoe Spec)
struct LiquidGlassPillMenu: View {
    let canOpen: Bool
    let canGenerate: Bool
    let canSave: Bool
    let onOpen: () -> Void
    let onGenerate: () -> Void
    let onSave: () -> Void
    
    var body: some View {
        HStack(spacing: 0) {
            // Open
            Button(action: onOpen) {
                Image(systemName: "folder")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(canOpen ? .white : .white.opacity(0.3))
                    .frame(width: 52, height: 44)
            }
            .buttonStyle(.plain)
            .disabled(!canOpen)
            
            // Divider
            Rectangle()
                .fill(.white.opacity(0.15))
                .frame(width: 0.5, height: 22)
            
            // Generate
            Button(action: onGenerate) {
                Image(systemName: "cube")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(canGenerate ? .white : .white.opacity(0.3))
                    .frame(width: 52, height: 44)
            }
            .buttonStyle(.plain)
            .disabled(!canGenerate)
            
            // Divider
            Rectangle()
                .fill(.white.opacity(0.15))
                .frame(width: 0.5, height: 22)
            
            // Save
            Button(action: onSave) {
                Image(systemName: "square.and.arrow.down")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(canSave ? .white : .white.opacity(0.3))
                    .frame(width: 52, height: 44)
            }
            .buttonStyle(.plain)
            .disabled(!canSave)
        }
        // Liquid Glass: blur with black at 25% opacity (dark mode)
        .background(
            Capsule()
                .fill(.black.opacity(0.15))
                .background(
                    Capsule()
                        .fill(.ultraThinMaterial)
                )
        )
        .clipShape(Capsule())
        // Inner highlight (glass edge) - white gradient top-to-bottom
        .overlay(
            Capsule()
                .strokeBorder(
                    LinearGradient(
                        colors: [.white.opacity(0.35), .white.opacity(0.1)],
                        startPoint: .top,
                        endPoint: .bottom
                    ),
                    lineWidth: 0.5
                )
        )
        // Drop shadow - blur 40px, Y 20px, 15% opacity
        .shadow(color: .black.opacity(0.2), radius: 30, y: 15)
    }
}




// MARK: - Sidebar View
struct SidebarView: View {
    @ObservedObject var viewModel: SharpViewModel
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 20) {
                if let error = viewModel.errorMessage {
                    Text(error.prefix(300))
                        .font(.system(size: 9, weight: .medium))
                        .foregroundStyle(.red.opacity(0.8))
                        .padding(10)
                        .background(Color.red.opacity(0.05))
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                }
                
                // Action Steps
                VStack(spacing: 24) {
                    WorkflowStep(number: 1, title: "Source") {
                        Button(action: viewModel.loadImage) {
                            Text(viewModel.selectedImage == nil ? "SELECT IMAGE" : "REPLACE")
                                .font(.system(size: 9, weight: .bold))
                                .frame(maxWidth: .infinity)
                                .frame(height: 30)
                        }
                        .buttonStyle(CinematicButtonStyle())
                    }
                    
                    WorkflowStep(number: 2, title: "Process") {
                        Button(action: viewModel.generate3D) {
                            Text(viewModel.gaussians == nil ? "START" : "SYNC")
                                .font(.system(size: 9, weight: .bold))
                                .frame(maxWidth: .infinity)
                                .frame(height: 30)
                        }
                        .buttonStyle(CinematicButtonStyle(prominent: true))
                        .disabled(!viewModel.isAvailable || viewModel.selectedImage == nil || viewModel.isProcessing)
                    }
                    
                    if let _ = viewModel.gaussians {
                        // Stats Overlay
                        VStack(alignment: .leading, spacing: 4) {
                            HStack {
                                Text("SCENE STATS")
                                    .font(.system(size: 8, weight: .bold))
                                    .foregroundColor(.white.opacity(0.4))
                                Spacer()
                            }
                            
                            HStack(spacing: 12) {
                                VStack(alignment: .leading, spacing: 0) {
                                    Text(viewModel.pointCountFormatted)
                                        .font(.system(size: 13, weight: .medium, design: .monospaced))
                                        .foregroundColor(.white)
                                    Text("Splats")
                                        .font(.system(size: 8))
                                        .foregroundColor(.white.opacity(0.5))
                                }
                                
                                Color.white.opacity(0.1)
                                    .frame(width: 1, height: 20)
                                
                                VStack(alignment: .leading, spacing: 0) {
                                    Text(viewModel.memoryUsageFormatted)
                                        .font(.system(size: 13, weight: .medium, design: .monospaced))
                                        .foregroundColor(.white)
                                    Text("VRAM")
                                        .font(.system(size: 8))
                                        .foregroundColor(.white.opacity(0.5))
                                }
                            }
                        }
                        .padding(12)
                        .background(RoundedRectangle(cornerRadius: 6).fill(Color.white.opacity(0.05)))
                        .padding(.bottom, 12)
                        
                        WorkflowStep(number: 3, title: "Refine") {
                            VStack(spacing: 20) {
                                VStack(spacing: 12) {
                                    // Splat scale control only
                                    HStack {
                                        Text("SPLAT SCALE")
                                            .font(.system(size: 9, weight: .bold))
                                            .foregroundStyle(.white.opacity(0.4))
                                        Spacer()
                                        Text(String(format: "%.1f", viewModel.splatScale))
                                            .font(.system(size: 9, design: .monospaced))
                                            .foregroundStyle(.white.opacity(0.6))
                                    }
                                    Slider(value: $viewModel.splatScale, in: 0.1...2.0)
                                        .controlSize(.mini)
                                    
                                    // Save Splat Button
                                    if viewModel.gaussians != nil {
                                        Button(action: {
                                            let panel = NSSavePanel()
                                            panel.allowedContentTypes = [.init(filenameExtension: "ply")!]
                                            panel.nameFieldStringValue = "scene.ply"
                                            if panel.runModal() == .OK, let url = panel.url {
                                                viewModel.saveSplat(to: url)
                                            }
                                        }) {
                                            HStack {
                                                Image(systemName: "square.and.arrow.down")
                                                Text("SAVE SPLAT")
                                            }
                                            .font(.system(size: 9, weight: .bold))
                                            .frame(maxWidth: .infinity)
                                            .frame(height: 28)
                                        }
                                        .buttonStyle(CinematicButtonStyle())
                                    }
                                }
                                
                                InputHelperView(mode: .orbit)
                            }
                        }
                    }
                    
                    if !viewModel.isAvailable {
                        SetupInstructionsView()
                    }
                }
            }
            .padding(12)
        }
        .background(.ultraThinMaterial)
        .background(Color.black.opacity(0.15))
        .frame(width: 220)
        .overlay(
            Rectangle()
                .fill(Color.white.opacity(0.04))
                .frame(width: 0.5)
                .frame(maxWidth: .infinity, alignment: .leading)
        )
    }
}


struct WorkflowStep<Content: View>: View {
    let number: Int
    let title: String
    let content: Content
    
    init(number: Int, title: String, @ViewBuilder content: () -> Content) {
        self.number = number
        self.title = title
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 8) {
                Text("\(number)")
                    .font(.system(size: 10, weight: .bold, design: .monospaced))
                    .foregroundStyle(.white.opacity(0.3))
                    .frame(width: 16, height: 16)
                    .overlay(Circle().stroke(Color.white.opacity(0.1), lineWidth: 1))
                
                Text(title.uppercased())
                    .font(.system(size: 10, weight: .bold))
                    .kerning(1)
                    .foregroundStyle(.white.opacity(0.6))
                    .minimumScaleFactor(0.8)
                    .lineLimit(1)
            }
            
            content
        }
    }
}

struct CameraSliderSimplified: View {
    @Binding var value: Double
    let label: String
    let range: ClosedRange<Double>
    let onChanged: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            HStack {
                Text(label)
                    .font(.system(size: 9))
                    .foregroundStyle(.secondary)
                    .minimumScaleFactor(0.5)
                    .lineLimit(1)
                Spacer()
                Text(String(format: "%.1f", value))
                    .font(.system(size: 9, design: .monospaced))
            }
            Slider(value: $value, in: range) { editing in
                if !editing { onChanged() }
            }
            .controlSize(.mini)
        }
    }
}

struct SetupInstructionsView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 8) {
                Image(systemName: "info.circle")
                Text("Setup Required")
            }
            .font(.system(size: 10, weight: .bold))
            .foregroundStyle(.white.opacity(0.5))
            
            Text("Apple's ml-sharp logic is missing. Install via github.com/apple/ml-sharp")
                .font(.system(size: 9))
                .foregroundStyle(.secondary)
                .minimumScaleFactor(0.5)
            
            Link("Guide", destination: URL(string: "https://github.com/apple/ml-sharp")!)
                .font(.system(size: 9, weight: .medium))
                .tint(.white.opacity(0.8))
        }
        .padding(10)
        .background(Color.white.opacity(0.02))
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}


struct InputHelperView: View {
    let mode: SharpViewModel.CameraMode
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 4) {
                Image(systemName: "keyboard")
                Text("CONTROLS")
            }
            .font(.system(size: 8, weight: .bold))
            .foregroundStyle(.white.opacity(0.4))
            
            Group {
                if mode == .fly {
                    controlRow(key: "WASD", action: "Move")
                    controlRow(key: "Shift/Space", action: "Up/Down")
                    controlRow(key: "Mouse", action: "Look")
                } else {
                    controlRow(key: "LMB", action: "Rotate")
                    controlRow(key: "RMB", action: "Pan")
                    controlRow(key: "Scroll", action: "Zoom")
                }
            }
        }
        .padding(8)
        .background(Color.white.opacity(0.03))
        .cornerRadius(4)
    }
    
    func controlRow(key: String, action: String) -> some View {
        HStack {
            Text(key)
                .font(.system(size: 9, weight: .bold))
                .foregroundStyle(.white.opacity(0.8))
            Spacer()
            Text(action)
                .font(.system(size: 9))
                .foregroundStyle(.white.opacity(0.6))
        }
    }
}
