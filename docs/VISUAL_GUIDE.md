# New Architecture Visual Guide

## Architecture Overview Diagram

### Before: Legacy Architecture
```
┌─────────────────────────────────────────────────────────┐
│                    React Native App                      │
│                  (JavaScript/React)                      │
│                                                           │
│  useAudioPro hook → AudioPro.play()                      │
└──────────────────────┬──────────────────────────────────┘
                       │
                       ▼
        ┌──────────────────────────┐
        │   RCT Bridge (Async)     │
        │ - Serialization          │
        │ - Type erasure           │
        │ - Queue management       │
        │ - Native thread dispatch │
        └──────────────┬───────────┘
                       │
                       ▼
        ┌──────────────────────────┐
        │  Native Module           │
        │ (Objective-C / Kotlin)   │
        │                          │
        │ - AVPlayer / ExoPlayer   │
        │ - Media session          │
        │ - Audio session          │
        └──────────────────────────┘
```

**Characteristics:**
- Asynchronous communication
- Data serialization overhead
- Type information lost
- ~10-50ms latency for method calls
- Reliable but slower

### After: New Architecture
```
┌─────────────────────────────────────────────────────────┐
│                    React Native App                      │
│                  (JavaScript/React)                      │
│                                                           │
│  useAudioPro hook → NativeAudioPro.play()               │
└──────────────────────┬──────────────────────────────────┘
                       │
                       ▼
        ┌──────────────────────────┐
        │   TurboModule (JSI)       │
        │ - Direct access          │
        │ - No serialization       │
        │ - Type-safe              │
        │ - Synchronous capable    │
        └──────────────┬───────────┘
                       │
                       ▼
        ┌──────────────────────────┐
        │  Native Module           │
        │ (Objective-C / Kotlin)   │
        │                          │
        │ - AVPlayer / ExoPlayer   │
        │ - Media session          │
        │ - Audio session          │
        └──────────────────────────┘
```

**Characteristics:**
- Direct access via JavaScript Interface (JSI)
- Zero serialization overhead
- Full type information preserved
- ~1-5ms latency for method calls
- Faster and more modern

## TypeScript Spec: The Bridge Between Worlds

```
┌─────────────────────────────────────────────────────────┐
│          src/specs/NativeAudioPro.ts                     │
│       (TypeScript Specification)                         │
├─────────────────────────────────────────────────────────┤
│                                                           │
│  export interface Spec extends TurboModule {              │
│    play(track: AudioTrack, options: PlayOptions): void;  │
│    pause(): void;                                         │
│    // ... 20 more methods ...                            │
│    addListener(eventName: string): void;                 │
│  }                                                        │
│                                                           │
└─────────────────────────────────────────────────────────┘
           │                         │
           │ CodeGen                 │ CodeGen
           ▼                         ▼
    ┌────────────────┐        ┌────────────────┐
    │ iOS            │        │ Android        │
    │ AudioProSpec   │        │ AudioProSpec   │
    │ Light.swift    │        │ .kt            │
    └────────────────┘        └────────────────┘
           │                         │
           ▼                         ▼
    ┌────────────────┐        ┌────────────────┐
    │ iOS Module     │        │ Android Module │
    │ implements     │        │ implements     │
    │ Spec           │        │ Spec           │
    └────────────────┘        └────────────────┘
```

**The Flow:**
1. Define methods in TypeScript spec
2. CodeGen generates native interfaces
3. Native modules implement interfaces
4. Compiler verifies compliance
5. Build succeeds when everything matches

## Event Emission: Same Pattern, Both Architectures

