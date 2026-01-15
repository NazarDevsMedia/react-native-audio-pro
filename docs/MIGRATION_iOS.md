# iOS AudioPro.swift Migration to Turbo Modules

## Overview
The `ios/AudioPro.swift` file needs to be updated to support the new React Native architecture while maintaining backward compatibility with the old architecture.

## Key Changes Required

### 1. Import Statement Changes
**Add:**
```swift
// For new architecture TurboModule support
#if RCT_NEW_ARCH_ENABLED
import AudioProSpecLight
#endif
```

### 2. Class Declaration Update
**Old:**
```swift
@objc(AudioPro)
class AudioPro: RCTEventEmitter {
```

**New:**
```swift
#if RCT_NEW_ARCH_ENABLED
class AudioPro: NSObject, AudioProSpec {
    @synthesize bridge = _bridge
    @synthesize turboModuleRegistry = _turboModuleRegistry
#else
@objc(AudioPro)
class AudioPro: RCTEventEmitter {
#endif
```

### 3. Event Emitter Property (for new arch)
**Add in class:**
```swift
#if RCT_NEW_ARCH_ENABLED
// Event emitter for new architecture
private var eventEmitter: RCTEventEmitter?

override init() {
    super.init()
    // Initialize event emitter if available
    self.eventEmitter = RCTEventEmitterModule(bridge: nil)
}

// Send event methods that work with both old and new architecture
private func sendEventToJS(name: String, body: [String: Any]) {
    #if RCT_NEW_ARCH_ENABLED
    self.eventEmitter?.sendEvent(withName: name, body: body)
    #else
    if hasListeners {
        self.sendEvent(withName: name, body: body)
    }
    #endif
}
#else
// Original RCTEventEmitter implementation for old architecture
#endif
```

### 4. Method Exports
All public methods need `@objc` attribute only for old architecture:

**Old Pattern (old arch only):**
```swift
@objc(play:withOptions:)
func play(track: NSDictionary, options: NSDictionary) {
    // implementation
}
```

**New Pattern (both arch):**
```swift
#if RCT_NEW_ARCH_ENABLED
func play(track: NSDictionary, options: NSDictionary) {
    // implementation
}
#else
@objc(play:withOptions:)
func play(track: NSDictionary, options: NSDictionary) {
    // implementation
}
#endif
```

### 5. Module Name Getter
**Update:**
```swift
#if RCT_NEW_ARCH_ENABLED
override static func moduleName() -> String! {
    return "AudioPro"
}

override static func requiresMainQueueSetup() -> Bool {
    return false
}
#else
override static func requiresMainQueueSetup() -> Bool {
    return false
}
#endif
```

### 6. Event Sending Helper
**Replace all `sendEvent` calls:**
```swift
// Instead of direct sendEvent, use this helper
private func emitEvent(_ eventName: String, body: [String: Any]) {
    #if RCT_NEW_ARCH_ENABLED
    self.eventEmitter?.sendEvent(withName: eventName, body: body)
    #else
    if hasListeners {
        self.sendEvent(withName: eventName, body: body)
    }
    #endif
}
```

## Implementation Strategy

1. Add conditional compilation flags throughout the file
2. Create helper methods for event emission that work with both architectures
3. Update method signatures to work with both old and new architecture
4. Test thoroughly on both architectures

## Conditional Compilation Summary

```swift
#if RCT_NEW_ARCH_ENABLED
    // New architecture code
#else
    // Old architecture code (existing code)
#endif
```

## Testing Approach

1. Build with `RCT_NEW_ARCH_ENABLED=1` for new architecture
2. Build without flag for backward compatibility
3. Test event emission on both platforms
4. Verify all methods work correctly

## References
- [RN Turbo Modules Documentation](https://reactnative.dev/docs/the-new-architecture/turbo-modules-intro)
- [Conditional Compilation with RCT_NEW_ARCH_ENABLED](https://reactnative.dev/docs/the-new-architecture/backward-compatibility-turbomodules)
