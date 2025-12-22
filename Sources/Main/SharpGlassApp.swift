import SwiftUI
import SharpGlassLibrary

@main
struct SharpGlassApp: App {
    init() {
        // Explicitly set the app icon if available in assets (Fix for running executable directly)
        if let icon = NSImage(named: "AppIcon") {
            NSApplication.shared.applicationIconImage = icon
        }
    }

    var body: some Scene {
        WindowGroup {
            MainView()
                .frame(minWidth: 900, minHeight: 700)
        }
        .windowStyle(.hiddenTitleBar)
    }
}
