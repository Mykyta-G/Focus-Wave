import Foundation
import AVFoundation

@MainActor
class AudioManager: ObservableObject {
    @Published var isPlaying = false
    @Published var volume: Float = 0.5
    @Published var currentSound: String = "White Noise"
    @Published var previousVolume: Float = 0.5
    
    private var audioPlayer: AVAudioPlayer?
    private var audioEngine: AVAudioEngine?
    private var playerNode: AVAudioPlayerNode?
    
    let soundOptions = ["White Noise", "Rain", "Ocean", "Forest", "Cafe", "Fireplace"]
    
    init() {
        // macOS doesn't need AVAudioSession setup
        // Initialize with default volume
        volume = 0.5
    }
    
    func addCustomSound(name: String, url: URL) {
        // Add the custom sound to the sound options
        // In a real implementation, you'd also save the file and manage it
        print("Added custom sound: \(name) from \(url)")
        // You could extend this to actually load and play the custom audio file
    }
    
    func playSound(_ soundName: String) {
        guard !isPlaying else { return }
        
        currentSound = soundName
        isPlaying = true
        
        // For now, we'll generate white noise programmatically
        // In a real app, you'd load actual audio files
        generateWhiteNoise()
    }
    
    func stopSound() {
        isPlaying = false
        
        if let player = audioPlayer {
            player.stop()
            audioPlayer = nil
        }
        
        if let node = playerNode {
            node.stop()
            playerNode = nil
        }
    }
    
    func setVolume(_ newVolume: Float) {
        volume = newVolume
        
        // Always update the volume, even if not playing
        // This ensures the volume is set for when audio starts
        
        if let player = audioPlayer {
            player.volume = newVolume
        }
        
        if let node = playerNode {
            node.volume = newVolume
        }
        
        // If we have an active audio engine, update its volume too
        if let engine = audioEngine {
            engine.mainMixerNode.outputVolume = newVolume
        }
        
        print("Volume set to: \(newVolume)")
    }
    
    private func generateWhiteNoise() {
        // Generate white noise buffer
        let sampleRate: Double = 44100
        let duration: Double = 1.0 // 1 second buffer that loops
        let frameCount = Int(sampleRate * duration)
        
        var audioBuffer = [Float](repeating: 0.0, count: frameCount)
        
        for i in 0..<frameCount {
            // Generate random white noise
            audioBuffer[i] = Float.random(in: -0.5...0.5)
        }
        
        // Create audio buffer
        let format = AVAudioFormat(standardFormatWithSampleRate: sampleRate, channels: 1)!
        let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: AVAudioFrameCount(frameCount))!
        buffer.frameLength = AVAudioFrameCount(frameCount)
        
        // Copy audio data
        let channelData = buffer.floatChannelData![0]
        for i in 0..<frameCount {
            channelData[i] = audioBuffer[i]
        }
        
        // Setup audio engine for continuous playback
        audioEngine = AVAudioEngine()
        playerNode = AVAudioPlayerNode()
        
        guard let engine = audioEngine, let node = playerNode else { return }
        
        engine.attach(node)
        engine.connect(node, to: engine.mainMixerNode, format: format)
        
        // Set the volume before starting
        engine.mainMixerNode.outputVolume = volume
        node.volume = volume
        
        do {
            try engine.start()
            
            // Schedule the buffer to loop
            node.scheduleBuffer(buffer, at: nil, options: .loops, completionHandler: nil)
            node.play()
            
            print("Started playing white noise at volume: \(volume)")
            
        } catch {
            print("Failed to start audio engine: \(error)")
            isPlaying = false
        }
    }
    
    func togglePlayback() {
        if isPlaying {
            stopSound()
        } else {
            playSound(currentSound)
        }
    }
    
    // Get current volume as a percentage string
    var volumePercentage: String {
        return "\(Int(volume * 100))%"
    }
}
