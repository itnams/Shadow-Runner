//
//  ContentView.swift
//  Shadow Runner
//
//  Created by Nam Nguyễn on 29/8/25.
//

import SwiftUI
import AVFoundation

// MARK: - Game Models
struct Obstacle: Identifiable {
    let id = UUID()
    var x: Double
    let y: Double
    let width: Double
    let height: Double
    var speed: Double
    
    mutating func update() {
        x -= speed
    }
}

struct GameState {
    var isGameActive = false
    var score = 0
    var gameOver = false
    var characterY: Double = 400
    var characterVelocity: Double = 0
    var obstacles: [Obstacle] = []
    var lastObstacleTime: Date = Date()
    var obstacleSpawnInterval: TimeInterval = 3.0
    var gameSpeed: Double = 8
    var gameStartTime: Date = Date()
    var maxObstaclesOnScreen: Int = 1
    var survivalTime: TimeInterval = 0
    var highScore: TimeInterval = 0
}

// MARK: - Game Constants
struct GameConstants {
    static let gravity: Double = 500
    static let jumpVelocity: Double = -350
    static let characterSize: Double = 45
    static let maxJumpHeight: Double = 250
    static let screenWidth: Double = 1200
    static let screenHeight: Double = 800
    static let obstacleWidth: Double = 50
    static let obstacleHeight: Double = 60
    
    // Dynamic ground position based on screen size
    static func getGroundY(for screenHeight: CGFloat) -> Double {
        // Calculate ground position as 85% of screen height
        // This ensures ground is visible on all screen sizes
        return Double(screenHeight * 0.85)
    }
    
    // Dynamic character starting position
    static func getCharacterStartY(for screenHeight: CGFloat) -> Double {
        return getGroundY(for: screenHeight) - characterSize/2
    }
    
    // Safe area padding for different screen sizes
    static func getSafeAreaPadding(for screenHeight: CGFloat) -> Double {
        if screenHeight <= 667 { // iPhone SE, 8, etc.
            return 20
        } else if screenHeight <= 844 { // iPhone 12, 13, etc.
            return 30
        } else { // iPhone 14 Pro Max, 15 Pro Max, etc.
            return 40
        }
    }
}

// MARK: - Audio Manager
class AudioManager: ObservableObject {
    var jumpSound: AVAudioPlayer?
    var backgroundMusic: AVAudioPlayer?
    
    @Published var isBackgroundMusicEnabled = true
    @Published var isJumpSoundEnabled = true
    
    init() {
        // Configure audio session first
        configureAudioSession()
        
        setupJumpSound()
        setupBackgroundMusic()
        loadAudioSettings()
        
        // Validate audio files
        validateAudioFiles()
    }
    
    private func setupJumpSound() {
        guard let url = Bundle.main.url(forResource: "pixel-jump-319167", withExtension: "mp3") else {
            print("❌ Could not find jump sound file")
            print("   Bundle path: \(Bundle.main.bundlePath)")
            return
        }
        
        do {
            jumpSound = try AVAudioPlayer(contentsOf: url)
            jumpSound?.volume = 1.0
            jumpSound?.prepareToPlay()
            print("✅ Jump sound setup successful")
            print("   Duration: \(jumpSound?.duration ?? 0) seconds")
            print("   Format: \(jumpSound?.format.description ?? "Unknown")")
        } catch {
            print("❌ Could not create jump sound player: \(error)")
            print("   Error domain: \(error._domain)")
            print("   Error code: \(error._code)")
        }
    }
    
    private func setupBackgroundMusic() {
        guard let url = Bundle.main.url(forResource: "Battle_Ready", withExtension: "mp3") else {
            print("❌ Could not find background music file")
            print("   Bundle path: \(Bundle.main.bundlePath)")
            return
        }
        
        do {
            backgroundMusic = try AVAudioPlayer(contentsOf: url)
            backgroundMusic?.numberOfLoops = -1 // Infinite loop
            backgroundMusic?.volume = 0.7 // Lower volume for background
            backgroundMusic?.prepareToPlay()
            
            print("✅ Background music setup successful")
            print("   Duration: \(backgroundMusic?.duration ?? 0) seconds")
            print("   Format: \(backgroundMusic?.format.description ?? "Unknown")")
            
        } catch {
            print("❌ Could not create background music player: \(error)")
            print("   Error domain: \(error._domain)")
            print("   Error code: \(error._code)")
        }
    }
    
    func playJump() {
        // Only play if jump sound is enabled
        guard isJumpSoundEnabled else { return }
        
        // Reset to beginning and play
        jumpSound?.currentTime = 0
        jumpSound?.play()
    }
    
    func stopJump() {
        jumpSound?.stop()
    }
    
    func playBackgroundMusic() {
        backgroundMusic?.play()
    }
    
    func stopBackgroundMusic() {
        backgroundMusic?.stop()
    }
    
    func pauseBackgroundMusic() {
        backgroundMusic?.pause()
    }
    
    func setBackgroundMusicVolume(_ volume: Float) {
        backgroundMusic?.volume = volume
    }
    
    func toggleBackgroundMusic() {
        isBackgroundMusicEnabled.toggle()
        if isBackgroundMusicEnabled {
            playBackgroundMusic()
        } else {
            stopBackgroundMusic()
        }
        saveAudioSettings()
    }
    
    func toggleJumpSound() {
        isJumpSoundEnabled.toggle()
        saveAudioSettings()
    }
    
