import SwiftUI
import AppKit

// Animated Pulse Line View
struct AnimatedPulseLine: View {
    let isPlaying: Bool
    @State private var animationPhase: CGFloat = 0
    
    var body: some View {
        GeometryReader { geometry in
            Path { path in
                let width = geometry.size.width
                let height = geometry.size.height
                let centerY = height / 2
                
                path.move(to: CGPoint(x: 0, y: centerY))
                
                if isPlaying {
                    // Animated wave when playing
                    for x in stride(from: 0, through: width, by: 2) {
                        let progress = x / width
                        let waveHeight = sin((progress * 8 + animationPhase) * .pi) * 18
                        let y = centerY + waveHeight
                        path.addLine(to: CGPoint(x: x, y: y))
                    }
                } else {
                    // Straight line when not playing
                    path.addLine(to: CGPoint(x: width, y: centerY))
                }
            }
            .stroke(
                LinearGradient(
                    colors: [.white.opacity(0.95), .white.opacity(0.7), .white.opacity(0.4)],
                    startPoint: .leading,
                    endPoint: .trailing
                ),
                lineWidth: 3
            )
            .shadow(color: .white.opacity(0.5), radius: 8, x: 0, y: 0)
        }
        .frame(height: 50)
        .onAppear {
            if isPlaying {
                withAnimation(.linear(duration: 2).repeatForever(autoreverses: false)) {
                    animationPhase = 2 * .pi
                }
            }
        }
        .onChange(of: isPlaying) { _, newValue in
            if newValue {
                withAnimation(.linear(duration: 2).repeatForever(autoreverses: false)) {
                    animationPhase = 2 * .pi
                }
            } else {
                withAnimation(.easeOut(duration: 0.5)) {
                    animationPhase = 0
                }
            }
        }
    }
}

struct ContentView: View {
    @StateObject private var audioManager = AudioManager()
    @StateObject private var backgroundManager = BackgroundManager()
    
    var body: some View {
        ZStack {
            // Dynamic gradient background based on desktop colors
            LinearGradient(
                colors: backgroundManager.gradientColors,
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            
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
                        
                        // Sync indicator
                        HStack(spacing: 4) {
                            Image(systemName: "paintbrush")
                                .font(.system(size: 11, weight: .medium))
                            Text("Synced")
                                .font(.system(size: 10, weight: .medium))
                        }
                        .foregroundColor(.white.opacity(0.7))
                        .padding(.horizontal, 6)
                        .padding(.vertical, 3)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
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
                    AnimatedPulseLine(isPlaying: audioManager.isPlaying)
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
            // Use async to avoid blocking the UI thread
            Task {
                await backgroundManager.extractBackgroundColorsAsync()
            }
        }
    }
}

#Preview {
    ContentView()
}







