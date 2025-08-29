import SwiftUI
import AppKit

@main
struct FocusWaveApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        Settings {
            EmptyView()
        }
    }
}

class AppDelegate: NSObject, NSApplicationDelegate {
    var statusItem: NSStatusItem?
    var popover: NSPopover?
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        // Create the status item (menu bar icon)
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        
        if let button = statusItem?.button {
            button.image = NSImage(systemSymbolName: "waveform", accessibilityDescription: "Focus Wave")
            button.action = #selector(togglePopover)
            button.target = self
        }
        
        // Create the popover with smooth animations
        popover = NSPopover()
        popover?.contentSize = NSSize(width: 400, height: 380)
        popover?.behavior = .transient
        popover?.contentViewController = NSHostingController(rootView: ContentView())
        popover?.animates = true
    }
    
    @objc func togglePopover() {
        guard let button = statusItem?.button else { return }
        
        // Use a different approach that avoids data race warnings
        let currentPopover = popover
        
        DispatchQueue.main.async {
            // Try to close first, if it fails, then show
            if currentPopover?.isShown == true {
                currentPopover?.performClose(nil)
            } else {
                currentPopover?.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
            }
        }
    }
}
