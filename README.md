# 🎮 Shadow Runner - Endless Runner Game

A modern, responsive endless runner game built with SwiftUI, featuring smooth animations, dynamic difficulty, and cross-platform support for iOS and macOS.

## 📱 Game Overview

**Shadow Runner** is an endless runner game where players control a shadow character, jumping over obstacles to survive as long as possible. The game features progressive difficulty, beautiful parallax backgrounds, and customizable audio controls.

### 🎯 Game Features
- **Endless Runner Gameplay**: Run, jump, and survive as long as possible
- **Dynamic Difficulty**: Game speed increases over time for progressive challenge
- **Responsive Design**: Optimized for all iPhone screen sizes (SE to Pro Max)
- **Customizable Audio**: Toggle background music and sound effects
- **High Score System**: Track and beat your personal best survival times
- **Beautiful Visuals**: Parallax scrolling backgrounds with stars, clouds, and mountains
- **Smooth Performance**: 60fps gameplay with optimized rendering

## 🚀 Getting Started

### Prerequisites
- **Xcode 15.0+** (for iOS 17.0+ and macOS 14.0+)
- **iOS 17.0+** or **macOS 14.0+**
- **Swift 5.9+**

### Installation
1. Clone the repository:
```bash
git clone https://github.com/yourusername/Shadow-Runner.git
cd Shadow-Runner
```

2. Open the project in Xcode:
```bash
open "Shadow Runner.xcodeproj"
```

3. Select your target device (iOS device or macOS)
4. Build and run the project (⌘+R)

## 🏗️ Project Structure

```
Shadow Runner/
├── Assets.xcassets/           # Game assets and images
│   ├── AppIcon.appiconset/    # App icon
│   ├── Shadow.imageset/       # Character sprite
│   ├── Obstacle.imageset/     # Obstacle sprite
│   └── AccentColor.colorset/  # App accent color
├── ContentView.swift          # Main game view and logic
├── Shadow_RunnerApp.swift     # App entry point
├── Shadow_Runner.entitlements # App entitlements
├── AudioTestView.swift        # Audio debugging tool
└── README.md                  # This file
```

## 🎮 Game Architecture

### Core Components

#### 1. Game State Management
```swift
struct GameState {
    var isGameActive: Bool = false
    var gameOver: Bool = false
    var characterY: Double = 0
    var characterVelocity: Double = 0
    var obstacles: [Obstacle] = []
    var survivalTime: TimeInterval = 0
    var highScore: TimeInterval = 0
    var gameSpeed: Double = 150
    var obstacleSpawnInterval: TimeInterval = 2.0
}
```

#### 2. Audio Management
```swift
class AudioManager: ObservableObject {
    var jumpSound: AVAudioPlayer?
    var backgroundMusic: AVAudioPlayer?
    @Published var isBackgroundMusicEnabled = true
    @Published var isJumpSoundEnabled = true
}
```

#### 3. Responsive Design
```swift
struct GameConstants {
    static func getGroundY(for screenHeight: CGFloat) -> Double {
        return Double(screenHeight * 0.85)
    }
    
    static func getCharacterStartY(for screenHeight: CGFloat) -> Double {
        return getGroundY(for: screenHeight) - characterSize/2
    }
}
```

### Game Loop
1. **TimelineView(.animation)**: Provides continuous 60fps updates
2. **Canvas Rendering**: Custom 2D drawing for game elements
3. **Physics Updates**: Gravity, collision detection, obstacle movement
4. **UI Updates**: Score display, game state changes

## 🎨 Visual Design

### Background System
- **Parallax Scrolling**: Multiple layers moving at different speeds
- **Dynamic Elements**: Stars, clouds, mountains, particles
- **Responsive Layout**: Adapts to all screen sizes and orientations

### Character Design
- **Shadow Character**: Simple, recognizable design
- **Smooth Animations**: Fluid movement and physics
- **Collision Detection**: Precise hitbox calculations

### UI Components
- **Modern Cards**: Beautiful start game and game over screens
- **Audio Controls**: Toggle buttons for music and sound effects
- **Score Display**: Real-time survival time tracking
- **Responsive Layout**: Works on all iPhone screen sizes

## 🎵 Audio System

### Sound Effects
- **Jump Sound**: `pixel-jump-319167.mp3`
- **Background Music**: `Battle_Ready.mp3` (looping)

### Audio Features
- **Volume Control**: Adjustable background music volume
- **Toggle Controls**: Enable/disable music and sound effects
- **Settings Persistence**: Audio preferences saved between sessions
- **Cross-Platform**: Works on both iOS and macOS

## 📱 Device Compatibility

