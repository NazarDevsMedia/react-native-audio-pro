# New Architecture Setup Guide

## Prerequisites

- React Native 0.71.0 or higher
- Xcode 14+ (iOS)
- Android NDK 23+ (Android)
- Node.js 16+ and Yarn 3.6.1+

## Installation

### 1. Install Dependencies

The required dependencies have been added to `package.json`:

```bash
yarn install
```

Key additions:
- `react-native-codegen` - Generates native bridging code from TypeScript specs

### 2. CodeGen Configuration

The `codegenConfig` in `package.json` tells CodeGen where to find specs:

```json
"codegenConfig": {
  "libraries": [
    {
      "name": "AudioPro",
      "type": "all",
      "jsSrcsDir": "src/specs"
    }
  ]
}
```

### 3. Native Module Spec

The TypeScript spec file `src/specs/NativeAudioPro.ts` defines the module interface.
CodeGen uses this to automatically generate:
- **iOS**: `ios/AudioProSpecLight.swift`
- **Android**: `android/.../AudioProSpec.kt`

## Building with New Architecture

### iOS (macOS only)

#### Enable New Architecture

```bash
cd example/ios
RCT_NEW_ARCH_ENABLED=1 pod install
```

#### Build Example App

```bash
yarn example ios
```

Or from Xcode:
```bash
open example/ios/AudioProExample.xcworkspace
# Select "AudioProExample" scheme
# Set "Build Settings" > "User-Defined" > "RCT_NEW_ARCH_ENABLED" = YES
# Build
```

### Android

#### Enable New Architecture via Gradle

Set environment variable before building:
```bash
export newArchEnabled=true
yarn example android
```

Or in `example/android/gradle.properties`:
```properties
newArchEnabled=true
```

Then build:
```bash
yarn example android
```

## Verification Checklist

After building, verify the new architecture is enabled:

### iOS
1. Check that `ios/AudioProSpecLight.swift` exists (CodeGen-generated)
2. Build logs should show "Using RCT_NEW_ARCH_ENABLED=1"
3. No compilation errors related to bridging

### Android
1. Check that `android/build/generated/source/codegen` contains `AudioProSpec.kt`
2. Build logs should show CodeGen task execution
3. Successfully links against `react-native` with new arch enabled

## Transitioning Example App

The example app demonstrates audio playback:

```bash
# Build library
yarn prepare

# Install and run example
yarn example start

# In another terminal
yarn example ios
# or
yarn example android
```

## TypeScript Generation

When making changes to `src/specs/NativeAudioPro.ts`:

1. CodeGen automatically generates native code when:
   - Running `pod install` (iOS)
   - Running `gradle build` (Android)
   - Running `yarn prepare` (triggers both)

2. Changes take effect on next build

## Troubleshooting

### "AudioProSpecLight.swift not found"
- Ensure `RCT_NEW_ARCH_ENABLED=1` is set before `pod install`
- Check `ios/Pods/Headers` for generated headers
- Try cleaning: `rm -rf ios/Pods ios/Podfile.lock && RCT_NEW_ARCH_ENABLED=1 pod install`

### "AudioProSpec not generated" (Android)
- Ensure `newArchEnabled=true` is set
- Run: `./gradlew clean :AudioPro:generateCodegenArtifactsFromSchema`
- Check `android/build/generated/source/codegen`

### Bridge not loading
- Verify TurboModuleRegistry.getEnforcing in emitter.ts succeeds
- Check native module name matches "AudioPro"
- Ensure event emitter is properly initialized

## Backward Compatibility

The library supports both old and new architecture:

### Using Old Architecture (Default)
```bash
# No special flags, uses legacy bridge
yarn example ios
yarn example android
```

### Using New Architecture (Opt-in)
```bash
# iOS
RCT_NEW_ARCH_ENABLED=1 pod install && yarn example ios

# Android
newArchEnabled=true yarn example android
```

Both build systems produce working binaries with the same JavaScript API.

## Next Steps

1. **Update Native Code**: Follow [MIGRATION_iOS.md](./MIGRATION_iOS.md) and [MIGRATION_Android.md](./MIGRATION_Android.md)
2. **Test Thoroughly**: Run on simulators and real devices
3. **Update Documentation**: Add platform-specific notes
4. **Release**: Bump version and publish

## References

- [React Native New Architecture Overview](https://reactnative.dev/docs/the-new-architecture)
- [Turbo Modules](https://reactnative.dev/docs/the-new-architecture/turbo-modules-intro)
- [CodeGen Configuration](https://reactnative.dev/docs/the-new-architecture/codegen)
- [Backward Compatibility Guide](https://reactnative.dev/docs/the-new-architecture/backward-compatibility-turbomodules)
