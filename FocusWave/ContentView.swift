import SwiftUI
import AppKit

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
                            .font(.system(size: 24, weight: .medium))
                            .foregroundColor(.white)
                        
                        Text("Focus Wave")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(.white)
                        
                        // Sync indicator
                        HStack(spacing: 4) {
                            Image(systemName: "paintbrush")
                                .font(.system(size: 12, weight: .medium))
                            Text("Synced")
                                .font(.system(size: 11, weight: .medium))
                        }
                        .foregroundColor(.white.opacity(0.7))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(.white.opacity(0.15))
                        )
                    }
                    
                    Spacer()
                    

                }
                .padding(.horizontal, 24)
                .padding(.top, 20)
                .padding(.bottom, 16)
                
                // Main content area with glassmorphism
                HStack(spacing: 30) {
                    // Left Column - Sound Selection and Volume
                    VStack(spacing: 24) {
                        // Sound Selection - Overhauled dropdown design
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Sound")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.white)
                            
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
                                        .font(.system(size: 16, weight: .medium))
                                        .foregroundColor(.white.opacity(0.8))
                                    
                                    Text(audioManager.currentSound)
                                        .foregroundColor(.white)
                                        .font(.system(size: 15, weight: .medium))
                                    
                                    Spacer()
                                    
                                    Image(systemName: "chevron.down.circle")
                                        .font(.system(size: 16, weight: .medium))
                                        .foregroundColor(.white.opacity(0.7))
                                }
                                .padding(.horizontal, 16)
                                .padding(.vertical, 14)
                                .background(
                                    RoundedRectangle(cornerRadius: 14)
                                        .fill(.white.opacity(0.15))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 14)
                                                .stroke(.white.opacity(0.25), lineWidth: 1.5)
                                        )
                                )
                            }
                        }
                        
                        // Volume Control - Sleek slider design
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Text("Volume")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(.white)
                                
                                Spacer()
                                
                                Text(audioManager.volumePercentage)
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(.white.opacity(0.8))
                            }
                            
                            // Interactive volume slider
                            Slider(value: Binding(
                                get: { Double(audioManager.volume) },
                                set: { audioManager.setVolume(Float($0)) }
                            ), in: 0...1, step: 0.01)
                            .accentColor(.white)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(.white.opacity(0.1))
                                    .frame(height: 8)
                            )
                            
                            // Volume change feedback
                            if !audioManager.isPlaying {
                                Text("Volume will apply when you start playing")
                                    .font(.caption)
                                    .foregroundColor(.white.opacity(0.6))
                                    .padding(.top, 4)
                            }
                        }
                    }
                    .frame(maxWidth: .infinity)
                    
                    // Right Column - Playback Controls and Quick Actions
                    VStack(spacing: 24) {
                        // Play/Stop Button - Large, prominent design
                        Button(action: {
                            audioManager.togglePlayback()
                        }) {
                            VStack(spacing: 12) {
                                Image(systemName: audioManager.isPlaying ? "stop.fill" : "play.fill")
                                    .font(.system(size: 36, weight: .medium))
                                    .foregroundColor(.white)
                                
                                Text(audioManager.isPlaying ? "Stop" : "Play")
                                    .font(.system(size: 18, weight: .semibold))
                                    .foregroundColor(.white)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 24)
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(
                                        audioManager.isPlaying 
                                            ? LinearGradient(colors: [.red.opacity(0.8), .red.opacity(0.6)], startPoint: .topLeading, endPoint: .bottomTrailing)
                                            : LinearGradient(colors: [.white.opacity(0.25), .white.opacity(0.15)], startPoint: .topLeading, endPoint: .bottomTrailing)
                                    )
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 16)
                                            .stroke(.white.opacity(0.3), lineWidth: 1)
                                    )
                            )
                        }
                        .buttonStyle(PlainButtonStyle())
                        
                        // Mute Button - Now full width since timer is removed
                        Button(action: {
                            audioManager.setVolume(0)
                        }) {
                            HStack(spacing: 12) {
                                Image(systemName: "speaker.slash")
                                    .font(.system(size: 20, weight: .medium))
                                    .foregroundColor(.white.opacity(0.9))
                                Text("Mute")
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(.white.opacity(0.9))
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 18)
                            .background(
                                RoundedRectangle(cornerRadius: 14)
                                    .fill(.white.opacity(0.1))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 14)
                                            .stroke(.white.opacity(0.2), lineWidth: 1)
                                    )
                            )
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                    .frame(maxWidth: .infinity)
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 24)
            }
        }
        .frame(width: 600, height: 350)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .shadow(color: .black.opacity(0.3), radius: 20, x: 0, y: 10)

        .onAppear {
            backgroundManager.extractBackgroundColors()
        }
    }
}

#Preview {
    ContentView()
}