### iPhone Models
- **iPhone SE (1st & 2nd gen)**: 667px height
- **iPhone 8, 8 Plus**: 667px, 736px height
- **iPhone X, XS, XR**: 812px, 896px height
- **iPhone 11, 11 Pro, 11 Pro Max**: 896px height
- **iPhone 12, 12 mini, 12 Pro, 12 Pro Max**: 844px, 926px height
- **iPhone 13, 13 mini, 13 Pro, 13 Pro Max**: 844px, 926px height
- **iPhone 14, 14 Plus, 14 Pro, 14 Pro Max**: 844px, 932px height
- **iPhone 15, 15 Plus, 15 Pro, 15 Pro Max**: 844px, 932px height

### Responsive Features
- **Dynamic Ground Positioning**: Automatically adjusts to screen height
- **Safe Area Support**: Respects notch and Dynamic Island
- **Orientation Support**: Optimized for landscape gameplay
- **Adaptive UI**: Elements scale appropriately for all screen sizes

## 🛠️ Development

### Building the Project
```bash
# Build for iOS
xcodebuild -project "Shadow Runner.xcodeproj" -scheme "Shadow Runner" -destination "platform=iOS Simulator,name=iPhone 15 Pro" build

# Build for macOS
xcodebuild -project "Shadow Runner.xcodeproj" -scheme "Shadow Runner" -destination "platform=macOS" build
```

### Testing
- **Simulator Testing**: Test on various iPhone screen sizes
- **Device Testing**: Test on real iOS devices
- **Audio Testing**: Use AudioTestView for debugging audio issues
- **Performance Testing**: Monitor frame rate and memory usage

### Debugging
- **Console Logs**: Detailed audio and game state logging
- **AudioTestView**: Dedicated audio testing interface
- **Performance Metrics**: Frame rate and rendering statistics

## 🚀 Deployment

### App Store Preparation
1. **App Icon**: Ensure all required sizes are included
2. **Screenshots**: Capture gameplay on different device sizes
3. **Metadata**: Prepare description, keywords, and promotional text
4. **Testing**: Test on TestFlight before release

### Build Configuration
- **Code Signing**: Configure with your Apple Developer account
- **Bundle Identifier**: Set unique app identifier
- **Version Management**: Increment build and version numbers
- **Archive**: Create production-ready build

## 📊 Performance

### Optimization Features
- **60fps Gameplay**: Smooth, responsive animations
- **Efficient Rendering**: Canvas-based 2D graphics
- **Memory Management**: Optimized asset loading and cleanup
- **Battery Efficiency**: Minimal background processing

### Performance Metrics
- **Frame Rate**: Consistent 60fps on supported devices
- **Memory Usage**: Efficient memory allocation and deallocation
- **Battery Impact**: Minimal battery drain during gameplay
- **Load Times**: Fast app startup and level loading

## 🐛 Troubleshooting

### Common Issues

#### Audio Not Working
1. Check audio files are included in bundle
2. Verify audio session configuration
3. Test with AudioTestView
4. Check device volume and silent mode

#### Visual Glitches
1. Verify device compatibility
2. Check screen size detection
3. Test on different orientations
4. Monitor console for errors

#### Performance Issues
1. Check device specifications
2. Monitor frame rate
3. Verify memory usage
4. Test on different iOS versions

### Debug Tools
- **AudioTestView**: Comprehensive audio testing
- **Console Logging**: Detailed game state information
- **Performance Monitoring**: Frame rate and memory tracking

## 📚 API Reference

### Key Classes and Structs

#### GameState
```swift
struct GameState {
    var isGameActive: Bool
    var gameOver: Bool
    var characterY: Double
    var characterVelocity: Double
    var obstacles: [Obstacle]
    var survivalTime: TimeInterval
    var highScore: TimeInterval
}
```

#### AudioManager
```swift
class AudioManager: ObservableObject {
    func playJump()
    func playBackgroundMusic()
    func stopBackgroundMusic()
    func toggleBackgroundMusic()
    func toggleJumpSound()
}
```

#### GameConstants
```swift
struct GameConstants {
    static func getGroundY(for screenHeight: CGFloat) -> Double
    static func getCharacterStartY(for screenHeight: CGFloat) -> Double
    static func getSafeAreaPadding(for screenHeight: CGFloat) -> Double
}
```

## 🤝 Contributing

### Development Guidelines
1. **Code Style**: Follow Swift style guidelines
2. **Documentation**: Comment complex logic and functions
3. **Testing**: Test on multiple device sizes
4. **Performance**: Monitor frame rate and memory usage

### Feature Requests
- Submit issues for bugs or feature requests
- Include device information and steps to reproduce
- Provide screenshots or videos when possible

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- **Audio Assets**: Jump sound and background music
- **SwiftUI**: Apple's modern UI framework
- **Canvas API**: Custom 2D rendering capabilities
- **AVFoundation**: Audio playback and management

## 📞 Support

For support and questions:
- **GitHub Issues**: Report bugs and request features
- **Documentation**: Check this README and code comments
- **Community**: Join SwiftUI development communities

---

**Shadow Runner** - Where every jump matters and survival is everything! 🎮✨

*Built with ❤️ using SwiftUI and Canvas*
# Shadow-Runner
