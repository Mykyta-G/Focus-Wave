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
class AppDelegate: NSObject, NSApplicationDelegate, NSPopoverDelegate, NSWindowDelegate {
    var statusItem: NSStatusItem?
    var popover: NSPopover?
    private var globalClickMonitor: Any?
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        // Check if this is the first launch and ask about automatic startup
        checkFirstLaunchAndSetupStartup()
        
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
        
        // Status item is visible by default, no need to set it
        
        // Create the popover
        popover = NSPopover()
        popover?.contentSize = NSSize(width: 400, height: 380)
        popover?.behavior = .transient
        popover?.contentViewController = NSHostingController(rootView: ContentView())
        
        // For status item popovers, we need to manually handle outside clicks
        setupPopoverOutsideClickHandling()
        
        // Set the popover delegate to handle window management
        popover?.delegate = self
        
        // Set up window monitoring for proper minimize behavior
        setupWindowMonitoring()
        
        // Popover will automatically close when clicking outside due to .transient behavior
    }
    
    // MARK: - Window Monitoring Setup
    
    /// Set up monitoring for app activation/deactivation
    private func setupWindowMonitoring() {
        // Monitor app activation/deactivation
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(applicationDidBecomeActive),
            name: NSApplication.didBecomeActiveNotification,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(applicationDidResignActive),
            name: NSApplication.didResignActiveNotification,
            object: nil
        )
    }
    
    // MARK: - Popover Outside Click Handling
    
    /// Set up monitoring to detect clicks outside the popover
    private func setupPopoverOutsideClickHandling() {
        // Monitor mouse clicks globally
        globalClickMonitor = NSEvent.addGlobalMonitorForEvents(matching: [.leftMouseDown, .rightMouseDown]) { [weak self] event in
            guard let self = self else { return }
            
            // Check if popover is showing
            if let popover = self.popover, popover.isShown {
                // Get the popover's window frame
                if let popoverWindow = popover.contentViewController?.view.window {
                    let clickLocation = event.locationInWindow
                    let popoverFrame = popoverWindow.frame
                    
                    // If click is outside popover, close it
                    if !popoverFrame.contains(clickLocation) {
                        DispatchQueue.main.async {
                            popover.performClose(nil)
                        }
                    }
                }
            }
        }
    }
    
    // MARK: - First Launch and Startup Management
    
    /// Check if this is the first launch and ask about automatic startup
    private func checkFirstLaunchAndSetupStartup() {
        let hasAskedBefore = UserDefaults.standard.bool(forKey: "HasAskedAboutStartup")
        
        if !hasAskedBefore {
            // This is the first launch, ask the user
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                self.showStartupDialog()
            }
        } else {
            // User has been asked before, apply their saved preference
            let shouldLaunchAtLogin = UserDefaults.standard.bool(forKey: "LaunchAtLogin")
            if shouldLaunchAtLogin {
                self.setLaunchAtLogin(true)
            }
        }
    }
    
    /// Show dialog asking about automatic startup
    private func showStartupDialog() {
        let alert = NSAlert()
        alert.messageText = "Welcome to Focus Wave!"
        alert.informativeText = "Would you like Focus Wave to start automatically when you log in to your Mac?"
        alert.alertStyle = .informational
        alert.addButton(withTitle: "Yes, start automatically")
        alert.addButton(withTitle: "No, start manually")
        
        let response = alert.runModal()
        
        let shouldLaunchAtLogin = (response == .alertFirstButtonReturn)
        
        // Save the user's preference
        UserDefaults.standard.set(true, forKey: "HasAskedAboutStartup")
        UserDefaults.standard.set(shouldLaunchAtLogin, forKey: "LaunchAtLogin")
        
        // Apply the setting
        if shouldLaunchAtLogin {
            setLaunchAtLogin(true)
        }
    }
    
    // MARK: - Launch at Login Management
    
    /// Check if the app is set to launch at login
    private func isLaunchAtLoginEnabled() -> Bool {
        let bundleID = Bundle.main.bundleIdentifier ?? "com.focuswave.app"
        let loginItemPath = "~/Library/LaunchAgents/\(bundleID).plist"
        let launchAgentsPath = (loginItemPath as NSString).expandingTildeInPath
        
        return FileManager.default.fileExists(atPath: launchAgentsPath)
    }
    
    /// Toggle launch at login setting
    private func setLaunchAtLogin(_ enabled: Bool) {
        if enabled {
            addToLoginItems()
        } else {
            removeFromLoginItems()
        }
        
        // Save the preference
        UserDefaults.standard.set(enabled, forKey: "LaunchAtLogin")
    }
    
    /// Add app to login items using LaunchAgent (reliable method)
    private func addToLoginItems() {
        do {
            let bundleID = Bundle.main.bundleIdentifier ?? "com.focuswave.app"
            let appPath = Bundle.main.bundlePath
            let loginItemPath = "~/Library/LaunchAgents/\(bundleID).plist"
            
            let plistContent = """
            <?xml version="1.0" encoding="UTF-8"?>
            <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
            <plist version="1.0">
            <dict>
                <key>Label</key>
                <string>\(bundleID)</string>
                <key>ProgramArguments</key>
                <array>
                    <string>\(appPath)/Contents/MacOS/FocusWave</string>
                </array>
                <key>RunAtLoad</key>
                <true/>
                <key>KeepAlive</key>
                <true/>
                <key>ProcessType</key>
                <string>Background</string>
                <key>LimitLoadToSessionType</key>
                <array>
                    <string>Aqua</string>
                </array>
            </dict>
            </plist>
            """
            
            let launchAgentsPath = (loginItemPath as NSString).expandingTildeInPath
            let launchAgentsDir = (launchAgentsPath as NSString).deletingLastPathComponent
            
            // Create directory if it doesn't exist
            try FileManager.default.createDirectory(atPath: launchAgentsDir, withIntermediateDirectories: true)
            
            // Write the plist file
            try plistContent.write(toFile: launchAgentsPath, atomically: true, encoding: .utf8)
            
            // Load the launch agent
            let process = Process()
            process.launchPath = "/bin/launchctl"
            process.arguments = ["load", launchAgentsPath]
            try process.run()
            process.waitUntilExit()
            
            print("✅ Successfully added to login items using LaunchAgent")
            
        } catch {
            print("❌ Failed to add to login items: \(error)")
            // Fallback to AppleScript method
            addToLoginItemsUsingAppleScript()
        }
    }
    
    /// Fallback method using AppleScript
    private func addToLoginItemsUsingAppleScript() {
        let appPath = Bundle.main.bundlePath
        let script = """
        tell application "System Events"
            make login item at end with properties {path:"\(appPath)", hidden:true}
        end tell
        """
        
        let appleScript = NSAppleScript(source: script)
        var error: NSDictionary?
        appleScript?.executeAndReturnError(&error)
        
        if let error = error {
            print("❌ AppleScript fallback also failed: \(error)")
        } else {
            print("✅ Successfully added to login items using AppleScript fallback")
        }
    }
    
    /// Remove app from login items
    private func removeFromLoginItems() {
        do {
            let bundleID = Bundle.main.bundleIdentifier ?? "com.focuswave.app"
            let loginItemPath = "~/Library/LaunchAgents/\(bundleID).plist"
            let launchAgentsPath = (loginItemPath as NSString).expandingTildeInPath
            
            // Unload the launch agent first
            let process = Process()
            process.launchPath = "/bin/launchctl"
            process.arguments = ["unload", launchAgentsPath]
            try process.run()
            process.waitUntilExit()
            
            // Remove the plist file
            try FileManager.default.removeItem(atPath: launchAgentsPath)
            
            print("✅ Successfully removed from login items")
            
        } catch {
            print("❌ Failed to remove from login items: \(error)")
            // Fallback to AppleScript method
            removeFromLoginItemsUsingAppleScript()
        }
    }
    
    /// Fallback method using AppleScript
    private func removeFromLoginItemsUsingAppleScript() {
        let bundleID = Bundle.main.bundleIdentifier ?? "com.focuswave.app"
        let script = """
        tell application "System Events"
            delete login item "\(bundleID)"
        end tell
        """
        
        let appleScript = NSAppleScript(source: script)
        var error: NSDictionary?
        appleScript?.executeAndReturnError(&error)
        
        if let error = error {
            print("❌ AppleScript fallback also failed: \(error)")
        } else {
            print("✅ Successfully removed from login items using AppleScript fallback")
        }
    }
    

    
    // MARK: - Context Menu Management
    
    /// Toggle launch at login setting
    @objc private func toggleLaunchAtLogin() {
        let currentState = isLaunchAtLoginEnabled()
        setLaunchAtLogin(!currentState)
        
        // Update the menu item title to reflect the new state
        if let button = statusItem?.button {
            let menu = createContextMenu()
            let popupPoint = NSPoint(x: 0, y: button.bounds.height - 2)
            menu.popUp(positioning: nil, at: popupPoint, in: button)
        }
    }
    
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
        
        // Add Launch at Login option
        let launchAtLoginItem = NSMenuItem(
            title: isLaunchAtLoginEnabled() ? "✓ Launch at Login" : "Launch at Login",
            action: #selector(toggleLaunchAtLogin),
            keyEquivalent: ""
        )
        launchAtLoginItem.target = self
        menu.addItem(launchAtLoginItem)
        
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
        // App automatically goes to background when popover closes
    }
    
    // MARK: - Window Management
    
    /// Handle app activation/deactivation
    func applicationDidBecomeActive(_ notification: Notification) {
        // App became active
    }
    
    func applicationDidResignActive(_ notification: Notification) {
        // App lost focus - this is normal behavior
    }
    
    /// Clean up observers when app terminates
    func applicationWillTerminate(_ notification: Notification) {
        NotificationCenter.default.removeObserver(self)
        
        // Remove global click monitor
        if let monitor = globalClickMonitor {
            NSEvent.removeMonitor(monitor)
        }
    }
}
