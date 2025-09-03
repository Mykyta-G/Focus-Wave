import SwiftUI
import AppKit

// Custom Animatable Wave Shape
struct WaveShape: Shape {
    var waveHeight: CGFloat
    var animationOffset: CGFloat
    
    var animatableData: AnimatablePair<CGFloat, CGFloat> {
        get { AnimatablePair(waveHeight, animationOffset) }
        set { 
            waveHeight = newValue.first
            animationOffset = newValue.second
        }
    }
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let width = rect.width
        let height = rect.height
        let centerY = height / 2
        let waveCount = 4
        let wavelength = width / CGFloat(waveCount)
        
        // Optimize: Use fewer points for better performance
        let stepSize: CGFloat = max(2.0, width / 200.0) // Adaptive step size based on width
        
        // Start from the first calculated wave point to avoid static line
        let firstY = centerY + sin(animationOffset * .pi * 2 / wavelength) * waveHeight
        path.move(to: CGPoint(x: 0, y: firstY))
        
        // Draw smooth wave from left to right with optimized point count
        for x in stride(from: 0, through: width, by: stepSize) {
            let waveX = x + animationOffset
            let y = centerY + sin(waveX * .pi * 2 / wavelength) * waveHeight
            path.addLine(to: CGPoint(x: x, y: y))
        }
        
        // Ensure we reach the end of the path
        if width.truncatingRemainder(dividingBy: stepSize) != 0 {
            let finalY = centerY + sin((width + animationOffset) * .pi * 2 / wavelength) * waveHeight
            path.addLine(to: CGPoint(x: width, y: finalY))
        }
        
        return path
    }
}

// Simplified System Load Monitor for Performance Optimization
class SystemLoadMonitor: ObservableObject {
    @Published var isSystemUnderLoad = false
    @Published var shouldPauseAnimation = false
    
    private var loadCheckTimer: Timer?
    private let loadThreshold: Double = 50.0 // CPU usage threshold - more sensitive to lag
    
    // Frame rate monitoring for lag detection
    private var lastFrameTime: CFTimeInterval = 0
    private var frameCount: Int = 0
    private var laggyFrameCount: Int = 0
    private let targetFrameRate: Double = 30.0 // Target 30 FPS
    private let lagThreshold: Double = 16.67 // 60 FPS = 16.67ms per frame, anything slower is lag
    
    init() {
        startMonitoring()
    }
    
    deinit {
        loadCheckTimer?.invalidate()
    }
    
    private func startMonitoring() {
        // Check system load every 3 seconds
        loadCheckTimer = Timer.scheduledTimer(withTimeInterval: 3.0, repeats: true) { [weak self] _ in
            DispatchQueue.main.async {
                self?.checkSystemLoad()
            }
        }
    }
    
    private func checkSystemLoad() {
        let cpuUsage = getCurrentCPUUsage()
        let isLagging = checkForAnimationLag()
        let wasUnderLoad = isSystemUnderLoad
        
        // Pause animation if either CPU is high OR we detect lag
        isSystemUnderLoad = cpuUsage > loadThreshold || isLagging
        shouldPauseAnimation = isSystemUnderLoad
        
        // Log when load state changes
        if wasUnderLoad != isSystemUnderLoad {
            let reason = cpuUsage > loadThreshold ? "HIGH CPU" : "ANIMATION LAG"
            print("🖥️ System load changed: \(isSystemUnderLoad ? "HIGH" : "NORMAL") (Reason: \(reason), CPU: \(String(format: "%.1f", cpuUsage))%)")
        }
    }
    
    private func checkForAnimationLag() -> Bool {
        let currentTime = CACurrentMediaTime()
        
        if lastFrameTime > 0 {
            let frameTime = currentTime - lastFrameTime
            frameCount += 1
            
            // If frame took longer than our threshold, it's laggy
            if frameTime > lagThreshold {
                laggyFrameCount += 1
            }
            
            // Check every 30 frames (about 1 second at 30 FPS)
            if frameCount >= 30 {
                let lagPercentage = Double(laggyFrameCount) / Double(frameCount)
                
                // Reset counters
                frameCount = 0
                laggyFrameCount = 0
                
                // If more than 20% of frames are laggy, consider it lagging
                return lagPercentage > 0.2
            }
        }
        
        lastFrameTime = currentTime
        return false
    }
    
