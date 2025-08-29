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

@MainActor
class AppDelegate: NSObject, NSApplicationDelegate, NSPopoverDelegate {
    var statusItem: NSStatusItem?
    var popover: NSPopover?
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        // Set as regular app initially, then hide dock icon
        NSApp.setActivationPolicy(.regular)
        
        // Hide the dock icon after a short delay to keep it as a menu bar app
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            NSApp.setActivationPolicy(.accessory)
        }
        
        // Create the status item (menu bar icon)
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        
        if let button = statusItem?.button {
            // Create a custom icon using system symbol
            let image = NSImage(systemSymbolName: "waveform", accessibilityDescription: "Focus Wave")
            
            // Apply template mode for proper menu bar appearance
            image?.isTemplate = true
            
            button.image = image
            button.imagePosition = .imageLeft
            
            // Set up both left-click (popover) and right-click (menu) handling
            setupButtonActions(for: button)
        }
        
        // Ensure the status item is visible
        statusItem?.isVisible = true
        
        // Create the popover
        popover = NSPopover()
        popover?.contentSize = NSSize(width: 400, height: 380)
        popover?.behavior = .transient  // Allow closing by clicking outside
        popover?.contentViewController = NSHostingController(rootView: ContentView())
        
        // Set the popover delegate to handle window management
        popover?.delegate = self
    }
    
    // MARK: - Context Menu Management
    
    /// Set up both left-click (popover) and right-click (menu) handling
    private func setupButtonActions(for button: NSStatusBarButton) {
        button.target = self
        button.action = #selector(statusItemClicked(_:))
        _ = button.sendAction(on: [.leftMouseUp, .rightMouseUp])
    }
    
    /// Single click handler that distinguishes left vs right click
    @objc private func statusItemClicked(_ sender: Any?) {
        guard let button = statusItem?.button else { return }
        guard let event = NSApp.currentEvent else {
            handleStatusButtonClick()
            return
        }
        
        if event.type == .rightMouseUp {
            let menu = createContextMenu()
            let popupPoint = NSPoint(x: 0, y: button.bounds.height - 2)
            menu.popUp(positioning: nil, at: popupPoint, in: button)
        } else {
            handleStatusButtonClick()
        }
    }
    
    /// Handle left-click (show popover)
    private func handleStatusButtonClick() {
        if let popover = popover {
            if popover.isShown {
                popover.performClose(nil)
            } else {
                if let button = statusItem?.button {
                    popover.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
                }
            }
        }
    }
    
    /// Create a context menu with quit and color options
    private func createContextMenu() -> NSMenu {
        let menu = NSMenu()
        
        // Add Quit option
        let quitItem = NSMenuItem(title: "Quit Focus Wave", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q")
        quitItem.target = NSApp
        menu.addItem(quitItem)
        
        // Add separator
        menu.addItem(NSMenuItem.separator())
        
        // Add Color Gradients section header
        let colorHeader = NSMenuItem(title: "Color Gradients", action: nil, keyEquivalent: "")
        colorHeader.isEnabled = false
        menu.addItem(colorHeader)
        
        // Add color gradient options
        let sunsetItem = NSMenuItem(title: "🌅 Sunset Serenity", action: #selector(setSunsetColors), keyEquivalent: "")
        sunsetItem.target = self
        menu.addItem(sunsetItem)
        
        let oceanItem = NSMenuItem(title: "🌊 Ocean Depths", action: #selector(setOceanColors), keyEquivalent: "")
        oceanItem.target = self
        menu.addItem(oceanItem)
        
        let forestItem = NSMenuItem(title: "🌿 Forest Focus", action: #selector(setForestColors), keyEquivalent: "")
        forestItem.target = self
        menu.addItem(forestItem)
        
        let midnightItem = NSMenuItem(title: "🎭 Midnight Elegance", action: #selector(setMidnightColors), keyEquivalent: "")
        midnightItem.target = self
        menu.addItem(midnightItem)
        
        let auroraItem = NSMenuItem(title: "✨ Aurora Dreams", action: #selector(setAuroraColors), keyEquivalent: "")
        auroraItem.target = self
        menu.addItem(auroraItem)
        
        let fireItem = NSMenuItem(title: "🔥 Fire & Ice", action: #selector(setFireColors), keyEquivalent: "")
        fireItem.target = self
        menu.addItem(fireItem)
        
        // Add separator
        menu.addItem(NSMenuItem.separator())
        
        // Add Reset to Default option
        let resetItem = NSMenuItem(title: "🔄 Reset to Default", action: #selector(resetToDefault), keyEquivalent: "")
        resetItem.target = self
        menu.addItem(resetItem)
        
        return menu
    }
    
    // MARK: - Color Gradient Methods
    
    @objc private func setSunsetColors() {
        NotificationCenter.default.post(name: NSNotification.Name("ChangeColors"), object: nil, userInfo: [
            "primary": Color.orange.opacity(0.9),
            "secondary": Color.purple.opacity(0.7),
            "name": "Sunset Serenity"
        ])
    }
    
    @objc private func setOceanColors() {
        NotificationCenter.default.post(name: NSNotification.Name("ChangeColors"), object: nil, userInfo: [
            "primary": Color.blue.opacity(0.8),
            "secondary": Color.teal.opacity(0.6),
            "name": "Ocean Depths"
        ])
    }
    
    @objc private func setForestColors() {
        NotificationCenter.default.post(name: NSNotification.Name("ChangeColors"), object: nil, userInfo: [
            "primary": Color.green.opacity(0.8),
            "secondary": Color.mint.opacity(0.6),
            "name": "Forest Focus"
        ])
    }
    
    @objc private func setMidnightColors() {
        NotificationCenter.default.post(name: NSNotification.Name("ChangeColors"), object: nil, userInfo: [
            "primary": Color.purple.opacity(0.8),
            "secondary": Color.indigo.opacity(0.6),
            "name": "Midnight Elegance"
        ])
    }
    
    @objc private func setAuroraColors() {
        NotificationCenter.default.post(name: NSNotification.Name("ChangeColors"), object: nil, userInfo: [
            "primary": Color.cyan.opacity(0.8),
            "secondary": Color.pink.opacity(0.6),
            "name": "Aurora Dreams"
        ])
    }
    
    @objc private func setFireColors() {
        NotificationCenter.default.post(name: NSNotification.Name("ChangeColors"), object: nil, userInfo: [
            "primary": Color.red.opacity(0.8),
            "secondary": Color.orange.opacity(0.6),
            "name": "Fire & Ice"
        ])
    }
    
    @objc private func resetToDefault() {
        NotificationCenter.default.post(name: NSNotification.Name("ChangeColors"), object: nil, userInfo: [
            "primary": Color.orange.opacity(0.9),
            "secondary": Color.purple.opacity(0.7),
            "name": "Sunset Serenity"
        ])
    }
    
    // MARK: - Popover Delegate
    
    func popoverShouldClose(_ popover: NSPopover) -> Bool {
        return true
    }
    
    func popoverDidClose(_ notification: Notification) {
        // Handle popover close if needed
    }
}