```
Both Old and New Architecture:

┌──────────────────────────┐
│  Native Module           │
│                          │
│  private func emitEvent( │
│    name: String,         │
│    body: Dictionary      │
│  ) {                     │
│    sendEvent(            │
│      withName: name,     │
│      body: body          │
│    )                     │
│  }                       │
└─────────────┬────────────┘
              │
              ▼ (Same code, both arch)
┌──────────────────────────┐
│  Event Emitter           │
│  (RCTEventEmitter)       │
└─────────────┬────────────┘
              │
              ▼ (Both receive via same names)
┌──────────────────────────┐
│  JavaScript              │
│                          │
│  emitter.addListener(    │
│    'AudioProEvent',      │
│    (event) => {          │
│      // handle event     │
│    }                     │
│  )                       │
└──────────────────────────┘
```

## Conditional Compilation Pattern

```
#if RCT_NEW_ARCH_ENABLED
    // New architecture code
    class AudioPro: NSObject, AudioProSpec {
        // Turbo Module implementation
    }
#else
    // Old architecture code
    class AudioPro: RCTEventEmitter {
        // Legacy Bridge implementation
    }
#endif

// Shared implementation code (works for both)
func play(track: NSDictionary, options: NSDictionary) {
    // Implementation is identical
    // Works with both architectures
}
```

## Build Flow: How CodeGen Works

```
Developer:
  1. Write TypeScript spec
     └─> src/specs/NativeAudioPro.ts

Build System:
  2. Detect spec file
     └─> codegenConfig in package.json
  
  3. Run CodeGen tool
     └─> react-native-codegen CLI
  
  4. Generate native code
     ├─> iOS: AudioProSpecLight.swift
     └─> Android: AudioProSpec.kt
  
  5. Compiler checks
     ├─> iOS: Does class implement spec?
     └─> Android: Does class implement spec?
  
  6. If match → Build succeeds ✅
     If mismatch → Build fails ❌

Result: Type-safe native modules!
```

## Backward Compatibility: Running Both

```
Single Library → Two Build Paths

┌──────────────────────────────────┐
│  react-native-audio-pro          │
│  (Source Code)                   │
│  ├─ src/specs/NativeAudioPro.ts │
│  ├─ ios/AudioPro.swift          │
│  ├─ android/AudioProModule.kt   │
│  └─ src/emitter.ts              │
└──┬───────────────────────────────┘
   │
   ├─────────────────────┬───────────────────────┐
   │                     │                       │
   ▼ (No flags)         ▼ (RCT_NEW_ARCH_ENABLED) ▼ (newArchEnabled=true)
   │                     │                       │
┌──────────────┐   ┌──────────────┐       ┌──────────────┐
│ Legacy Build │   │ iOS New Arch │       │ Android New  │
│  (Default)   │   │    Build     │       │    Arch      │
│              │   │              │       │    Build     │
│ RCTBridge    │   │ TurboModule  │       │ TurboModule  │
│ NativeModule │   │ + JSI        │       │ + JSI        │
└──────────────┘   └──────────────┘       └──────────────┘
   │                     │                       │
   └─────────────────────┴───────────────────────┘
                         │
                    App Works!
                (Same JavaScript API)
```

## Method Call Flow Comparison

### Old Architecture Call
```
JavaScript:
  AudioPro.play(track, options)
         │
         ▼ (Serialization)
  {"__jsonMessageId__": 1, "method": "play", "args": [...]}
         │
         ▼ (Bridge Thread)
  C++ Bridge Layer
         │
         ▼ (Deserialization)
  Native Module receives NSDictionary/ReadableMap
         │
         ▼ (50-100ms total)
  Implementation executes
         │
         ▼ (Reply via event)
  JavaScript receives event
```

### New Architecture Call
```
JavaScript:
  NativeAudioPro.play(track, options)
         │
         ▼ (Direct JSI Call)
  Native Module receives arguments directly
         │
         ▼ (1-5ms total)
  Implementation executes
         │
         ▼ (Reply via event emitter)
  JavaScript receives event
```

## Performance Improvement

```
Old Architecture (Legacy Bridge):
├─ Serialization:        10-20ms
├─ Bridge crossing:      10-30ms
├─ Deserialization:      10-20ms
├─ Native execution:     10-50ms
└─ Total: 40-120ms per call

New Architecture (TurboModule + JSI):
├─ Direct call:          0ms
├─ Native execution:     10-50ms
└─ Total: 10-50ms per call

Improvement: 50-70% faster! 🚀
```

