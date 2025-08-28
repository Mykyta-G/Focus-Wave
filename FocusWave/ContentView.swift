import SwiftUI

struct ContentView: View {
    @StateObject private var audioManager = AudioManager()
    @State private var showSettings = false
    
    var body: some View {
        VStack(spacing: 16) {
            // Header
            HStack {
                Image(systemName: "waveform")
                    .font(.title2)
                    .foregroundColor(.blue)
                Text("Focus Wave")
                    .font(.headline)
                    .fontWeight(.semibold)
                Spacer()
            }
            .padding(.horizontal)
            
            Divider()
            
            // Sound Selection
            VStack(alignment: .leading, spacing: 8) {
                Text("Sound")
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Picker("Select Sound", selection: $audioManager.currentSound) {
                    ForEach(audioManager.soundOptions, id: \.self) { sound in
                        Text(sound).tag(sound)
                    }
                }
                .pickerStyle(MenuPickerStyle())
                .frame(maxWidth: .infinity)
                .onChange(of: audioManager.currentSound) { _, newSound in
                    if audioManager.isPlaying {
                        audioManager.stopSound()
                        audioManager.playSound(newSound)
                    }
                }
            }
            .padding(.horizontal)
            
            // Volume Control
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("Volume")
                        .font(.subheadline)
                        .fontWeight(.medium)
                    Spacer()
                    Text("\(Int(audioManager.volume * 100))%")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Slider(value: Binding(
                    get: { Double(audioManager.volume) },
                    set: { audioManager.setVolume(Float($0)) }
                ), in: 0...1, step: 0.01)
                .accentColor(.blue)
            }
            .padding(.horizontal)
            
            // Play/Stop Button
            Button(action: {
                audioManager.togglePlayback()
            }) {
                HStack {
                    Image(systemName: audioManager.isPlaying ? "stop.fill" : "play.fill")
                    Text(audioManager.isPlaying ? "Stop" : "Play")
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(audioManager.isPlaying ? Color.red : Color.blue)
                .foregroundColor(.white)
                .cornerRadius(8)
            }
            .buttonStyle(PlainButtonStyle())
            .padding(.horizontal)
            
            // Quick Actions
            HStack(spacing: 12) {
                Button(action: {
                    // Quick mute action
                    audioManager.setVolume(0)
                }) {
                    Image(systemName: "speaker.slash")
                        .font(.title3)
                        .foregroundColor(.secondary)
                }
                .buttonStyle(PlainButtonStyle())
                
                Spacer()
                
                Button(action: {
                    showSettings.toggle()
                }) {
                    Image(systemName: "gearshape")
                        .font(.title3)
                        .foregroundColor(.secondary)
                }
                .buttonStyle(PlainButtonStyle())
            }
            .padding(.horizontal)
            
            Spacer()
        }
        .frame(width: 280, height: 320)
        .padding(.vertical)
        .sheet(isPresented: $showSettings) {
            SettingsView()
        }
    }
}

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var autoStart = false
    @State private var fadeInOut = true
    @State private var defaultVolume: Double = 0.5
    
    var body: some View {
        NavigationView {
            Form {
                Section("Playback") {
                    Toggle("Auto-start on launch", isOn: $autoStart)
                    Toggle("Fade in/out", isOn: $fadeInOut)
                    
                    VStack(alignment: .leading) {
                        Text("Default Volume")
                        Slider(value: $defaultVolume, in: 0...1, step: 0.01)
                        Text("\(Int(defaultVolume * 100))%")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                Section("About") {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text("1.0.0")
                            .foregroundColor(.secondary)
                    }
                }
            }
            .navigationTitle("Settings")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
        .frame(width: 400, height: 300)
    }
}

#Preview {
    ContentView()
}
