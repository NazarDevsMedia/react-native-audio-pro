/**
 * NativeAudioPro.ts
 *
 * This file defines the TypeScript specification for the AudioPro native module.
 * It is used by react-native-codegen to automatically generate native bridging code
 * for both iOS and Android platforms.
 *
 * Changes to this file will trigger CodeGen to regenerate the native specs.
 */

import type { TurboModule } from 'react-native';
import { TurboModuleRegistry } from 'react-native';

/**
 * Audio track data structure
 */
export interface AudioTrack {
	url: string;
	title: string;
	artwork: string;
	album?: string;
	artist?: string;
}

/**
 * Options for audio playback
 */
export interface PlayOptions {
	debug?: boolean;
	debugIncludesProgress?: boolean;
	playbackSpeed?: number;
	volume?: number;
	autoPlay?: boolean;
	showNextPrevControls?: boolean;
	showSkipControls?: boolean;
	startTimeMs?: number;
	skipIntervalMs?: number;
	progressIntervalMs?: number;
	contentType?: string;
	headers?: {
		audio?: {
			[key: string]: string;
		};
	};
}

/**
 * Options for ambient audio playback
 */
export interface AmbientPlayOptions {
	url: string;
	debug?: boolean;
	loop?: boolean;
	volume?: number;
}

/**
 * Native Audio Pro Module Interface
 * Defines all methods exposed to JavaScript
 */
export interface Spec extends TurboModule {
	/**
	 * Play an audio track
	 * @param track The audio track to play
	 * @param options Playback options
	 */
	play(track: AudioTrack, options: PlayOptions): void;

	/**
	 * Pause playback
	 */
	pause(): void;

	/**
	 * Resume playback
	 */
	resume(): void;

	/**
	 * Stop playback and cleanup
	 */
	stop(): void;

	/**
	 * Seek to a specific position
	 * @param position Position in milliseconds
	 */
	seekTo(position: number): void;

	/**
	 * Seek forward by a specified amount
	 * @param amount Amount in milliseconds
	 */
	seekForward(amount: number): void;

	/**
	 * Seek backward by a specified amount
	 * @param amount Amount in milliseconds
	 */
	seekBack(amount: number): void;

	/**
	 * Set playback speed
	 * @param speed Playback speed (1.0 = normal speed)
	 */
	setPlaybackSpeed(speed: number): void;

	/**
	 * Set volume
	 * @param volume Volume level (0.0 to 1.0)
	 */
	setVolume(volume: number): void;

	/**
	 * Clear current playback and reset state
	 */
	clear(): void;

	/**
	 * Play ambient audio in background
	 * @param options Ambient playback options
	 */
	ambientPlay(options: AmbientPlayOptions): void;

	/**
	 * Stop ambient audio playback
	 */
	ambientStop(): void;

	/**
	 * Set ambient audio volume
	 * @param volume Volume level (0.0 to 1.0)
	 */
	ambientSetVolume(volume: number): void;

	/**
	 * Pause ambient audio
	 */
	ambientPause(): void;

	/**
	 * Resume ambient audio
	 */
	ambientResume(): void;

	/**
	 * Seek ambient audio to a specific position
	 * @param positionMs Position in milliseconds
	 */
	ambientSeekTo(positionMs: number): void;

	/**
	 * Event emitter methods (required for RN event system)
	 */
	addListener(eventName: string): void;
	removeListeners(count: number): void;
}

export default TurboModuleRegistry.getEnforcing<Spec>('AudioPro');