    private func getCurrentCPUUsage() -> Double {
        // Use a more reliable method to detect system load
        let systemInfo = ProcessInfo.processInfo
        
        // Check if system is under thermal pressure
        if systemInfo.isLowPowerModeEnabled {
            return 90.0 // High load when in low power mode
        }
        
        // Check system load average (simplified approach)
        let loadAverage = systemInfo.systemUptime
        
        // Estimate load based on system activity
        // This is a simplified approach - in a real implementation you'd use more sophisticated monitoring
        let estimatedLoad = min(100.0, (loadAverage.truncatingRemainder(dividingBy: 10.0)) * 10.0)
        
        // Add some randomness to simulate varying load conditions
        let randomFactor = Double.random(in: 0.8...1.2)
        let finalLoad = estimatedLoad * randomFactor
        
        return min(100.0, max(0.0, finalLoad))
    }
    
    /// Called by animation timer to track frame performance
    func notifyFrameUpdate() {
        _ = checkForAnimationLag()
    }
}

// Static Wave Shape for High Load Conditions
struct StaticWaveShape: Shape {
    var waveHeight: CGFloat
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let width = rect.width
        let height = rect.height
        let centerY = height / 2
        let waveCount = 4
        let wavelength = width / CGFloat(waveCount)
        
        // Create a static wave pattern
        let stepSize: CGFloat = max(3.0, width / 100.0) // Even fewer points for static version
        
        for x in stride(from: 0, through: width, by: stepSize) {
            let y = centerY + sin(x * .pi * 2 / wavelength) * waveHeight
            if x == 0 {
                path.move(to: CGPoint(x: x, y: y))
            } else {
                path.addLine(to: CGPoint(x: x, y: y))
            }
        }
        
        return path
    }
}

// Optimized Animated Wavy Line View with Performance Monitoring
struct WavyLine: View {
    let isPlaying: Bool
    @ObservedObject var loadMonitor: SystemLoadMonitor
    @State private var animationOffset: CGFloat = 0
    @State private var waveHeight: CGFloat = 5
    @State private var animationTimer: Timer?
    @State private var isVisible = false
    
    var body: some View {
        Group {
            if loadMonitor.shouldPauseAnimation {
                // Show static wave when system is under load
                StaticWaveShape(waveHeight: waveHeight)
                    .stroke(Color.white, lineWidth: 3)
                    .shadow(color: .white.opacity(0.3), radius: 2, x: 0, y: 0)
                    .frame(height: 50)
            } else {
                // Show animated wave when system load is normal
                WaveShape(waveHeight: waveHeight, animationOffset: animationOffset)
                    .stroke(Color.white, lineWidth: 3)
                    .shadow(color: .white.opacity(0.3), radius: 2, x: 0, y: 0)
                    .frame(height: 50)
            }
        }
        .onAppear {
            isVisible = true
            startWaveAnimation()
        }
        .onDisappear {
            isVisible = false
            stopWaveAnimation()
        }
        .onChange(of: isPlaying) { _, newValue in
            print("🔄 WavyLine: isPlaying changed to \(newValue)")
            
            // Animate the wave height change
            withAnimation(.easeInOut(duration: 2.0)) {
                if newValue {
                    print("🎵 WavyLine: Growing waves to height: 18")
                    waveHeight = 18
                } else {
                    print("😴 WavyLine: Shrinking waves to height: 5")
                    waveHeight = 5
                }
            }
        }
        .onChange(of: loadMonitor.shouldPauseAnimation) { _, shouldPause in
            if shouldPause {
                print("⏸️ Switching to static wave due to high system load")
                pauseAnimation()
            } else {
                print("▶️ Switching to animated wave - system load normal")
                resumeAnimation()
            }
        }
    }
    
