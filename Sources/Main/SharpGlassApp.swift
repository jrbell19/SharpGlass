import SwiftUI
import SharpGlass

@main
struct SharpGlassApp: App {
    var body: some Scene {
        WindowGroup {
            MainView()
                .frame(minWidth: 900, minHeight: 700)
        }
        .windowStyle(.hiddenTitleBar)
    }
}
