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
                
                // Central Content Area - Pulse Line as the star
                VStack(spacing: 0) {
                    // Top Section - Sound Selection with Play Button Overlay
                    ZStack {
                        // Sound Selection Dropdown - Background
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Sound")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(.white.opacity(0.9))
                            
                            Menu {
                                ForEach(audioManager.soundOptions, id: \.self) { sound in
                                    Button(action: {
                                        audioManager.currentSound = sound
                                        if audioManager.isPlaying {
                                            audioManager.stopSound()
                                            audioManager.playSound(sound)
                                        }
                                    }) {
                                        HStack {
                                            Image(systemName: "waveform")
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
                                HStack {
                                    Image(systemName: "waveform")
                                        .font(.system(size: 14, weight: .medium))
                                        .foregroundColor(.white.opacity(0.8))
                                    
                                    Text(audioManager.currentSound)
                                        .foregroundColor(.white)
                                        .font(.system(size: 13, weight: .medium))
                                    
                                    Spacer()
                                    
                                    Image(systemName: "chevron.down.circle")
                                        .font(.system(size: 14, weight: .medium))
                                        .foregroundColor(.white.opacity(0.7))
                                }
                                .padding(.horizontal, 16)
                                .padding(.vertical, 12)
                                .background(
                                    RoundedRectangle(cornerRadius: 14)
                                        .fill(.white.opacity(0.12))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 14)
                                                .stroke(.white.opacity(0.2), lineWidth: 1)
                                        )
                                )
                            }
                        }
                        .frame(maxWidth: .infinity)
                        
                        // Play Button - Floating over the dropdown
                        HStack {
                            Spacer()
                            
                            Button(action: {
                                audioManager.togglePlayback()
                            }) {
                                HStack(spacing: 6) {
                                    Image(systemName: audioManager.isPlaying ? "stop.fill" : "play.fill")
                                        .font(.system(size: 16, weight: .medium))
                                        .foregroundColor(.white)
                                    
                                    Text(audioManager.isPlaying ? "Stop" : "Play")
                                        .font(.system(size: 13, weight: .semibold))
                                        .foregroundColor(.white)
                                }
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(
                                            audioManager.isPlaying 
                                                ? LinearGradient(colors: [.red.opacity(0.8), .red.opacity(0.6)], startPoint: .topLeading, endPoint: .bottomTrailing)
                                                : LinearGradient(colors: [.white.opacity(0.25), .white.opacity(0.15)], startPoint: .topLeading, endPoint: .bottomTrailing)
                                        )
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 12)
                                                .stroke(.white.opacity(0.3), lineWidth: 1)
                                        )
                                )
                                .shadow(color: .black.opacity(0.2), radius: 4, x: 0, y: 2)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                        .padding(.trailing, 20)
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 20)
                    
                    // The Star of the Show - Animated Pulse Line
                    AnimatedPulseLine(isPlaying: audioManager.isPlaying)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 10)
                    
                    // Bottom Section - Compact Volume Control
                    VStack(spacing: 12) {
                        // Volume Control - Shorter width, centered
                        VStack(alignment: .center, spacing: 8) {
                            HStack {
                                Text("Volume")
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(.white.opacity(0.9))
                                
                                Spacer()
                                
                                Text(audioManager.volumePercentage)
                                    .font(.system(size: 12, weight: .medium))
                                    .foregroundColor(.white.opacity(0.8))
                            }
                            
                            HStack(spacing: 12) {
                                // Volume Slider
                                Slider(value: Binding(
                                    get: { Double(audioManager.volume) },
                                    set: { audioManager.setVolume(Float($0)) }
                                ), in: 0...1, step: 0.01)
                                .accentColor(.white)
                                .background(
                                    RoundedRectangle(cornerRadius: 6)
                                        .fill(.white.opacity(0.1))
                                        .frame(height: 6)
                                )
                                
                                // Mute Button - Compact
                                Button(action: {
                                    audioManager.setVolume(0)
                                }) {
                                    Image(systemName: "speaker.slash")
                                        .font(.system(size: 14, weight: .medium))
                                        .foregroundColor(.white.opacity(0.8))
                                        .padding(8)
                                        .background(
                                            RoundedRectangle(cornerRadius: 8)
                                                .fill(.white.opacity(0.1))
                                                .overlay(
                                                    RoundedRectangle(cornerRadius: 8)
                                                        .stroke(.white.opacity(0.2), lineWidth: 1)
                                                )
                                        )
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                        .frame(maxWidth: 300) // Shorter width as requested
                        .padding(.horizontal, 20)
                        .padding(.vertical, 16)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(.white.opacity(0.08))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16)
                                        .stroke(.white.opacity(0.15), lineWidth: 1)
                                        .blur(radius: 0.5)
                                )
                        )
                    }
                    .padding(.top, 20)
                }
                
                Spacer()
            }
        }
        .frame(width: 500, height: 320)
        .clipShape(RoundedRectangle(cornerRadius: 18))
        .shadow(color: .black.opacity(0.3), radius: 20, x: 0, y: 10)
        .onAppear {
            backgroundManager.extractBackgroundColors()
        }
    }
}

#Preview {
    ContentView()
}







