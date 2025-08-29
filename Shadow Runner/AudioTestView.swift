import SwiftUI
import AVFoundation

struct AudioTestView: View {
    @StateObject private var audioManager = AudioManager()
    @State private var showDebugInfo = false
    @State private var testResults: [String] = []
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Audio Test - TestFlight Debug")
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(.white)
            
            VStack(spacing: 15) {
                Button("Test Jump Sound") {
                    testJumpSound()
                }
                .buttonStyle(.borderedProminent)
                
                Button("Test Background Music") {
                    testBackgroundMusic()
                }
                .buttonStyle(.borderedProminent)
                
                Button("Stop Background Music") {
                    audioManager.stopBackgroundMusic()
                    addTestResult("Background music stopped")
                }
                .buttonStyle(.bordered)
                
                Button("Toggle Background Music") {
                    audioManager.toggleBackgroundMusic()
                    addTestResult("Background music toggled")
                }
                .buttonStyle(.bordered)
                
                Button("Toggle Jump Sound") {
                    audioManager.toggleJumpSound()
                    addTestResult("Jump sound toggled")
                }
                .buttonStyle(.bordered)
                
                Button("Run Full Audio Test") {
                    runFullAudioTest()
                }
                .buttonStyle(.borderedProminent)
                .foregroundColor(.orange)
            }
            
            Button("Show Debug Info") {
                showDebugInfo.toggle()
                if showDebugInfo {
                    audioManager.debugAudioStatus()
                }
            }
            .buttonStyle(.bordered)
            
            if showDebugInfo {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Debug Info:")
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    Text("Jump Sound: \(audioManager.jumpSound != nil ? "✅ Loaded" : "❌ Not loaded")")
                        .foregroundColor(.white)
                    Text("Background Music: \(audioManager.backgroundMusic != nil ? "✅ Loaded" : "❌ Not loaded")")
                        .foregroundColor(.white)
                    Text("Jump Enabled: \(audioManager.isJumpSoundEnabled ? "✅ Yes" : "❌ No")")
                        .foregroundColor(.white)
                    Text("Music Enabled: \(audioManager.isBackgroundMusicEnabled ? "✅ Yes" : "❌ No")")
                        .foregroundColor(.white)
                }
                .padding()
                .background(Color.gray.opacity(0.3))
                .cornerRadius(8)
            }
            
            if !testResults.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Test Results:")
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    ScrollView {
                        VStack(alignment: .leading, spacing: 4) {
                            ForEach(testResults, id: \.self) { result in
                                Text(result)
                                    .font(.caption)
                                    .foregroundColor(.white.opacity(0.8))
                            }
                        }
                    }
                    .frame(maxHeight: 100)
                }
                .padding()
                .background(Color.black.opacity(0.5))
                .cornerRadius(8)
            }
        }
        .padding()
        .background(
            LinearGradient(
                colors: [Color.black.opacity(0.8), Color.blue.opacity(0.6)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .onAppear {
            addTestResult("AudioTestView loaded")
        }
    }
    
    private func testJumpSound() {
        addTestResult("Testing jump sound...")
        audioManager.playJump()
        addTestResult("Jump sound test completed")
    }
    
    private func testBackgroundMusic() {
        addTestResult("Testing background music...")
        audioManager.playBackgroundMusic()
        addTestResult("Background music test completed")
    }
    
    private func runFullAudioTest() {
        addTestResult("=== Starting Full Audio Test ===")
        
        // Test 1: Check audio session
        let audioSession = AVAudioSession.sharedInstance()
        addTestResult("Audio Session Category: \(audioSession.category)")
        addTestResult("Audio Session Mode: \(audioSession.mode)")
        addTestResult("Audio Session Active: \(audioSession.isOtherAudioPlaying)")
        addTestResult("Device Volume: \(audioSession.outputVolume)")
        
        // Test 2: Check bundle
        addTestResult("Bundle Path: \(Bundle.main.bundlePath)")
        addTestResult("Bundle ID: \(Bundle.main.bundleIdentifier ?? "Unknown")")
        
        // Test 3: Check audio files
        let audioFiles = [
            ("pixel-jump-319167", "mp3"),
            ("Battle_Ready", "mp3")
        ]
        
        for (name, ext) in audioFiles {
            if let url = Bundle.main.url(forResource: name, withExtension: ext) {
                addTestResult("✅ Found \(name).\(ext)")
                
                do {
                    let attributes = try FileManager.default.attributesOfItem(atPath: url.path)
                    let fileSize = attributes[.size] as? Int64 ?? 0
                    addTestResult("   File size: \(fileSize) bytes")
                } catch {
                    addTestResult("   Error reading file: \(error)")
                }
            } else {
                addTestResult("❌ Missing \(name).\(ext)")
            }
        }
        
        // Test 4: Check audio players
        addTestResult("Jump Sound Player: \(audioManager.jumpSound != nil ? "✅ Ready" : "❌ Not Ready")")
        addTestResult("Background Music Player: \(audioManager.backgroundMusic != nil ? "✅ Ready" : "❌ Not Ready")")
        
        addTestResult("=== Full Audio Test Completed ===")
    }
    
    private func addTestResult(_ result: String) {
        let timestamp = DateFormatter.localizedString(from: Date(), dateStyle: .none, timeStyle: .medium)
        testResults.append("[\(timestamp)] \(result)")
        
        // Keep only last 20 results
        if testResults.count > 20 {
            testResults.removeFirst()
        }
    }
}

#Preview {
    AudioTestView()
}
