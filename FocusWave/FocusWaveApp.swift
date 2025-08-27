import SwiftUI

@main
struct FocusWaveApp: App {
    var body: some Scene {
        MenuBarExtra {
            Text("Focus Wave")
                .frame(width: 200, height: 100)
        } label: {
            Image(systemName: "waveform")
        }
        .menuBarExtraStyle(.window)
    }
}