    private func loadAudioSettings() {
        let defaults = UserDefaults.standard
        isBackgroundMusicEnabled = defaults.bool(forKey: "isBackgroundMusicEnabled")
        isJumpSoundEnabled = defaults.bool(forKey: "isJumpSoundEnabled")
    }
    
    private func saveAudioSettings() {
        let defaults = UserDefaults.standard
        defaults.set(isBackgroundMusicEnabled, forKey: "isBackgroundMusicEnabled")
        defaults.set(isJumpSoundEnabled, forKey: "isJumpSoundEnabled")
    }
    
    // MARK: - Debug & Validation Methods
    
    private func configureAudioSession() {
        do {
            let audioSession = AVAudioSession.sharedInstance()
            
            // Try different categories for better compatibility
            try audioSession.setCategory(.playback, mode: .default, options: [.mixWithOthers, .allowBluetooth])
            
            // Set preferred sample rate and buffer duration
            try audioSession.setPreferredSampleRate(44100.0)
            try audioSession.setPreferredIOBufferDuration(0.005)
            
            // Activate audio session
            try audioSession.setActive(true)
            
            print("✅ Audio session configured successfully")
            print("   Category: \(audioSession.category)")
            print("   Mode: \(audioSession.mode)")
            print("   Sample rate: \(audioSession.sampleRate)")
            
        } catch {
            print("❌ Failed to configure audio session: \(error)")
        }
    }
    
    private func validateAudioFiles() {
        print("🔍 Validating audio files...")
        print("Bundle path: \(Bundle.main.bundlePath)")
        
        let audioFiles = [
            ("pixel-jump-319167", "mp3"),
            ("Battle_Ready", "mp3")
        ]
        
        for (name, ext) in audioFiles {
            if let url = Bundle.main.url(forResource: name, withExtension: ext) {
                print("✅ Found \(name).\(ext)")
                
                // Check file size
                do {
                    let attributes = try FileManager.default.attributesOfItem(atPath: url.path)
                    let fileSize = attributes[.size] as? Int64 ?? 0
                    print("   File size: \(fileSize) bytes")
                } catch {
                    print("   Error reading file attributes: \(error)")
                }
            } else {
                print("❌ Missing \(name).\(ext)")
            }
        }
        
        // List all files in bundle
        if let resourcePath = Bundle.main.resourcePath {
            do {
                let files = try FileManager.default.contentsOfDirectory(atPath: resourcePath)
                let audioFiles = files.filter { $0.hasSuffix(".mp3") }
                print("📁 Audio files in bundle: \(audioFiles)")
            } catch {
                print("Error reading bundle: \(error)")
            }
        }
    }
    
    // Debug method to check audio status
    func debugAudioStatus() {
        print("🎵 === Audio Debug Info ===")
        print("Jump sound: \(jumpSound != nil ? "✅ Loaded" : "❌ Not loaded")")
        print("Background music: \(backgroundMusic != nil ? "✅ Loaded" : "❌ Not loaded")")
        print("Jump sound enabled: \(isJumpSoundEnabled ? "✅ Yes" : "❌ No")")
        print("Background music enabled: \(isBackgroundMusicEnabled ? "✅ Yes" : "❌ No")")
        
        // Check audio session
        let audioSession = AVAudioSession.sharedInstance()
        print("Audio session category: \(audioSession.category)")
        print("Audio session mode: \(audioSession.mode)")
        print("Audio session is active: \(audioSession.isOtherAudioPlaying)")
        print("Device volume: \(audioSession.outputVolume)")
        
        // Check bundle info
        print("Bundle identifier: \(Bundle.main.bundleIdentifier ?? "Unknown")")
        print("Bundle version: \(Bundle.main.infoDictionary?["CFBundleShortVersionString"] ?? "Unknown")")
    }
}

// MARK: - Game View
struct ContentView: View {
    @StateObject private var audioManager = AudioManager()
    @State private var gameState = GameState()
    @State private var lastUpdateTime: Date = Date()
    @State private var showControlsHint = false
    @State private var backgroundOffset: CGFloat = 0
    @State private var showSplash = true
    
