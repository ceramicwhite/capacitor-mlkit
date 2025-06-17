import type { PermissionState, PluginListenerHandle } from '@capacitor/core';

export interface WhisperPlugin {
  /**
   * Transcribe audio from a file path.
   *
   * On iOS, this method leverages whisper.cpp with Core ML acceleration
   * for maximum performance and efficiency.
   *
   * @since 0.1.0
   */
  transcribeFile(options: TranscribeFileOptions): Promise<TranscribeResult>;

  /**
   * Load a Whisper model for transcription.
   *
   * This method preloads the model to improve transcription performance.
   * The model is loaded from the app bundle or downloaded if necessary.
   *
   * @since 0.1.0
   */
  loadModel(options: LoadModelOptions): Promise<void>;

  /**
   * Unload the currently loaded model to free up memory.
   *
   * @since 0.1.0
   */
  unloadModel(): Promise<void>;

  /**
   * Get information about the currently loaded model.
   *
   * @since 0.1.0
   */
  getModelInfo(): Promise<ModelInfo>;

  /**
   * Check if the whisper.cpp library is available and properly configured.
   *
   * @since 0.1.0
   */
  isSupported(): Promise<IsSupportedResult>;

  /**
   * Check microphone permission status.
   *
   * @since 0.1.0
   */
  checkPermissions(): Promise<PermissionStatus>;

  /**
   * Request microphone permission.
   *
   * @since 0.1.0
   */
  requestPermissions(): Promise<PermissionStatus>;

  /**
   * Called when transcription progress is updated.
   *
   * @since 0.1.0
   */
  addListener(
    eventName: 'transcriptionProgress',
    listenerFunc: (event: TranscriptionProgressEvent) => void,
  ): Promise<PluginListenerHandle>;

  /**
   * Called when an error occurs during transcription.
   *
   * @since 0.1.0
   */
  addListener(
    eventName: 'transcriptionError',
    listenerFunc: (event: TranscriptionErrorEvent) => void,
  ): Promise<PluginListenerHandle>;

  /**
   * Remove all listeners for this plugin.
   *
   * @since 0.1.0
   */
  removeAllListeners(): Promise<void>;
}

/**
 * @since 0.1.0
 */
export interface TranscribeFileOptions {
  /**
   * Path to the audio file to transcribe.
   * Supports common audio formats: WAV, MP3, M4A, AAC, FLAC.
   *
   * @since 0.1.0
   */
  filePath: string;

  /**
   * Language code for transcription (e.g., 'en', 'es', 'fr').
   * If not specified, auto-detection will be used.
   *
   * @since 0.1.0
   */
  language?: string;

  /**
   * Whether to include word-level timestamps in the result.
   *
   * @since 0.1.0
   * @default false
   */
  wordTimestamps?: boolean;

  /**
   * Whether to translate the transcription to English.
   * Only works with multilingual models.
   *
   * @since 0.1.0
   * @default false
   */
  translate?: boolean;

  /**
   * Number of threads to use for transcription (iOS only).
   * If not specified, will use optimal number based on device.
   *
   * @since 0.1.0
   */
  threadCount?: number;

  /**
   * Maximum context length for the transcription.
   *
   * @since 0.1.0
   * @default 224
   */
  maxContext?: number;

  /**
   * Whether to use beam search for decoding.
   *
   * @since 0.1.0
   * @default false
   */
  beamSearch?: boolean;

  /**
   * Whether to suppress non-speech tokens.
   *
   * @since 0.1.0
   * @default true
   */
  suppressNonSpeechTokens?: boolean;
}

/**
 * @since 0.1.0
 */
export interface LoadModelOptions {
  /**
   * Name of the model to load.
   * Common models: 'tiny', 'tiny.en', 'base', 'base.en', 'small', 'small.en', 'medium', 'large-v3'
   *
   * @since 0.1.0
   */
  modelName: string;

  /**
   * Whether to use Core ML acceleration (iOS only).
   * When enabled, provides significant performance improvements.
   *
   * @since 0.1.0
   * @default true
   */
  useCoreML?: boolean;

  /**
   * Whether to download the model if not available locally.
   *
   * @since 0.1.0
   * @default true
   */
  allowDownload?: boolean;
}

/**
 * @since 0.1.0
 */
export interface TranscribeResult {
  /**
   * The transcribed text.
   *
   * @since 0.1.0
   */
  text: string;

  /**
   * Array of transcribed segments with timestamps.
   *
   * @since 0.1.0
   */
  segments: TranscriptionSegment[];

  /**
   * Detected language code.
   *
   * @since 0.1.0
   */
  language: string;

  /**
   * Total processing time in milliseconds.
   *
   * @since 0.1.0
   */
  processingTime: number;
}

/**
 * @since 0.1.0
 */
export interface TranscriptionSegment {
  /**
   * Start time of the segment in seconds.
   *
   * @since 0.1.0
   */
  startTime: number;

  /**
   * End time of the segment in seconds.
   *
   * @since 0.1.0
   */
  endTime: number;

  /**
   * Text content of the segment.
   *
   * @since 0.1.0
   */
  text: string;

