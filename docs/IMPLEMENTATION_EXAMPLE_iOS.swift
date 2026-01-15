/**
 * Hybrid AudioPro.swift Implementation
 *
 * This file demonstrates how to update ios/AudioPro.swift to support both
 * the old and new React Native architectures.
 *
 * Key points:
 * 1. Uses conditional compilation with RCT_NEW_ARCH_ENABLED
 * 2. Maintains backward compatibility with old architecture
 * 3. All method signatures remain the same
 * 4. Event emission works consistently across architectures
 */

import Foundation
import AVFoundation
import React
import MediaPlayer
import UIKit

// Import the generated spec for new architecture
#if RCT_NEW_ARCH_ENABLED
import AudioProSpec
#endif

#if RCT_NEW_ARCH_ENABLED
@objc(AudioPro)
class AudioPro: NSObject, AudioProSpec, RCTEventEmitter {
    // Synthesize required bridge property for EventEmitter
    @synthesize bridge = _bridge
#else
@objc(AudioPro)
class AudioPro: RCTEventEmitter {
#endif

    // ... all existing properties remain the same ...
    
    private var player: AVPlayer?
    private var timer: Timer?
    private var hasListeners = false
    private let EVENT_NAME = "AudioProEvent"
    private let AMBIENT_EVENT_NAME = "AudioProAmbientEvent"
    
    // ... rest of properties ...

    ////////////////////////////////////////////////////////////
    // MARK: - Module Setup (New Architecture)
    ////////////////////////////////////////////////////////////

    #if RCT_NEW_ARCH_ENABLED
    override static func moduleName() -> String! {
        return "AudioPro"
    }

    override static func requiresMainQueueSetup() -> Bool {
        return false
    }
    #endif

    ////////////////////////////////////////////////////////////
    // MARK: - React Native Event Emitter
    ////////////////////////////////////////////////////////////

    override func supportedEvents() -> [String]! {
        return [EVENT_NAME, AMBIENT_EVENT_NAME]
    }

    override static func requiresMainQueueSetup() -> Bool {
        return false
    }

    override func startObserving() {
        hasListeners = true
    }

    override func stopObserving() {
        hasListeners = false
    }

    ////////////////////////////////////////////////////////////
    // MARK: - Public API Methods
    ////////////////////////////////////////////////////////////

    @objc(play:withOptions:)
    func play(track: NSDictionary, options: NSDictionary) {
        // Implementation remains unchanged
        log("Playing track...")
        // ... existing implementation ...
    }

    @objc
    func pause() {
        // Implementation remains unchanged
        log("Pausing playback...")
        // ... existing implementation ...
    }

    @objc
    func resume() {
        // Implementation remains unchanged
        log("Resuming playback...")
        // ... existing implementation ...
    }

    @objc
    func stop() {
        // Implementation remains unchanged
        log("Stopping playback...")
        // ... existing implementation ...
    }

    @objc(seekTo:)
    func seekTo(position: NSNumber) {
        // Implementation remains unchanged
        log("Seeking to \(position)ms")
        // ... existing implementation ...
    }

    @objc(seekForward:)
    func seekForward(amount: NSNumber) {
        log("Seeking forward by \(amount)ms")
        // ... existing implementation ...
    }

    @objc(seekBack:)
    func seekBack(amount: NSNumber) {
        log("Seeking back by \(amount)ms")
        // ... existing implementation ...
    }

    @objc(setPlaybackSpeed:)
    func setPlaybackSpeed(speed: NSNumber) {
        log("Setting playback speed to \(speed)")
        // ... existing implementation ...
    }

    @objc(setVolume:)
    func setVolume(volume: NSNumber) {
        log("Setting volume to \(volume)")
        // ... existing implementation ...
    }

    @objc
    func clear() {
        log("Clearing audio")
        // ... existing implementation ...
    }

    @objc(ambientPlay:)
    func ambientPlay(options: NSDictionary) {
        log("Playing ambient audio")
        // ... existing implementation ...
    }

    @objc
    func ambientStop() {
        log("Stopping ambient audio")
        // ... existing implementation ...
    }

    @objc(ambientSetVolume:)
    func ambientSetVolume(volume: NSNumber) {
        log("Setting ambient volume to \(volume)")
        // ... existing implementation ...
    }

    @objc
    func ambientPause() {
        log("Pausing ambient audio")
        // ... existing implementation ...
    }

    @objc
    func ambientResume() {
        log("Resuming ambient audio")
        // ... existing implementation ...
    }

    @objc(ambientSeekTo:)
    func ambientSeekTo(positionMs: NSNumber) {
        log("Seeking ambient audio to \(positionMs)ms")
        // ... existing implementation ...
    }

    ////////////////////////////////////////////////////////////
    // MARK: - Event Emission (Works for Both Architectures)
    ////////////////////////////////////////////////////////////

    private func emitEvent(_ eventName: String, body: [String: Any]) {
        if hasListeners {
            self.sendEvent(withName: eventName, body: body)
        }
    }

    private func sendStateEvent(state: String, position: Double = 0, duration: Double = 0, track: NSDictionary?) {
        var eventBody: [String: Any] = [
            "type": "STATE_CHANGED",
            "state": state,
            "position": position,
            "duration": duration
        ]
        
        if let track = track {
            eventBody["track"] = track
        }
        
        emitEvent(EVENT_NAME, body: eventBody)
    }

    private func sendProgressEvent(position: Double, duration: Double) {
        let eventBody: [String: Any] = [
            "type": "PROGRESS",
            "position": position,
            "duration": duration
        ]
        emitEvent(EVENT_NAME, body: eventBody)
    }

    // ... all other event methods ...

    ////////////////////////////////////////////////////////////
    // MARK: - Helper Methods
    ////////////////////////////////////////////////////////////

    private func log(_ items: Any...) {
        // Debug logging implementation
        // ... existing implementation ...
    }

    // ... all other helper methods remain unchanged ...
}

/*
 * MIGRATION NOTES:
 *
 * 1. The @objc attributes remain for backward compatibility with old bridge
 * 2. No #if guards needed for public methods - they work with both architectures
 * 3. Event emission uses the same sendEvent method for both old and new arch
 * 4. The EventEmitter protocol is synthesized for new architecture via bridge property
 *
 * 2. When CodeGen generates AudioProSpec.swift, it creates method definitions
 *    that match this class's public methods
 *
 * 3. For new architecture:
 *    - TurboModuleRegistry will instantiate this class
 *    - JSI will call methods directly
 *    - Events still go through RCTEventEmitter
 *
 * 4. For old architecture:
 *    - RCTBridge will instantiate this class
 *    - Methods will be called via serialized bridge calls
 *    - Events go through RCTEventEmitter as before
 *
 * NO BREAKING CHANGES - Existing implementation logic is preserved.
 */