## Development Workflow

```
Standard Development:
  1. Edit TypeScript spec (src/specs/NativeAudioPro.ts)
  2. Run yarn prepare
  3. CodeGen generates native code
  4. Update native implementation to match
  5. Build and test
  6. Code review and merge

Continuous Integration:
  1. CodeGen runs on every build
  2. If spec changed, native code regenerated
  3. Type checking prevents breaking changes
  4. Build fails if spec not implemented
```

## File Structure Highlights

```
react-native-audio-pro/
│
├── src/
│   ├── specs/
│   │   └── NativeAudioPro.ts           ← TypeScript spec
│   │                                      ├─ Defines interface
│   │                                      ├─ Type-safe
│   │                                      └─ Generated code source
│   │
│   └── emitter.ts                       ← Works with both arch
│       ├─ Imports from specs
│       ├─ Same event pattern
│       └─ Auto-detected architecture
│
├── ios/
│   ├── AudioPro.swift                   ← Implements spec
│   │   ├─ Old arch: RCTEventEmitter
│   │   ├─ New arch: TurboModule
│   │   └─ Shared implementation
│   │
│   └── AudioProSpecLight.swift          ← Generated by CodeGen
│       └─ Native interface (auto-generated)
│
├── android/
│   ├── build.gradle                     ← CodeGen config
│   └── src/main/java/.../
│       ├── AudioProModule.kt            ← Implements spec
│       │   ├─ Old arch: ReactContextBase
│       │   ├─ New arch: TurboModule
│       │   └─ Shared implementation
│       │
│       ├── AudioProSpec.kt              ← Generated by CodeGen
│       │   └─ Native interface (auto-generated)
│       │
│       └── AudioProPackage.kt           ← Module registration
│           └─ Works with both architectures
│
└── docs/
    ├── SETUP_NEW_ARCHITECTURE.md        ← How to build
    ├── MIGRATION_iOS.md                 ← iOS guide
    ├── MIGRATION_Android.md             ← Android guide
    └── IMPLEMENTATION_EXAMPLE_*.{swift,kt}  ← Code examples
```

## Success Indicators

When migration is complete, you'll see:

```
✅ CodeGen generates without errors
  └─ ios/AudioProSpecLight.swift exists
  └─ android/.../AudioProSpec.kt exists

✅ Native modules compile
  └─ iOS: Compiles without bridging errors
  └─ Android: Compiles without CodeGen errors

✅ Both architectures work
  └─ yarn example ios (old arch)
  └─ yarn example android (old arch)
  └─ RCT_NEW_ARCH_ENABLED=1 yarn example ios (new arch)
  └─ newArchEnabled=true yarn example android (new arch)

✅ Events flow correctly
  └─ Progress events received
  └─ State changes received
  └─ Error events received

✅ No API changes
  └─ JavaScript code unchanged
  └─ Same hook API
  └─ Same imperative API
  └─ 100% backward compatible

✅ Tests pass
  └─ yarn test
  └─ yarn lint
  └─ yarn typecheck
```

## Key Takeaways

1. **One Spec, Two Implementations**
   - Define once in TypeScript
   - CodeGen generates for each platform
   - Both platforms implement same interface

2. **Performance Win**
   - JSI provides direct access
   - No serialization overhead
   - Synchronous when needed

3. **Type Safety**
   - TypeScript spec defines contract
   - CodeGen verifies implementation
   - Build fails if types don't match

4. **Backward Compatible**
   - Old code still works
   - New code can opt-in
   - Gradual rollout possible

5. **Future-Proof**
   - Aligns with React Native roadmap
   - More libraries using this pattern
   - Better ecosystem support

---

**Created**: January 15, 2025  
**For**: react-native-audio-pro  
**Purpose**: Visual understanding of new architecture migration