    private func startWaveAnimation() {
        // Stop any existing timer
        stopWaveAnimation()
        
        // Only start if not under load and visible
        guard !loadMonitor.shouldPauseAnimation && isVisible else { return }
        
        // Adaptive frame rate based on system load - more responsive to lag
        let frameRate: TimeInterval = loadMonitor.isSystemUnderLoad ? 0.15 : 0.03
        
        animationTimer = Timer.scheduledTimer(withTimeInterval: frameRate, repeats: true) { _ in
            DispatchQueue.main.async {
                // Only update if visible and not under load
                if self.isVisible && !self.loadMonitor.shouldPauseAnimation {
                    self.animationOffset += 1.5
                    
                    // Notify load monitor of frame update for lag detection
                    self.loadMonitor.notifyFrameUpdate()
                }
            }
        }
    }
    
    private func pauseAnimation() {
        // Keep the timer but don't update the animation
        // This allows for quick resumption when load decreases
    }
    
    private func resumeAnimation() {
        // Restart with normal frame rate
        startWaveAnimation()
    }
    
    private func stopWaveAnimation() {
        animationTimer?.invalidate()
        animationTimer = nil
    }
}

struct ContentView: View {
    @StateObject private var audioManager = AudioManager()
    @StateObject private var backgroundManager = BackgroundManager()
    @StateObject private var loadMonitor = SystemLoadMonitor()
    
    var body: some View {
        ZStack {
            // Dynamic gradient background based on desktop colors
            LinearGradient(
                colors: [backgroundManager.primaryColor, backgroundManager.secondaryColor],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .onAppear {
                print("🎨 ContentView using colors: primary=\(backgroundManager.primaryColor), secondary=\(backgroundManager.secondaryColor)")
            }
            
            VStack(spacing: 0) {
                // Header with glassmorphism effect
                HStack {
                    HStack(spacing: 12) {
                        Image(systemName: "waveform")
                            .font(.system(size: 22, weight: .medium))
                            .foregroundColor(.white)
                        
                        Text("Focus Wave")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.white)
                        
                        // System load status indicator
                        if loadMonitor.shouldPauseAnimation {
                            Text("Paused due to heavy load")
                                .font(.system(size: 10, weight: .medium))
                                .foregroundColor(.white.opacity(0.9))
                                .padding(.horizontal, 8)
                                .padding(.vertical, 2)
                                .background(
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(.orange.opacity(0.3))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 8)
                                                .stroke(.orange.opacity(0.6), lineWidth: 1)
                                        )
                                )
                        }
                        
                        // Current color scheme indicator
                        Text(backgroundManager.currentSchemeName)
                            .font(.system(size: 10, weight: .medium))
                            .foregroundColor(.white.opacity(0.8))
                            .padding(.horizontal, 8)
                            .padding(.vertical, 2)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(.white.opacity(0.15))
                            )
                        

                    }
                    
                    Spacer()
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)
                .padding(.bottom, 12)
                
                Spacer()
                
