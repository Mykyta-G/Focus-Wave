import SwiftUI
import AppKit
import CoreImage

@MainActor
class BackgroundManager: ObservableObject {
    @Published var primaryColor: Color = Color.orange.opacity(0.9)    // Warm coral
    @Published var secondaryColor: Color = Color.purple.opacity(0.7)  // Soft lavender
    @Published var currentSchemeName: String = "Sunset Serenity"
    @Published var isBackgroundSynced: Bool = true  // Always synced since we use static colors
    
    init() {
        print("🚀 BackgroundManager initialized")
        
        // Load saved theme or use default
        loadSavedTheme()
        
        // Listen for color change notifications from the menu bar
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleColorChange),
            name: NSNotification.Name("ChangeColors"),
            object: nil
        )
    }
    
    @objc private func handleColorChange(_ notification: Notification) {
        guard let userInfo = notification.userInfo,
              let primary = userInfo["primary"] as? Color,
              let secondary = userInfo["secondary"] as? Color,
              let name = userInfo["name"] as? String else {
            return
        }
        
        DispatchQueue.main.async {
            self.primaryColor = primary
            self.secondaryColor = secondary
            self.currentSchemeName = name
            print("🎨 Colors changed to: \(name)")
            
            // Save the selected theme
            self.saveTheme(primary: primary, secondary: secondary, name: name)
        }
    }
    
    // MARK: - Theme Persistence
    
    private func saveTheme(primary: Color, secondary: Color, name: String) {
        let defaults = UserDefaults.standard
        
        // Just save the theme name - we'll recreate colors from predefined values
        defaults.set(name, forKey: "FocusWave_ThemeName")
        
        print("💾 Theme saved: \(name)")
    }
    
    private func loadSavedTheme() {
        let defaults = UserDefaults.standard
        
        // Check if we have a saved theme
        if let themeName = defaults.string(forKey: "FocusWave_ThemeName") {
            // Recreate colors from the saved theme name
            let (primary, secondary) = getColorsForTheme(themeName)
            
            // Set the saved theme
            self.primaryColor = primary
            self.secondaryColor = secondary
            self.currentSchemeName = themeName
            
            print("📱 Loaded saved theme: \(themeName)")
        } else {
            // No saved theme, use default Sunset Serenity
            self.primaryColor = Color.orange.opacity(0.9)
            self.secondaryColor = Color.purple.opacity(0.7)
            self.currentSchemeName = "Sunset Serenity"
            print("🎨 Using default theme: Sunset Serenity")
        }
    }
    
    private func getColorsForTheme(_ themeName: String) -> (primary: Color, secondary: Color) {
        switch themeName {
        case "Sunset Serenity":
            return (Color.orange.opacity(0.9), Color.purple.opacity(0.7))
        case "Ocean Depths":
            return (Color.blue.opacity(0.8), Color.teal.opacity(0.6))
        case "Forest Focus":
            return (Color.green.opacity(0.8), Color.mint.opacity(0.6))
        case "Midnight Elegance":
            return (Color.purple.opacity(0.8), Color.indigo.opacity(0.6))
        case "Aurora Dreams":
            return (Color.cyan.opacity(0.8), Color.pink.opacity(0.6))
        case "Fire & Ice":
            return (Color.red.opacity(0.8), Color.orange.opacity(0.6))
        default:
            return (Color.orange.opacity(0.9), Color.purple.opacity(0.7))
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}