    var body: some View {
        ZStack {
            // Background
            LinearGradient(
                gradient: Gradient(colors: [Color.white, Color.gray.opacity(0.1)]),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            // Safe area overlay for different screen sizes
            GeometryReader { geometry in
                Color.clear
                    .onAppear {
                        // Update game constants based on current screen size
                        let screenHeight = geometry.size.height
                        print("📱 Screen size detected: \(geometry.size.width) x \(screenHeight)")
                        print("🌍 Ground Y will be at: \(GameConstants.getGroundY(for: screenHeight))")
                        print("👤 Character start Y will be at: \(GameConstants.getCharacterStartY(for: screenHeight))")
                    }
            }
            
            // Splash View
            if showSplash {
                SplashView(showSplash: $showSplash)
                    .transition(.opacity.combined(with: .scale))
                    .animation(.easeInOut(duration: 0.5), value: showSplash)
                    .zIndex(1000)
            }
            
            // Game Canvas
            TimelineView(.animation) { timeline in
                Canvas { context, size in
                    drawGame(context: context, size: size)
                }
                .onChange(of: timeline.date) { _, newDate in
                    updateGame(currentTime: newDate)
                    
                    // Update background scrolling animation
                    if gameState.isGameActive {
                        backgroundOffset = CGFloat(newDate.timeIntervalSince1970 * 150) // Speed of background scroll
                    }
                }
            }
            
            // UI Overlay - Beautiful and modern design
            VStack {
                // Top Game Info Bar
                HStack {
                    // Survival Time Display
                    HStack(spacing: 8) {
                        Image(systemName: "clock.fill")
                            .font(.title2)
                            .foregroundColor(.white)
                            .shadow(color: .black.opacity(0.5), radius: 3, x: 0, y: 2)
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text("SURVIVAL")
                                .font(.caption)
                                .fontWeight(.bold)
                                .foregroundColor(.white.opacity(0.8))
                                .textCase(.uppercase)
                            
                            Text(formatTime(gameState.survivalTime))
                                .font(.system(size: 24, weight: .black, design: .monospaced))
                                .foregroundColor(.white)
                                .shadow(color: .black.opacity(0.7), radius: 4, x: 0, y: 2)
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 15)
                            .fill(
                                LinearGradient(
                                    colors: [
                                        Color.blue.opacity(0.9),
                                        Color.blue.opacity(0.7)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 15)
                                    .stroke(Color.white.opacity(0.3), lineWidth: 1)
                            )
                    )
                    .shadow(color: .black.opacity(0.3), radius: 8, x: 0, y: 4)
                    
                    Spacer()
                    
                    // Audio Control Buttons
                    HStack(spacing: 8) {
                        // Background Music Toggle
                        Button(action: {
                            audioManager.toggleBackgroundMusic()
                        }) {
                            Image(systemName: audioManager.isBackgroundMusicEnabled ? "speaker.wave.2.fill" : "speaker.slash.fill")
                                .font(.title3)
                                .foregroundColor(audioManager.isBackgroundMusicEnabled ? .blue : .gray)
                                .frame(width: 32, height: 32)
                                .background(
                                    Circle()
                                        .fill(Color.white.opacity(0.2))
                                        .overlay(
                                            Circle()
                                                .stroke(audioManager.isBackgroundMusicEnabled ? Color.blue.opacity(0.6) : Color.gray.opacity(0.6), lineWidth: 1)
                                        )
                                )
                        }
                        .scaleEffect(audioManager.isBackgroundMusicEnabled ? 1.0 : 0.8)
                        .animation(.easeInOut(duration: 0.2), value: audioManager.isBackgroundMusicEnabled)
                        
                        // Jump Sound Toggle
                        Button(action: {
                            audioManager.toggleJumpSound()
                        }) {
                            Image(systemName: audioManager.isJumpSoundEnabled ? "waveform" : "waveform.slash")
                                .font(.title3)
                                .foregroundColor(audioManager.isJumpSoundEnabled ? .green : .gray)
                                .frame(width: 32, height: 32)
                                .background(
                                    Circle()
                                        .fill(Color.white.opacity(0.2))
                                        .overlay(
                                            Circle()
                                                .stroke(audioManager.isJumpSoundEnabled ? Color.green.opacity(0.6) : Color.gray.opacity(0.6), lineWidth: 1)
                                        )
                                )
                        }
                        .scaleEffect(audioManager.isJumpSoundEnabled ? 1.0 : 0.8)
                        .animation(.easeInOut(duration: 0.2), value: audioManager.isJumpSoundEnabled)
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.black.opacity(0.3))
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(Color.white.opacity(0.2), lineWidth: 1)
                            )
                    )
                    .shadow(color: .black.opacity(0.2), radius: 4, x: 0, y: 2)
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
                
                Spacer()
                
                // Bottom Controls Hint (only show during gameplay for first 3 seconds)
                if gameState.isGameActive && showControlsHint {
                    VStack(spacing: 8) {
                        // Controls Hint
                        HStack(spacing: 12) {
                            // Jump Control
                            HStack(spacing: 6) {
                                Image(systemName: "arrow.up.circle.fill")
                                    .font(.title2)
                                    .foregroundColor(.white)
                                    .shadow(color: .black.opacity(0.5), radius: 3, x: 0, y: 2)
                                
                                Text("JUMP")
                                    .font(.caption)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white.opacity(0.9))
                                    .textCase(.uppercase)
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(Color.orange.opacity(0.3))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 10)
                                            .stroke(Color.orange.opacity(0.6), lineWidth: 1)
                                    )
                            )
                            
                            // Platform Hint
                            HStack(spacing: 6) {
                                Image(systemName: "gamecontroller.fill")
                                    .font(.title2)
                                    .foregroundColor(.white)
                                    .font(.title2)
                                    .foregroundColor(.white)
                                    .shadow(color: .black.opacity(0.5), radius: 3, x: 0, y: 2)
                                
                                Text("SPACE / TAP")
                                    .font(.caption)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white.opacity(0.9))
                                    .textCase(.uppercase)
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(Color.purple.opacity(0.3))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 10)
                                            .stroke(Color.purple.opacity(0.6), lineWidth: 1)
                                    )
                            )
                        }
                        
                        // Game Tip
                        Text("Avoid obstacles and survive as long as possible!")
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(.white.opacity(0.7))
                            .padding(.horizontal, 16)
                            .padding(.vertical, 6)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color.black.opacity(0.4))
                            )
                    }
                    .padding(.bottom, 20)
                    .transition(.opacity.combined(with: .move(edge: .bottom)))
                    .animation(.easeInOut(duration: 0.3), value: showControlsHint)
                    
                    // Visual Gameplay Enhancement
                    .overlay(
                        // Top-right corner decoration
                        VStack {
                            HStack {
                                Spacer()
                                
                               
                            }
                            
                            Spacer()
                        }
                    )
                }
                
                if !gameState.isGameActive && !gameState.gameOver {
                        // Start Game Card - Beautiful and modern design
                        VStack(spacing: 18) {
                            // Game Title and Icon
                            VStack(spacing: 10) {
                                Image(systemName: "gamecontroller.fill")
                                    .font(.system(size: 45))
                                    .foregroundColor(.blue)
                                    .shadow(color: .blue.opacity(0.6), radius: 10, x: 0, y: 5)
                                
                                Text("SHADOW RUNNER")
                                    .font(.system(size: 32, weight: .black, design: .rounded))
                                    .foregroundColor(.white)
                                    .shadow(color: .black.opacity(0.7), radius: 6, x: 0, y: 3)
                                    .multilineTextAlignment(.center)
                            }
                
                            // Game Description
                            VStack(spacing: 6) {
                                Text("Endless Runner Adventure")
                                    .font(.title3)
                                    .fontWeight(.medium)
                                    .foregroundColor(.gray.opacity(0.9))
                                
                                Text("Jump over obstacles and survive as long as possible!")
                                    .font(.caption)
                                    .foregroundColor(.white.opacity(0.8))
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal, 15)
                            }
                
                            // High Score Display (if exists)
                            if gameState.highScore > 0 {
                                VStack(spacing: 6) {
                                    Text("Best Time")
                                        .font(.body)
                                        .fontWeight(.medium)
                                        .foregroundColor(.yellow.opacity(0.9))
                                    
                                    Text(formatTime(gameState.highScore))
                                        .font(.system(size: 22, weight: .bold, design: .monospaced))
                                        .foregroundColor(.yellow)
                                        .padding(.horizontal, 20)
                                        .padding(.vertical, 8)
                                        .background(
                                            RoundedRectangle(cornerRadius: 12)
                                                .fill(Color.yellow.opacity(0.2))
                                                .overlay(
                                                    RoundedRectangle(cornerRadius: 12)
                                                        .stroke(Color.yellow.opacity(0.6), lineWidth: 2)
                                                )
                                        )
                                }
                            }
                            
                            // Start Game Button
                            Button(action: {
                                startGame()
                            }) {
                                HStack(spacing: 8) {
                                    Image(systemName: "play.fill")
                                        .font(.body)
                                    Text("START GAME")
                                        .font(.body)
                                        .fontWeight(.black)
                                }
                                .foregroundColor(.white)
                                .padding(.horizontal, 30)
                                .padding(.vertical, 12)
                                .background(
                                    RoundedRectangle(cornerRadius: 15)
                                        .fill(
                                            LinearGradient(
                                                colors: [Color.green, Color.green.opacity(0.8)],
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            )
                                        )
                                        .shadow(color: .green.opacity(0.6), radius: 8, x: 0, y: 4)
                                )
                            }
                            .scaleEffect(1.0)
                            .animation(.easeInOut(duration: 0.2), value: true)
                        }
                        .padding(.horizontal, 30)
                        .padding(.vertical, 30)
                        .background(
                            RoundedRectangle(cornerRadius: 30)
                                .fill(
                                    LinearGradient(
                                        colors: [
                                            Color.black.opacity(0.85),
                                            Color.black.opacity(0.75),
                                            Color.black.opacity(0.85)
                                        ],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: 30)
                                        .stroke(
                                            LinearGradient(
                                                colors: [Color.blue.opacity(0.8), Color.purple.opacity(0.6)],
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            ),
                                            lineWidth: 3
                                        )
                                )
                        )
                        .shadow(color: .black.opacity(0.8), radius: 25, x: 0, y: 15)
                    }
                }
                .padding()
                
                Spacer()
                
                if gameState.gameOver {
                    ZStack {
                        // Semi-transparent overlay
                        Color.black.opacity(0.7)
                            .ignoresSafeArea()
                        
                        // Center the Game Over Card perfectly
                        VStack {
                            Spacer()
                            
                                                        // Game Over Card - Centered and properly positioned
                            VStack(spacing: 15) {
                                // Game Over Icon/Title
                                VStack(spacing: 8) {
                                    Image(systemName: "gamecontroller.fill")
                                        .font(.system(size: 35))
                                        .foregroundColor(.red)
                                        .shadow(color: .red.opacity(0.5), radius: 6, x: 0, y: 3)
                                    
                                    Text("GAME OVER!")
                                        .font(.system(size: 28, weight: .black, design: .rounded))
                                        .foregroundColor(.white)
                                        .shadow(color: .black.opacity(0.5), radius: 3, x: 0, y: 1)
                                }
                                
                                // Score Display
                                VStack(spacing: 10) {
                                    // Current Score
                                    VStack(spacing: 6) {
                                        Text("Survival Time")
                                            .font(.body)
                                            .fontWeight(.medium)
                                            .foregroundColor(.gray.opacity(0.8))
                                        
                                        Text(formatTime(gameState.survivalTime))
                                            .font(.system(size: 22, weight: .bold, design: .monospaced))
                                            .foregroundColor(.white)
                                            .padding(.horizontal, 18)
                                            .padding(.vertical, 8)
                                            .background(
                                                RoundedRectangle(cornerRadius: 10)
                                                    .fill(Color.blue.opacity(0.3))
                                                    .overlay(
                                                        RoundedRectangle(cornerRadius: 10)
                                                            .stroke(Color.blue.opacity(0.6), lineWidth: 2)
                                                    )
                                            )
                                    }
                                    
                                    // High Score
                                    VStack(spacing: 6) {
                                        Text("High Score")
                                            .font(.caption)
                                            .fontWeight(.medium)
                                            .foregroundColor(.yellow.opacity(0.8))
                                        
                                        Text(formatTime(gameState.highScore))
                                            .font(.system(size: 18, weight: .bold, design: .monospaced))
                                            .foregroundColor(.yellow)
                                            .padding(.horizontal, 12)
                                            .padding(.vertical, 6)
                                            .background(
                                                RoundedRectangle(cornerRadius: 8)
                                                    .fill(Color.yellow.opacity(0.2))
                                                    .overlay(
                                                        RoundedRectangle(cornerRadius: 8)
                                                            .stroke(Color.yellow.opacity(0.6), lineWidth: 2)
                                                    )
                                            )
                                    }
                                }
                                
                                // Action Buttons
                                HStack(spacing: 12) {
                                    // Play Again Button
                                    Button(action: {
                                        startGame()
                                    }) {
                                        HStack(spacing: 5) {
                                            Image(systemName: "arrow.clockwise")
                                                .font(.caption)
                                            Text("Play Again")
                                                .font(.caption)
                                                .fontWeight(.bold)
                                        }
                                        .foregroundColor(.white)
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 8)
                                        .background(
                                            RoundedRectangle(cornerRadius: 10)
                                                .fill(Color.green)
                                                .shadow(color: .green.opacity(0.5), radius: 4, x: 0, y: 2)
                                        )
                                    }
                                    
                                    // Home Button
                                    Button(action: {
                                        // Reset to main menu
                                        gameState.gameOver = false
                                        gameState.isGameActive = false
                                        
                                        // Stop background music
                                        audioManager.stopBackgroundMusic()
                                    }) {
                                        HStack(spacing: 5) {
                                            Image(systemName: "house.fill")
                                                .font(.caption)
                                            Text("Home")
                                                .font(.caption)
                                                .fontWeight(.bold)
                                        }
                                        .foregroundColor(.white)
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 8)
                                        .background(
                                            RoundedRectangle(cornerRadius: 10)
                                                .fill(Color.orange)
                                                .shadow(color: .orange.opacity(0.5), radius: 4, x: 0, y: 2)
                                        )
                                    }
                                }
                            }
                            .padding(.horizontal, 25)
                            .padding(.vertical, 25)
                        .background(
                            RoundedRectangle(cornerRadius: 25)
                                .fill(
                                    LinearGradient(
                                        gradient: Gradient(colors: [
                                            Color.black.opacity(0.9),
                                            Color.gray.opacity(0.8),
                                            Color.black.opacity(0.9)
                                        ]),
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: 25)
                                        .stroke(
                                            LinearGradient(
                                                gradient: Gradient(colors: [
                                                    Color.blue.opacity(0.6),
                                                    Color.purple.opacity(0.6)
                                                ]),
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            ),
                                            lineWidth: 3
                                        )
                                )
                        )
                        .shadow(color: .black.opacity(0.8), radius: 20, x: 0, y: 10)
                    }
                    
                    Spacer()
                }
                .zIndex(1000) // Ensure it's on top
            }
        }
        .onTapGesture {
            if gameState.isGameActive {
                jump()
            }
        }
        .onKeyPress(.space) {
            if gameState.isGameActive {
                jump()
                return .handled
            }
            return .ignored
        }
    }
    
    // MARK: - Game Logic
    private func startGame() {
        gameState = GameState()
        gameState.isGameActive = true
        
        // Get screen size for dynamic positioning
        let screenHeight = UIScreen.main.bounds.height
        gameState.characterY = GameConstants.getCharacterStartY(for: screenHeight)
        
        gameState.obstacles.removeAll()
        gameState.gameStartTime = Date()
        gameState.highScore = loadHighScore()
        lastUpdateTime = Date()
        
        // Start background music if enabled
        if audioManager.isBackgroundMusicEnabled {
            audioManager.playBackgroundMusic()
        }
        
        // Show controls hint for first 3 seconds
        showControlsHint = true
        
        // Hide controls hint after 3 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            withAnimation(.easeOut(duration: 0.5)) {
                showControlsHint = false
            }
        }
    }
    
    private func jump() {
        guard gameState.isGameActive else { return }
        
        // Play jump sound
        audioManager.playJump()
        
        // Set jump velocity
        gameState.characterVelocity = GameConstants.jumpVelocity
    }
    
    private func updateGame(currentTime: Date) {
        guard gameState.isGameActive else { return }
        
        let deltaTime = currentTime.timeIntervalSince(lastUpdateTime)
        lastUpdateTime = currentTime
        
        // Update survival time (score)
        gameState.survivalTime = currentTime.timeIntervalSince(gameState.gameStartTime)
        gameState.score = Int(gameState.survivalTime)
        
        // Update character physics
        updateCharacter(deltaTime: deltaTime)
        
        // Update obstacles
        updateObstacles(deltaTime: deltaTime)
        
        // Spawn new obstacles
        spawnObstacles(currentTime: currentTime)
        
        // Check collisions
        checkCollisions()
    }
    
    private func updateCharacter(deltaTime: TimeInterval) {
        // Get current screen height for dynamic positioning
        let screenHeight = UIScreen.main.bounds.height
        let currentGroundY = GameConstants.getGroundY(for: screenHeight)
        
        // Apply gravity
        gameState.characterVelocity += GameConstants.gravity * deltaTime
        
        // Update position
        gameState.characterY += gameState.characterVelocity * deltaTime
        
        // Ground collision
        if gameState.characterY >= currentGroundY {
            gameState.characterY = currentGroundY
            gameState.characterVelocity = 0
        }
        
        // Maximum jump height limit (to avoid touching Score area)
        let maxY = currentGroundY - GameConstants.maxJumpHeight
        if gameState.characterY <= maxY {
            gameState.characterY = maxY
            gameState.characterVelocity = 0
        }
    }
    
    private func updateObstacles(deltaTime: TimeInterval) {
        for i in gameState.obstacles.indices {
            gameState.obstacles[i].update()
        }
        
        // Remove obstacles that are off screen
        gameState.obstacles.removeAll { obstacle in
            obstacle.x + obstacle.width < 0
        }
    }
    
    private func spawnObstacles(currentTime: Date) {
        if currentTime.timeIntervalSince(gameState.lastObstacleTime) >= gameState.obstacleSpawnInterval {
            // Calculate game duration for difficulty scaling
            let gameDuration = currentTime.timeIntervalSince(gameState.gameStartTime)
            
            // Increase difficulty based on survival time (every 15 seconds)
            if gameDuration > 15 { // After 15 seconds
                gameState.maxObstaclesOnScreen = 2
            }
            if gameDuration > 30 { // After 30 seconds
                gameState.maxObstaclesOnScreen = 3
            }
            if gameDuration > 45 { // After 45 seconds
                gameState.maxObstaclesOnScreen = 4
            }
            
            // Spawn obstacles based on current limit
            let obstaclesToSpawn = min(gameState.maxObstaclesOnScreen, 1 + Int(gameDuration / 15))
            
            for _ in 0..<obstaclesToSpawn {
                // Get current screen height for dynamic positioning
                let screenHeight = UIScreen.main.bounds.height
                let currentGroundY = GameConstants.getGroundY(for: screenHeight)
                
                // All obstacles appear near the character's current Y position to prevent cheating
                let characterY = gameState.characterY
                let minY = max(characterY - 80, currentGroundY - GameConstants.maxJumpHeight - GameConstants.obstacleWidth)
                let maxY = min(characterY + 80, currentGroundY - GameConstants.obstacleWidth)
                
                let obstacleY = Double.random(in: minY...maxY)
                
                // Random X offset for multiple obstacles (more spread out)
                let randomXOffset = Double.random(in: 0...150)
                
                let obstacle = Obstacle(
                    x: GameConstants.screenWidth + randomXOffset,
                    y: obstacleY,
                    width: GameConstants.obstacleWidth,
                    height: GameConstants.obstacleWidth, // Make it square
                    speed: gameState.gameSpeed
                )
                
                gameState.obstacles.append(obstacle)
            }
            
            gameState.lastObstacleTime = currentTime
            
            // Increase difficulty over time (faster progression)
            gameState.gameSpeed = min(40, gameState.gameSpeed + 1.0)
            gameState.obstacleSpawnInterval = max(1.5, gameState.obstacleSpawnInterval - 0.02)
        }
    }
    
    private func checkCollisions() {
        let characterRect = CGRect(
            x: 150 - GameConstants.characterSize/2,
            y: gameState.characterY - GameConstants.characterSize/2,
            width: GameConstants.characterSize,
            height: GameConstants.characterSize
        )
        
        for obstacle in gameState.obstacles {
            let obstacleRect = CGRect(
                x: obstacle.x,
                y: obstacle.y,
                width: obstacle.width,
                height: obstacle.height
            )
            
            if characterRect.intersects(obstacleRect) {
                gameOver()
                return
            }
        }
    }
    
    private func updateScore() {
        for obstacle in gameState.obstacles {
            // Check if obstacle has passed the character (regardless of Y position)
            if obstacle.x + obstacle.width < 100 - GameConstants.characterSize/2 && 
               obstacle.x + obstacle.width > 100 - GameConstants.characterSize/2 - 5 {
                gameState.score += 1
            }
        }
    }
    
    private func gameOver() {
        gameState.isGameActive = false
        gameState.gameOver = true
        
        // Stop background music
        audioManager.stopBackgroundMusic()
        
        checkAndUpdateHighScore()
    }
    
    private func formatTime(_ time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    private func loadHighScore() -> TimeInterval {
        return UserDefaults.standard.double(forKey: "ShadowRunnerHighScore")
    }
    
    private func saveHighScore(_ score: TimeInterval) {
        UserDefaults.standard.set(score, forKey: "ShadowRunnerHighScore")
    }
    
    private func checkAndUpdateHighScore() {
        let currentScore = gameState.survivalTime
        let currentHighScore = gameState.highScore
        
        if currentScore > currentHighScore {
            gameState.highScore = currentScore
            saveHighScore(currentScore)
        }
    }
    
    // MARK: - Drawing
    private func drawGame(context: GraphicsContext, size: CGSize) {
        // Draw beautiful dark gradient background with stars
        let backgroundGradient = Gradient(colors: [
            Color.black.opacity(0.4),
            Color.blue.opacity(0.7),
            Color.purple.opacity(0.6),
            Color.black.opacity(0.3)
        ])
        
        let backgroundRect = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        context.fill(Path(backgroundRect), with: .linearGradient(
            backgroundGradient,
            startPoint: CGPoint(x: 0, y: 0),
            endPoint: CGPoint(x: size.width, y: size.height)
        ))
        
        // Get dynamic ground position for sky drawing
        let skyGroundY = GameConstants.getGroundY(for: size.height)
        
        // Draw dark sky with stars effect
        let skyRect = CGRect(x: 0, y: 0, width: size.width, height: skyGroundY)
        context.fill(Path(skyRect), with: .linearGradient(
            Gradient(colors: [Color.black.opacity(0.3), Color.blue.opacity(0.8), Color.black.opacity(0.4)]),
            startPoint: CGPoint(x: 0, y: 0),
            endPoint: CGPoint(x: 0, y: skyGroundY)
        ))
        
        // Draw scrolling stars for night sky effect
        if gameState.isGameActive {
            let starCount = 25
            for i in 0..<starCount {
                let starX = CGFloat(i * 40) - backgroundOffset * 0.1 // Very slow scroll for stars
                let starY = CGFloat((i % 5) * 60 + 30)
                let starSize = CGFloat(1.0 + Double(i % 3) * 0.5)
                let starBrightness = Double(0.7 + Double((i % 4)) * 0.1)
                
                let starRect = CGRect(
                    x: starX,
                    y: starY,
                    width: starSize,
                    height: starSize
                )
                
                // Only draw stars that are visible on screen
                if starX + starSize > 0 && starX < size.width {
                    // Draw bright star
                    context.fill(Path(starRect), with: .color(.white.opacity(starBrightness)))
                    
                    // Add star twinkle effect
                    let twinkleSize = starSize * 1.5
                    let twinkleRect = CGRect(
                        x: starX - (twinkleSize - starSize) / 2,
                        y: starY - (twinkleSize - starSize) / 2,
                        width: twinkleSize,
                        height: twinkleSize
                    )
                    context.fill(Path(twinkleRect), with: .color(.white.opacity(starBrightness * 0.3)))
                }
            }
        }
        
        // Draw scrolling clouds for night sky effect
        if gameState.isGameActive {
            // Add distant mountains for depth
            let mountainCount = 4
            for i in 0..<mountainCount {
                let mountainX = CGFloat(i) * 300 - backgroundOffset * 0.05 // Very slow scroll for mountains
                let mountainY = skyGroundY - 100
                let mountainWidth = CGFloat(200 + (i % 2) * 50)
                let mountainHeight = CGFloat(80 + (i % 3) * 30)
                
                let mountainRect = CGRect(
                    x: mountainX,
                    y: mountainY,
                    width: mountainWidth,
                    height: mountainHeight
                )
                
                // Draw mountain with dark gradient
                let mountainGradient = Gradient(colors: [
                    Color.black.opacity(0.2),
                    Color.gray.opacity(0.8),
                    Color.black.opacity(0.3)
                ])
                
                context.fill(Path(mountainRect), with: .linearGradient(
                    mountainGradient,
                    startPoint: CGPoint(x: mountainX, y: mountainY),
                    endPoint: CGPoint(x: mountainX + mountainWidth, y: mountainY + mountainHeight)
                ))
            }
            
            // Add floating particles for atmosphere
            let particleCount = 15
            for i in 0..<particleCount {
                let particleX = CGFloat(i * 60) - backgroundOffset * 0.15
                let particleY = CGFloat(i % 4) * 40 + 80
                let particleSize = CGFloat(1 + (i % 2) * Int(0.5))
                
                let particleRect = CGRect(
                    x: particleX,
                    y: particleY,
                    width: particleSize,
                    height: particleSize
                )
                
                // Only draw particles that are visible
                if particleX + particleSize > 0 && particleX < size.width {
                    context.fill(Path(particleRect), with: .color(.white.opacity(0.2)))
                }
            }
            
            let cloudCount = 6
            for i in 0..<cloudCount {
                let cloudX = CGFloat(i) * 250 - backgroundOffset * 0.2 // Slower scroll for distant clouds
                let cloudY = CGFloat((i % 3) * 70 + 40)
                let cloudSize = CGFloat(50.0 + Double(i % 3) * 15.0)
                
                let cloudRect = CGRect(
                    x: cloudX,
                    y: cloudY,
                    width: cloudSize,
                    height: cloudSize * 0.5
                )
                
                // Draw dark cloud with subtle glow
                let cloudPath = Path { path in
                    path.addEllipse(in: cloudRect)
                }
                
                // Dark cloud base
                context.fill(cloudPath, with: .color(.gray.opacity(0.8)))
                
                // Cloud glow effect
                let glowRect = CGRect(
                    x: cloudX - 2,
                    y: cloudY - 2,
                    width: cloudSize + 4,
                    height: cloudSize * 0.5 + 4
                )
                let glowPath = Path { path in
                    path.addEllipse(in: glowRect)
                }
                context.fill(glowPath, with: .color(.blue.opacity(0.3)))
                
                // Additional cloud parts for depth
                let cloudPart1 = CGRect(
                    x: cloudX + cloudSize * 0.2,
                    y: cloudY + cloudSize * 0.1,
                    width: cloudSize * 0.7,
                    height: cloudSize * 0.4
                )
                let cloudPart2 = CGRect(
                    x: cloudX + cloudSize * 0.1,
                    y: cloudY + cloudSize * 0.15,
                    width: cloudSize * 0.5,
                    height: cloudSize * 0.3
                )
                
                context.fill(Path(cloudPart1), with: .color(.gray.opacity(0.7)))
                context.fill(Path(cloudPart2), with: .color(.gray.opacity(0.75)))
            }
        }
        
        // Get dynamic ground position based on screen size
        let currentGroundY = GameConstants.getGroundY(for: size.height)
        
        // Draw beautiful ground with texture
        let groundRect = CGRect(
            x: 0,
            y: currentGroundY + GameConstants.characterSize/2,
            width: size.width,
            height: size.height - currentGroundY - GameConstants.characterSize/2
        )
        
        // Ground base with gradient
        context.fill(Path(groundRect), with: .linearGradient(
            Gradient(colors: [
                Color.green.opacity(0.9),
                Color.green.opacity(0.8),
                Color.brown.opacity(0.6)
            ]),
            startPoint: CGPoint(x: 0, y: currentGroundY),
            endPoint: CGPoint(x: 0, y: size.height)
        ))
        
        // Draw ground texture lines with scrolling effect
        if gameState.isGameActive {
            let lineCount = Int(size.width / 20) + 10 // Extra lines for smooth scrolling
            for i in 0..<lineCount {
                let lineX = CGFloat(i) * 20 - backgroundOffset * 0.6 // Faster scroll for ground
                let lineY = currentGroundY + GameConstants.characterSize/2 + 5
                let lineRect = CGRect(
                    x: lineX,
                    y: lineY,
                    width: 15,
                    height: 2
                )
                
                // Only draw lines that are visible on screen
                if lineX + 15 > 0 && lineX < size.width {
                    context.fill(Path(lineRect), with: .color(.green.opacity(0.9)))
                }
            }
        } else {
            // Static ground texture when not playing
            for i in stride(from: 0, to: size.width, by: 20) {
                let lineY = currentGroundY + GameConstants.characterSize/2 + 5
                let lineRect = CGRect(
                    x: i,
                    y: lineY,
                    width: 15,
                    height: 2
                )
                context.fill(Path(lineRect), with: .color(.green.opacity(0.9)))
            }
        }
        
        // Draw character (shadow) using image from Assets
        let characterRect = CGRect(
            x: 150 - GameConstants.characterSize/2,
            y: gameState.characterY - GameConstants.characterSize/2,
            width: GameConstants.characterSize,
            height: GameConstants.characterSize
        )
        
        // Draw the shadow image from Assets
        let shadowImage = Image("Shadow")
        context.draw(shadowImage, in: characterRect)
        
        // Draw obstacles using image from Assets
        for obstacle in gameState.obstacles {
            let obstacleRect = CGRect(
                x: obstacle.x,
                y: obstacle.y,
                width: obstacle.width,
                height: obstacle.height
            )
            
            // Draw the obstacle image from Assets
            let obstacleImage = Image("Obstacle")
            context.draw(obstacleImage, in: obstacleRect)
        }
    }
}


