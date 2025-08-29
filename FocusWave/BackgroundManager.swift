import SwiftUI
import AppKit
import CoreImage

@MainActor
class BackgroundManager: ObservableObject {
    @Published var gradientColors: [Color] = [
        Color.blue.opacity(0.8),
        Color.purple.opacity(0.6),
        Color.pink.opacity(0.4)
    ]
    
    init() {
        // Don't call async method from init - will be called when needed
    }
    
    func extractBackgroundColors() async {
        let workspace = NSWorkspace.shared
        
        // Get the current desktop background image
        if let backgroundImage = workspace.desktopImageURL(for: NSScreen.main ?? NSScreen.screens.first ?? NSScreen.screens[0]) {
            await extractColorsFromImage(at: backgroundImage)
        } else {
            // Fallback to default colors if no background image
            setDefaultColors()
        }
    }
    
    // Async version that doesn't block the UI thread
    func extractBackgroundColorsAsync() async {
        let workspace = NSWorkspace.shared
        
        // Get the current desktop background image
        if let backgroundImage = workspace.desktopImageURL(for: NSScreen.main ?? NSScreen.screens.first ?? NSScreen.screens[0]) {
            await extractColorsFromImageAsync(at: backgroundImage)
        } else {
            // Fallback to default colors if no background image
            setDefaultColors()
        }
    }
    
    private func extractColorsFromImage(at url: URL) async {
        guard let image = NSImage(contentsOf: url),
              let cgImage = image.cgImage(forProposedRect: nil, context: nil, hints: nil) else {
            setDefaultColors()
            return
        }
        
        // Create a smaller version for faster processing
        let size = CGSize(width: 100, height: 100)
        let context = CIContext()
        let ciImage = CIImage(cgImage: cgImage)
        
        // Scale down the image
        let scaleFilter = CIFilter(name: "CILanczosScaleTransform")
        scaleFilter?.setValue(ciImage, forKey: kCIInputImageKey)
        scaleFilter?.setValue(size.width / CGFloat(cgImage.width), forKey: kCIInputScaleKey)
        
        guard let scaledImage = scaleFilter?.outputImage else {
            setDefaultColors()
            return
        }
        
        // Extract colors using simple sampling approach
        let colors = await extractDominantColors(from: scaledImage, context: context)
        
        // Create a beautiful gradient from the extracted colors
        await MainActor.run {
            self.gradientColors = colors
        }
    }
    
    // Async version that processes on background thread
    private func extractColorsFromImageAsync(at url: URL) async {
        await Task.detached(priority: .userInitiated) {
            guard let image = NSImage(contentsOf: url),
                  let cgImage = image.cgImage(forProposedRect: nil, context: nil, hints: nil) else {
                await MainActor.run {
                    self.setDefaultColors()
                }
                return
            }
            
            // Create a smaller version for faster processing
            let size = CGSize(width: 100, height: 100)
            let context = CIContext()
            let ciImage = CIImage(cgImage: cgImage)
            
            // Scale down the image
            let scaleFilter = CIFilter(name: "CILanczosScaleTransform")
            scaleFilter?.setValue(ciImage, forKey: kCIInputImageKey)
            scaleFilter?.setValue(size.width / CGFloat(cgImage.width), forKey: kCIInputScaleKey)
            
            guard let scaledImage = scaleFilter?.outputImage else {
                await MainActor.run {
                    self.setDefaultColors()
                }
                return
            }
            
            // Extract colors using simple sampling approach
            let colors = await self.extractDominantColors(from: scaledImage, context: context)
            
            // Update UI on main thread
            await MainActor.run {
                self.gradientColors = colors
            }
        }.value
    }
    
    private func extractDominantColors(from ciImage: CIImage, context: CIContext) async -> [Color] {
        // Simple color extraction - get colors from corners and center
        let corners = [
            CGPoint(x: 0, y: 0),
            CGPoint(x: ciImage.extent.width, y: 0),
            CGPoint(x: 0, y: ciImage.extent.height),
            CGPoint(x: ciImage.extent.width, y: ciImage.extent.height),
            CGPoint(x: ciImage.extent.width / 2, y: ciImage.extent.height / 2)
        ]
        
        var colors: [Color] = []
        
        for point in corners {
            if let color = getColorAt(point: point, in: ciImage, context: context) {
                colors.append(color)
            }
        }
        
        // If we couldn't extract enough colors, add some fallbacks
        while colors.count < 3 {
            colors.append(generateComplementaryColor(from: colors.first ?? .blue))
        }
        
        // Limit to 3-4 colors for a clean gradient
        return Array(colors.prefix(3))
    }
    
    private func getColorAt(point: CGPoint, in ciImage: CIImage, context: CIContext) -> Color? {
        // Create a 1x1 pixel context to sample the color
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedLast.rawValue)
        
        guard let cgContext = CGContext(
            data: nil,
            width: 1,
            height: 1,
            bitsPerComponent: 8,
            bytesPerRow: 4,
            space: colorSpace,
            bitmapInfo: bitmapInfo.rawValue
        ) else { return nil }
        
        // Convert CIImage to CGImage first, then draw
        guard let cgImage = context.createCGImage(ciImage, from: CGRect(x: point.x, y: point.y, width: 1, height: 1)) else {
            return nil
        }
        
        // Draw the CGImage at the origin
        cgContext.draw(cgImage, in: CGRect(x: 0, y: 0, width: 1, height: 1))
        
        // Get the pixel data
        guard let data = cgContext.data else { return nil }
        let ptr = data.bindMemory(to: UInt8.self, capacity: 4)
        
        let r = Double(ptr[0]) / 255.0
        let g = Double(ptr[1]) / 255.0
        let b = Double(ptr[2]) / 255.0
        let a = Double(ptr[3]) / 255.0
        
        // Only use colors with sufficient opacity
        guard a > 0.1 else { return nil }
        
        // Adjust opacity for better gradient appearance
        return Color(red: r, green: g, blue: b).opacity(0.7)
    }
    
    private func generateComplementaryColor(from color: Color) -> Color {
        // Generate a complementary color
        let colors: [Color] = [
            .blue.opacity(0.6),
            .purple.opacity(0.5),
            .pink.opacity(0.4),
            .orange.opacity(0.6),
            .green.opacity(0.5)
        ]
        
        return colors.randomElement() ?? .blue.opacity(0.6)
    }
    
    private func setDefaultColors() {
        gradientColors = [
            Color.blue.opacity(0.8),
            Color.purple.opacity(0.6),
            Color.pink.opacity(0.4)
        ]
    }
}