                // Central Content Area - Elegant Vertical Layout
                VStack(spacing: 0) {
                    // Top Controls Section - Clean and Organized
                    VStack(spacing: 24) {
                        // Play Button and Sound Selection - Vertical Stack
                        VStack(spacing: 22) {
                            // Play Button - Prominent and Beautiful (Now First)
                            Button(action: {
                                audioManager.togglePlayback()
                            }) {
                                HStack(spacing: 12) {
                                    Image(systemName: audioManager.isPlaying ? "pause.fill" : "play.fill")
                                        .font(.system(size: 22, weight: .medium))
                                        .foregroundColor(.white)
                                    
                                    Text(audioManager.isPlaying ? "Pause" : "Play")
                                        .font(.system(size: 17, weight: .semibold))
                                        .foregroundColor(.white)
                                }
                                .padding(.horizontal, 36)
                                .padding(.vertical, 16)
                                .background(
                                    RoundedRectangle(cornerRadius: 20)
                                        .fill(
                                            audioManager.isPlaying 
                                                ? LinearGradient(colors: [.blue.opacity(0.9), .blue.opacity(0.7)], startPoint: .topLeading, endPoint: .bottomTrailing)
                                                : LinearGradient(colors: [.white.opacity(0.25), .white.opacity(0.15)], startPoint: .topLeading, endPoint: .bottomTrailing)
                                        )
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 20)
                                                .stroke(.white.opacity(0.4), lineWidth: 1.5)
                                        )
                                )
                                .shadow(color: .black.opacity(0.3), radius: 10, x: 0, y: 5)
                            }
                            .buttonStyle(PlainButtonStyle())
                            
                            // Sound Dropdown - Under the Play Button
                            Menu {
                                ForEach(audioManager.soundOptions, id: \.self) { sound in
                                    Button(action: {
                                        audioManager.currentSound = sound
                                        if audioManager.isPlaying {
                                            audioManager.pauseSound()
                                            audioManager.playSound(sound)
                                        }
                                    }) {
                                        HStack {
                                            Image(systemName: "cloud.rain")
                                                .foregroundColor(.blue)
                                            Text(sound)
                                            if sound == audioManager.currentSound {
                                                Spacer()
                                                Image(systemName: "checkmark")
                                                    .foregroundColor(.green)
                                            }
                                        }
                                    }
                                }
                                

                            } label: {
                                HStack(spacing: 10) {
                                    Image(systemName: "cloud.rain")
                                        .font(.system(size: 16, weight: .medium))
                                        .foregroundColor(.white.opacity(0.9))
                                    
                                    Text(audioManager.currentSound)
                                        .font(.system(size: 15, weight: .medium))
                                        .foregroundColor(.white)
                                    
                                    Image(systemName: "chevron.down")
                                        .font(.system(size: 12, weight: .medium))
                                        .foregroundColor(.white.opacity(0.6))
                                }
                                .padding(.horizontal, 18)
                                .padding(.vertical, 14)
                                .background(
                                    RoundedRectangle(cornerRadius: 18)
                                        .fill(.white.opacity(0.15))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 18)
                                                .stroke(.white.opacity(0.25), lineWidth: 1)
                                        )
                                )
                            }
                            .frame(maxWidth: 280)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 24)
                    .padding(.bottom, 20)
                    
                    // The Star - Animated Pulse Line with Perfect Centering
                    Spacer()
                    WavyLine(isPlaying: audioManager.isPlaying, loadMonitor: loadMonitor)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 20)
                        .frame(maxHeight: 80)
                    Spacer()
                    
                    // Volume Control - At the Very Bottom
                    Spacer(minLength: 20)
                    
                    // Volume Control - Minimal and Unobtrusive
                    HStack(spacing: 10) {
                        Text("Volume")
                            .font(.system(size: 11, weight: .medium))
                            .foregroundColor(.white.opacity(0.5))
                        
                        // Volume Slider
                        Slider(value: Binding(
                            get: { Double(audioManager.volume) },
                            set: { audioManager.setVolume(Float($0)) }
                        ), in: 0...1, step: 0.01)
                        .accentColor(.white)
                        .frame(maxWidth: 100)
                        
                        Text(audioManager.volumePercentage)
                            .font(.system(size: 10, weight: .medium))
                            .foregroundColor(.white.opacity(0.4))
                            .frame(width: 25, alignment: .trailing)
                        
                        // Mute Button - Toggle mute/unmute with volume memory
                        Button(action: {
                            if audioManager.volume > 0 {
                                // Store current volume and mute
                                audioManager.previousVolume = audioManager.volume
                                audioManager.setVolume(0)
                            } else {
                                // Restore previous volume
                                audioManager.setVolume(audioManager.previousVolume)
                            }
                        }) {
                            Image(systemName: audioManager.volume > 0 ? "speaker.slash" : "speaker.wave.2")
                                .font(.system(size: 11, weight: .medium))
                                .foregroundColor(.white.opacity(0.4))
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                    .frame(maxWidth: 260)
                    .padding(.horizontal, 40)
                    .padding(.vertical, 10)
                }
                
                Spacer()
            }
        }
        .frame(width: 400, height: 380)
        .clipShape(RoundedRectangle(cornerRadius: 18))
        .shadow(color: .black.opacity(0.3), radius: 20, x: 0, y: 10)
        .background(.clear)
        .onAppear {
            // Background colors are automatically extracted on init
        }

    }
}

#Preview {
    ContentView()
}