// MARK: - Splash View
struct SplashView: View {
    @Binding var showSplash: Bool
    @State private var logoScale: CGFloat = 0.5
    @State private var logoOpacity: Double = 0.0
    @State private var textOpacity: Double = 0.0
    
    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                colors: [
                    Color.black.opacity(0.9),
                    Color.blue.opacity(0.7),
                    Color.purple.opacity(0.6),
                    Color.black.opacity(0.8)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 40) {
                // App Icon
                Image("AppIcon")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 120, height: 120)
                    .scaleEffect(logoScale)
                    .opacity(logoOpacity)
                    .shadow(color: .blue.opacity(0.8), radius: 20, x: 0, y: 10)
                
                // Game Title
                VStack(spacing: 15) {
                    Text("SHADOW RUNNER")
                        .font(.system(size: 48, weight: .black, design: .rounded))
                        .foregroundColor(.white)
                        .shadow(color: .black.opacity(0.8), radius: 8, x: 0, y: 4)
                        .opacity(textOpacity)
                    
                    Text("Endless Runner Adventure")
                        .font(.title2)
                        .fontWeight(.medium)
                        .foregroundColor(.gray.opacity(0.9))
                        .opacity(textOpacity)
                }
                
                // Loading indicator
                HStack(spacing: 8) {
                    ForEach(0..<3) { i in
                        Circle()
                            .fill(Color.blue)
                            .frame(width: 8, height: 8)
                            .scaleEffect(textOpacity > 0 ? 1.0 : 0.5)
                            .animation(
                                .easeInOut(duration: 0.6)
                                .repeatForever()
                                .delay(Double(i) * 0.2),
                                value: textOpacity
                            )
                    }
                }
                .opacity(textOpacity)
            }
            .padding(.horizontal, 40)
        }
        .onAppear {
            // Animate logo appearance
            withAnimation(.easeOut(duration: 1.0)) {
                logoScale = 1.0
                logoOpacity = 1.0
            }
            
            // Animate text appearance
            withAnimation(.easeIn(duration: 0.8).delay(0.5)) {
                textOpacity = 1.0
            }
            
            // Auto-hide splash after 3 seconds
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                withAnimation(.easeInOut(duration: 0.8)) {
                    showSplash = false
                }
            }
        }
    }
}
#Preview {
    ContentView()
}

