import SwiftUI

@main
struct FocusWaveApp: App {
    var body: some Scene {
        MenuBarExtra {
            ContentView()
        } label: {
            Image(systemName: "waveform")
        }
        .menuBarExtraStyle(.window)
        .defaultSize(width: 600, height: 350)
    }
}