  /**
   * Word-level timestamps if requested.
   *
   * @since 0.1.0
   */
  words?: WordTimestamp[];
}

/**
 * @since 0.1.0
 */
export interface WordTimestamp {
  /**
   * The word.
   *
   * @since 0.1.0
   */
  word: string;

  /**
   * Start time of the word in seconds.
   *
   * @since 0.1.0
   */
  startTime: number;

  /**
   * End time of the word in seconds.
   *
   * @since 0.1.0
   */
  endTime: number;

  /**
   * Confidence score (0.0 to 1.0).
   *
   * @since 0.1.0
   */
  confidence: number;
}

/**
 * @since 0.1.0
 */
export interface ModelInfo {
  /**
   * Name of the currently loaded model.
   *
   * @since 0.1.0
   */
  modelName: string;

  /**
   * Whether the model is loaded and ready for use.
   *
   * @since 0.1.0
   */
  isLoaded: boolean;

  /**
   * Whether Core ML acceleration is enabled (iOS only).
   *
   * @since 0.1.0
   */
  usingCoreML: boolean;

  /**
   * Model file size in bytes.
   *
   * @since 0.1.0
   */
  modelSize: number;

  /**
   * Supported languages by the model.
   *
   * @since 0.1.0
   */
  supportedLanguages: string[];
}

/**
 * @since 0.1.0
 */
export interface IsSupportedResult {
  /**
   * Whether whisper.cpp is supported on this device.
   *
   * @since 0.1.0
   */
  supported: boolean;

  /**
   * Whether Core ML acceleration is available (iOS only).
   *
   * @since 0.1.0
   */
  coreMLSupported?: boolean;
}

/**
 * @since 0.1.0
 */
export type MicrophonePermissionState = PermissionState | 'limited';

/**
 * @since 0.1.0
 */
export interface PermissionStatus {
  /**
   * @since 0.1.0
   */
  microphone: MicrophonePermissionState;
}

/**
 * @since 0.1.0
 */
export interface TranscriptionProgressEvent {
  /**
   * Current transcription progress (0.0 to 1.0).
   *
   * @since 0.1.0
   */
  progress: number;

  /**
   * Intermediate transcription result (if available).
   *
   * @since 0.1.0
   */
  partialText?: string;
}

/**
 * @since 0.1.0
 */
export interface TranscriptionErrorEvent {
  /**
   * Error message.
   *
   * @since 0.1.0
   */
  message: string;

  /**
   * Error code.
   *
   * @since 0.1.0
   */
  code: TranscriptionErrorCode;
}

/**
 * @since 0.1.0
 */
export enum TranscriptionErrorCode {
  /**
   * Unknown error occurred.
   *
   * @since 0.1.0
   */
  UNKNOWN = 'UNKNOWN',

  /**
   * Model not loaded or failed to load.
   *
   * @since 0.1.0
   */
  MODEL_NOT_LOADED = 'MODEL_NOT_LOADED',

  /**
   * Audio file not found or cannot be read.
   *
   * @since 0.1.0
   */
  FILE_NOT_FOUND = 'FILE_NOT_FOUND',

  /**
   * Unsupported audio format.
   *
   * @since 0.1.0
   */
  UNSUPPORTED_FORMAT = 'UNSUPPORTED_FORMAT',

  /**
   * Insufficient memory to process the audio.
   *
   * @since 0.1.0
   */
  INSUFFICIENT_MEMORY = 'INSUFFICIENT_MEMORY',

  /**
   * Permission denied (microphone access).
   *
   * @since 0.1.0
   */
  PERMISSION_DENIED = 'PERMISSION_DENIED',

  /**
   * Network error when downloading model.
   *
   * @since 0.1.0
   */
  NETWORK_ERROR = 'NETWORK_ERROR',

  /**
   * Model download failed.
   *
   * @since 0.1.0
   */
  MODEL_DOWNLOAD_FAILED = 'MODEL_DOWNLOAD_FAILED',
}

/**
 * @since 0.1.0
 */
export enum WhisperModel {
  /**
   * Tiny model (39 MB). Fastest but lowest accuracy.
   *
   * @since 0.1.0
   */
  TINY = 'tiny',

  /**
   * Tiny English-only model (39 MB). Faster than multilingual tiny.
   *
   * @since 0.1.0
   */
  TINY_EN = 'tiny.en',

  /**
   * Base model (74 MB). Good balance of speed and accuracy.
   *
   * @since 0.1.0
   */
  BASE = 'base',

  /**
   * Base English-only model (74 MB). Better than multilingual base for English.
   *
   * @since 0.1.0
   */
  BASE_EN = 'base.en',

  /**
   * Small model (244 MB). Better accuracy than base.
   *
   * @since 0.1.0
   */
  SMALL = 'small',

  /**
   * Small English-only model (244 MB). Optimized for English.
   *
   * @since 0.1.0
   */
  SMALL_EN = 'small.en',

  /**
   * Medium model (769 MB). High accuracy, slower processing.
   *
   * @since 0.1.0
   */
  MEDIUM = 'medium',

  /**
   * Large v3 model (1550 MB). Highest accuracy, slowest processing.
   *
   * @since 0.1.0
   */
  LARGE_V3 = 'large-v3',
}