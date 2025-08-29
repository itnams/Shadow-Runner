# 🎵 TestFlight Audio Troubleshooting Guide - Shadow Runner

## 🚨 **Vấn đề: Âm thanh không hoạt động trên TestFlight**

### **🔍 Nguyên nhân có thể:**

#### **1. Audio Session Configuration Issues**
- Audio session chưa được configure đúng cách cho real device
- Category và mode không phù hợp với iOS background behavior
- Audio session bị deactivate bởi system

#### **2. File Bundle Issues**
- Audio files không được include trong app bundle
- File permissions bị restrict
- Bundle path không đúng trên real device

#### **3. iOS System Restrictions**
- Silent mode được bật
- Do Not Disturb mode
- System volume bị tắt
- Background app refresh bị disable

#### **4. Build Configuration Issues**
- Audio files không được copy vào app bundle
- Missing frameworks
- Code signing issues

---

## ✅ **Giải pháp đã áp dụng:**

### **1. Enhanced Audio Session Configuration**
```swift
private func setupBackgroundMusic() {
    guard let url = Bundle.main.url(forResource: "Battle_Ready", withExtension: "mp3") else {
        print("Could not find background music file")
        return
    }
    
    do {
        backgroundMusic = try AVAudioPlayer(contentsOf: url)
        backgroundMusic?.numberOfLoops = -1
        backgroundMusic?.volume = 0.7
        
        // Configure audio session for better performance
        try AVAudioSession.sharedInstance().setCategory(.ambient, mode: .default)
        try AVAudioSession.sharedInstance().setActive(true)
        
    } catch {
        print("Could not create background music player: \(error)")
    }
}
```

### **2. Smart Audio Control**
```swift
func toggleBackgroundMusic() {
    isBackgroundMusicEnabled.toggle()
    if isBackgroundMusicEnabled {
        playBackgroundMusic()
    } else {
        stopBackgroundMusic()
    }
    saveAudioSettings()
}

func playJump() {
    // Only play if jump sound is enabled
    guard isJumpSoundEnabled else { return }
    
    // Reset to beginning and play
    jumpSound?.currentTime = 0
    jumpSound?.play()
}
```

---

## 🛠️ **Cách khắc phục TestFlight Audio Issues:**

### **Bước 1: Kiểm tra Console Logs**
1. **Kết nối device** với Xcode
2. **Chạy app từ TestFlight**
3. **Xem console logs** trong Xcode
4. **Tìm các message**:
   - "Could not find background music file"
   - "Could not create background music player"
   - "Could not create audio player"

### **Bước 2: Kiểm tra Audio Files trong Project**
1. **Mở Xcode project**
2. **Chọn target "Shadow Runner"**
3. **Tab "Build Phases"**
4. **Kiểm tra "Copy Bundle Resources"**
5. **Đảm bảo có**:
   - `pixel-jump-319167.mp3`
   - `Battle_Ready.mp3`

### **Bước 3: Kiểm tra File Paths**
```swift
// Debug file paths
print("Bundle path: \(Bundle.main.bundlePath)")
print("Audio files in bundle:")
if let resourcePath = Bundle.main.resourcePath {
    do {
        let files = try FileManager.default.contentsOfDirectory(atPath: resourcePath)
        for file in files {
            if file.hasSuffix(".mp3") {
                print("Found audio file: \(file)")
            }
        }
    } catch {
        print("Error reading bundle: \(error)")
    }
}
```

### **Bước 4: Test Audio trên Device**
1. **Sử dụng AudioTestView** để test riêng lẻ
2. **Kiểm tra từng audio component**
3. **Xem debug info**

---

## 🔧 **Các bước tiếp theo nếu vẫn không hoạt động:**

### **1. Enhanced Audio Session Setup**
```swift
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
        
        print("Audio session configured successfully")
        print("Category: \(audioSession.category)")
        print("Mode: \(audioSession.mode)")
        print("Sample rate: \(audioSession.sampleRate)")
        
    } catch {
        print("Failed to configure audio session: \(error)")
    }
}
```

### **2. Audio File Validation**
```swift
private func validateAudioFiles() {
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
}
```

### **3. Enhanced Error Handling**
```swift
private func setupJumpSound() {
    guard let url = Bundle.main.url(forResource: "pixel-jump-319167", withExtension: "mp3") else {
        print("❌ Could not find jump sound file")
        print("Bundle path: \(Bundle.main.bundlePath)")
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
```

---

## 📱 **Device-specific Troubleshooting:**

### **iOS Device:**
1. **Tắt Silent Mode**: Kiểm tra switch bên cạnh device
2. **Tăng Volume**: Tăng volume lên maximum
3. **Kiểm tra Do Not Disturb**: Tắt trong Settings
4. **Background App Refresh**: Bật trong Settings
5. **Restart Device**: Restart hoàn toàn

### **TestFlight Specific:**
1. **Reinstall App**: Xóa và cài lại từ TestFlight
2. **Check Build**: Đảm bảo dùng build mới nhất
3. **Device Compatibility**: Kiểm tra iOS version support

---

## 🎯 **Debug Commands:**

### **Trong Xcode Console:**
```swift
// Check audio session
po AVAudioSession.sharedInstance().category
po AVAudioSession.sharedInstance().mode
po AVAudioSession.sharedInstance().isOtherAudioPlaying

// Check audio players
po audioManager.jumpSound != nil
po audioManager.backgroundMusic != nil

// Check bundle
po Bundle.main.bundlePath
po Bundle.main.resourcePath
```

### **Trong Code:**
```swift
.onAppear {
    // Debug audio on app launch
    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
        audioManager.validateAudioFiles()
        audioManager.configureAudioSession()
    }
}
```

---

## 📞 **Nếu vẫn không hoạt động:**

### **1. Check Apple Developer Forums**
- Tìm solutions tương tự
- Check iOS version compatibility
- Audio session best practices

### **2. Test trên Simulator**
- So sánh với real device
- Check audio output routing
- Verify file loading

### **3. Contact Apple Support**
- Report TestFlight audio issues
- Check app review guidelines
- Audio framework support

---

## 🎵 **Expected TestFlight Behavior:**

✅ **Audio Session**: Configured successfully  
✅ **Jump Sound**: Loaded and ready  
✅ **Background Music**: Loaded and ready  
✅ **Volume Control**: Working  
✅ **Toggle Functions**: Working  
✅ **Settings Persistence**: Working  
✅ **File Loading**: All audio files found  
✅ **Device Compatibility**: iOS 12.0+  

---

## 🚀 **Next Steps:**

1. **Implement enhanced audio session** configuration
2. **Add audio file validation** methods
3. **Test trên real device** với Xcode
4. **Deploy new build** lên TestFlight
5. **Monitor console logs** cho errors
6. **Verify audio functionality** trên TestFlight

---

*Last updated: Shadow Runner v1.0 - TestFlight Audio Fix*
