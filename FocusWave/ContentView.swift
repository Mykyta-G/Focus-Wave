import SwiftUI
import AppKit

struct ContentView: View {
    @StateObject private var audioManager = AudioManager()
    @StateObject private var backgroundManager = BackgroundManager()
    @State private var showImportSheet = false
    @State private var showSettings = false
    
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
                    
                    HStack(spacing: 12) {
                        // Import Button
                        Button(action: {
                            showImportSheet.toggle()
                        }) {
                            HStack(spacing: 6) {
                                Image(systemName: "plus.circle")
                                    .font(.system(size: 16, weight: .medium))
                                Text("Import")
                                    .font(.system(size: 14, weight: .medium))
                            }
                            .foregroundColor(.white)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(
                                RoundedRectangle(cornerRadius: 20)
                                    .fill(.white.opacity(0.2))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 20)
                                            .stroke(.white.opacity(0.3), lineWidth: 1)
                                    )
                            )
                        }
                        .buttonStyle(PlainButtonStyle())
                        
                        // Settings Button
                        Button(action: {
                            showSettings.toggle()
                        }) {
                            Image(systemName: "gearshape")
                                .font(.system(size: 18, weight: .medium))
                                .foregroundColor(.white.opacity(0.8))
                                .padding(8)
                                .background(
                                    Circle()
                                        .fill(.white.opacity(0.15))
                                        .overlay(
                                            Circle()
                                                .stroke(.white.opacity(0.2), lineWidth: 1)
                                        )
                                )
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
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
                                
                                Divider()
                                
                                Button("Import Custom Sound...") {
                                    showImportSheet.toggle()
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
        .frame(width: 520, height: 300)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .shadow(color: .black.opacity(0.3), radius: 20, x: 0, y: 10)
        .sheet(isPresented: $showImportSheet) {
            ImportSoundView(audioManager: audioManager)
        }
        .sheet(isPresented: $showSettings) {
            SettingsView(backgroundManager: backgroundManager, audioManager: audioManager)
        }
        .onAppear {
            backgroundManager.extractBackgroundColors()
        }
    }
}

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var backgroundManager: BackgroundManager
    @ObservedObject var audioManager: AudioManager
    @State private var autoStart = false
    @State private var fadeInOut = true
    @State private var defaultVolume: Double = 0.5
    
    init(backgroundManager: BackgroundManager, audioManager: AudioManager) {
        self.backgroundManager = backgroundManager
        self.audioManager = audioManager
        self._defaultVolume = State(initialValue: Double(audioManager.volume))
    }
    
    var body: some View {
        ZStack {
            // Background with subtle gradient
            LinearGradient(
                colors: [
                    Color(NSColor.controlBackgroundColor),
                    Color(NSColor.controlBackgroundColor).opacity(0.8)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header with glassmorphism effect
                VStack(spacing: 16) {
                    HStack {
                        Image(systemName: "gearshape.fill")
                            .font(.system(size: 24, weight: .medium))
                            .foregroundColor(.blue)
                        
                        Text("Settings")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        Spacer()
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 20)
                    
                    Divider()
                        .padding(.horizontal, 24)
                }
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Background Colors Section
                        VStack(alignment: .leading, spacing: 16) {
                            HStack {
                                Image(systemName: "paintbrush.fill")
                                    .font(.title3)
                                    .foregroundColor(.blue)
                                Text("Background Colors")
                                    .font(.headline)
                                    .fontWeight(.semibold)
                            }
                            
                            Text("Colors are automatically synced to your desktop background")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.leading)
                            
                            // Current gradient preview with enhanced styling
                            VStack(spacing: 12) {
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(
                                        LinearGradient(
                                            colors: backgroundManager.gradientColors,
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .frame(height: 80)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 16)
                                            .stroke(.blue.opacity(0.3), lineWidth: 2)
                                    )
                                    .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
                                
                                Button(action: {
                                    backgroundManager.extractBackgroundColors()
                                }) {
                                    HStack(spacing: 8) {
                                        Image(systemName: "arrow.clockwise")
                                            .font(.system(size: 14, weight: .medium))
                                        Text("Refresh Background Colors")
                                            .font(.system(size: 14, weight: .medium))
                                    }
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 10)
                                    .background(
                                        RoundedRectangle(cornerRadius: 20)
                                            .fill(.blue)
                                    )
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                        .padding(.horizontal, 24)
                        
                        Divider()
                            .padding(.horizontal, 24)
                        
                        // Playback Settings Section
                        VStack(alignment: .leading, spacing: 16) {
                            HStack {
                                Image(systemName: "play.circle.fill")
                                    .font(.title3)
                                    .foregroundColor(.green)
                                Text("Playback Settings")
                                    .font(.headline)
                                    .fontWeight(.semibold)
                            }
                            
                            VStack(spacing: 16) {
                                // Auto-start toggle with enhanced styling
                                HStack {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("Auto-start on launch")
                                            .font(.system(size: 14, weight: .medium))
                                        Text("Automatically start playing when the app launches")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                    
                                    Spacer()
                                    
                                    Toggle("", isOn: $autoStart)
                                        .toggleStyle(SwitchToggleStyle(tint: .blue))
                                }
                                .padding(.horizontal, 16)
                                .padding(.vertical, 12)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color(NSColor.controlBackgroundColor).opacity(0.5))
                                )
                                
                                // Fade in/out toggle
                                HStack {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("Fade in/out")
                                            .font(.system(size: 14, weight: .medium))
                                        Text("Smoothly fade audio when starting/stopping")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                    
                                    Spacer()
                                    
                                    Toggle("", isOn: $fadeInOut)
                                        .toggleStyle(SwitchToggleStyle(tint: .blue))
                                }
                                .padding(.horizontal, 16)
                                .padding(.vertical, 12)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color(NSColor.controlBackgroundColor).opacity(0.5))
                                )
                                
                                // Default volume slider - Now connected to audioManager
                                VStack(alignment: .leading, spacing: 8) {
                                    HStack {
                                        Text("Default Volume")
                                            .font(.system(size: 14, weight: .medium))
                                        Spacer()
                                        Text("\(Int(defaultVolume * 100))%")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                            .padding(.horizontal, 8)
                                            .padding(.vertical, 4)
                                            .background(
                                                RoundedRectangle(cornerRadius: 8)
                                                    .fill(.blue.opacity(0.1))
                                            )
                                    }
                                    
                                    Slider(value: $defaultVolume, in: 0...1, step: 0.01)
                                        .accentColor(.blue)
                                        .onChange(of: defaultVolume) { _, newValue in
                                            // Update the audioManager volume in real-time
                                            audioManager.setVolume(Float(newValue))
                                        }
                                }
                                .padding(.horizontal, 16)
                                .padding(.vertical, 12)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color(NSColor.controlBackgroundColor).opacity(0.5))
                                )
                            }
                        }
                        .padding(.horizontal, 24)
                        
                        // About Section
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Image(systemName: "info.circle.fill")
                                    .font(.title3)
                                    .foregroundColor(.orange)
                                Text("About")
                                    .font(.headline)
                                    .fontWeight(.semibold)
                            }
                            
                            HStack {
                                Text("Version")
                                    .font(.system(size: 14, weight: .medium))
                                Spacer()
                                Text("1.0.0")
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(.secondary)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(
                                        RoundedRectangle(cornerRadius: 8)
                                            .fill(.orange.opacity(0.1))
                                    )
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 12)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color(NSColor.controlBackgroundColor).opacity(0.5))
                            )
                        }
                        .padding(.horizontal, 24)
                        .padding(.bottom, 24)
                    }
                }
            }
        }
        .frame(width: 480, height: 520)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .shadow(color: .black.opacity(0.2), radius: 20, x: 0, y: 10)
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(.blue.opacity(0.1), lineWidth: 1)
        )
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel") {
                    // Only close the settings window, not the main app
                    dismiss()
                }
                .buttonStyle(.bordered)
            }
            
            ToolbarItem(placement: .confirmationAction) {
                Button("Done") {
                    // Save settings and close
                    dismiss()
                }
                .buttonStyle(.borderedProminent)
            }
        }
    }
}

