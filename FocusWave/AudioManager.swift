import Foundation
import AVFoundation

@MainActor
class AudioManager: NSObject, ObservableObject, AVAudioPlayerDelegate {
    @Published var isPlaying = false
    @Published var volume: Float = 0.5
    @Published var currentSound: String = "Rain"
    @Published var previousVolume: Float = 0.5
    
    // Store playback position for resuming
    private var playbackPosition: TimeInterval = 0
    
    private var audioPlayer: AVAudioPlayer?
    
    let soundOptions = ["Rain"]
    
    override init() {
        // macOS doesn't need AVAudioSession setup
        super.init()
        
        // Load saved volume settings
        loadVolumeSettings()
    }
    
    func addCustomSound(name: String, url: URL) {
        // Add the custom sound to the sound options
        // In a real implementation, you'd also save the file and manage it
        print("Added custom sound: \(name) from \(url)")
        // You could extend this to actually load and play the custom audio file
    }
    
    func playSound(_ soundName: String) {
        guard !isPlaying else { return }
        
        // Reset playback position when switching sounds
        if currentSound != soundName {
            playbackPosition = 0
            print("Switching sounds, resetting playback position")
        }
        
        currentSound = soundName
        // Don't set isPlaying here - wait for audio to actually start
        
        // Only play real audio files
        switch soundName {
        case "Rain":
            playAudioFile(named: "rain.mp3")
        default:
            print("No audio file found for: \(soundName)")
            isPlaying = false
        }
    }
    
    func pauseSound() {
        if let player = audioPlayer {
            // Store the current playback position before pausing
            playbackPosition = player.currentTime
            print("Stored playback position: \(playbackPosition) seconds")
            
            player.stop()
            audioPlayer = nil
        }
        
        isPlaying = false
    }
    
    func setVolume(_ newVolume: Float) {
        volume = newVolume
        
        // Always update the volume, even if not playing
        // This ensures the volume is set for when audio starts
        
        if let player = audioPlayer {
            player.volume = newVolume
        }
        
        // Save volume setting for persistence
        saveVolumeSettings()
        
        print("Volume set to: \(newVolume)")
    }
    
    private func playAudioFile(named fileName: String) {
        // Try multiple possible paths for the Sounds folder
        var audioURL: URL?
        
        // First, try the project directory (where we are now)
        let projectPath = "/Users/mykytagrogul/Documents/GitHub/Focus-Wave/FocusWave"
        let soundsPath = (projectPath as NSString).appendingPathComponent("Sounds")
        let testURL = URL(fileURLWithPath: soundsPath).appendingPathComponent(fileName)
        if FileManager.default.fileExists(atPath: testURL.path) {
            audioURL = testURL
            print("Found audio file in project directory")
        }
        
        // If not found, try the current working directory
        if audioURL == nil {
            let currentPath = FileManager.default.currentDirectoryPath
            let currentSoundsPath = (currentPath as NSString).appendingPathComponent("Sounds")
            let testURL = URL(fileURLWithPath: currentSoundsPath).appendingPathComponent(fileName)
            if FileManager.default.fileExists(atPath: testURL.path) {
                audioURL = testURL
                print("Found audio file in current directory")
            }
        }
        
        // Check if we found the file
        guard let finalURL = audioURL else {
            print("Audio file not found: \(fileName)")
            print("Tried project path: \(soundsPath)")
            print("Tried current path: \(FileManager.default.currentDirectoryPath)/Sounds")
            isPlaying = false
            return
        }
        
        do {
            // Pause any existing audio (this will store the current position)
            pauseSound()
            
            // Create and configure audio player
            audioPlayer = try AVAudioPlayer(contentsOf: finalURL)
            audioPlayer?.volume = volume
            audioPlayer?.numberOfLoops = -1 // Loop indefinitely
            
            // Resume from stored position if available
            if playbackPosition > 0 {
                audioPlayer?.currentTime = playbackPosition
                print("Resuming from position: \(playbackPosition) seconds")
            }
            
            // Start playing and update state
            if audioPlayer?.play() == true {
                isPlaying = true
                print("Playing audio file: \(fileName) from \(finalURL.path)")
            } else {
                print("Failed to start audio playback")
                isPlaying = false
            }
        } catch {
            print("Error playing audio file: \(error)")
            isPlaying = false
        }
    }
    

    
    func togglePlayback() {
        if isPlaying {
            pauseSound()
        } else {
            playSound(currentSound)
        }
    }
    
    // Get current volume as a percentage string
    var volumePercentage: String {
        return "\(Int(volume * 100))%"
    }
    
    // Get current playback time for display
    var currentPlaybackTime: String {
        guard let player = audioPlayer else { return "0:00" }
        let time = Int(player.currentTime)
        let minutes = time / 60
        let seconds = time % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
    
    // Get total duration for display
    var totalDuration: String {
        guard let player = audioPlayer else { return "0:00" }
        let time = Int(player.duration)
        let minutes = time / 60
        let seconds = time % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
    
    // MARK: - AVAudioPlayerDelegate
    
    nonisolated func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        // Handle audio completion if needed
        if flag {
            print("Audio finished playing successfully")
            // Reset playback position when audio finishes
            Task { @MainActor in
                self.playbackPosition = 0
            }
        }
    }
    
    // MARK: - Volume Persistence
    
    private func saveVolumeSettings() {
        UserDefaults.standard.set(volume, forKey: "FocusWave_Volume")
        UserDefaults.standard.set(currentSound, forKey: "FocusWave_CurrentSound")
        print("Volume settings saved: volume=\(volume), sound=\(currentSound)")
    }
    
    private func loadVolumeSettings() {
        // Load saved volume (default to 0.5 if not found)
        let savedVolume = UserDefaults.standard.object(forKey: "FocusWave_Volume") as? Float ?? 0.5
        volume = savedVolume
        previousVolume = savedVolume
        
        // Load saved sound preference (default to "Rain" if not found)
        let savedSound = UserDefaults.standard.string(forKey: "FocusWave_CurrentSound") ?? "Rain"
        currentSound = savedSound
        
        print("Volume settings loaded: volume=\(volume), sound=\(currentSound)")
    }
}
