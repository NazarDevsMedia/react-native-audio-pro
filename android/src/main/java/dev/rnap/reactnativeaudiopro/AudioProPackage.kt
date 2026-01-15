package dev.rnap.reactnativeaudiopro

import com.facebook.react.TurboReactPackage
import com.facebook.react.bridge.NativeModule
import com.facebook.react.bridge.ReactApplicationContext
import com.facebook.react.module.model.ReactModuleInfo
import com.facebook.react.module.model.ReactModuleInfoProvider

/**
 * AudioProPackage - Package for registering AudioPro native module
 * 
 * Supports both old architecture (ReactPackage) and new architecture (TurboReactPackage)
 * via inheritance from TurboReactPackage which implements both interfaces.
 */
class AudioProPackage : TurboReactPackage() {
	override fun getModule(
		name: String,
		reactContext: ReactApplicationContext
	): NativeModule? {
		return if (name == AudioProModule.NAME) {
			AudioProModule(reactContext)
		} else {
			null
		}
	}

	override fun getReactModuleInfoProvider(): ReactModuleInfoProvider {
		return ReactModuleInfoProvider {
			mapOf(
				AudioProModule.NAME to ReactModuleInfo(
					_name = AudioProModule.NAME,
					_className = "AudioProModule",
					canOverrideExistingModule = true,
					needsEagerInit = false,
					isCxxModule = false,
					isTurboModule = true
				)
			)
		}
	}
}