struct ImportSoundView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var audioManager: AudioManager
    @State private var selectedFile: URL?
    @State private var customSoundName = ""
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                VStack(spacing: 16) {
                    Image(systemName: "waveform.badge.plus")
                        .font(.system(size: 48))
                        .foregroundColor(.blue)
                    
                    Text("Import Custom Sound")
                        .font(.title2)
                        .fontWeight(.semibold)
                    
                    Text("Add your own audio files to the sound library")
                        .font(.body)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                
                VStack(spacing: 16) {
                    // File picker button
                    Button("Choose Audio File") {
                        let panel = NSOpenPanel()
                        panel.allowedContentTypes = [.audio]
                        panel.allowsMultipleSelection = false
                        
                        if panel.runModal() == .OK {
                            selectedFile = panel.url
                            if let fileName = panel.url?.deletingPathExtension().lastPathComponent {
                                customSoundName = fileName
                            }
                        }
                    }
                    .buttonStyle(.borderedProminent)
                    
                    if let selectedFile = selectedFile {
                        VStack(spacing: 8) {
                            Text("Selected: \(selectedFile.lastPathComponent)")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            
                            TextField("Sound Name", text: $customSoundName)
                                .textFieldStyle(.roundedBorder)
                                .frame(maxWidth: 300)
                        }
                    }
                }
                
                Spacer()
            }
            .padding(24)
            .navigationTitle("Import Sound")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Import") {
                        if let selectedFile = selectedFile, !customSoundName.isEmpty {
                            // Here you would add the sound to the audioManager
                            // For now, we'll just add it to the sound options
                            audioManager.addCustomSound(name: customSoundName, url: selectedFile)
                            dismiss()
                        }
                    }
                    .disabled(selectedFile == nil || customSoundName.isEmpty)
                }
            }
        }
        .frame(width: 400, height: 300)
    }
}

#Preview {
    ContentView()
}
