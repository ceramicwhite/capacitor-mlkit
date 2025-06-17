# @capacitor-mlkit/whisper

Capacitor plugin for on-device speech recognition using Whisper.cpp with native performance optimizations.

## Features

- ⚡️ **Native Performance**: Direct integration with whisper.cpp for maximum speed
- 🚀 **Core ML Acceleration**: Hardware-accelerated inference on iOS using Apple Neural Engine
- 🔒 **Privacy-First**: Complete offline processing, no data leaves the device
- 📱 **Optimized Models**: Support for quantized models to reduce memory usage
- 🎯 **High Accuracy**: State-of-the-art speech recognition powered by OpenAI's Whisper
- 📊 **Word-level Timestamps**: Precise timing information for each transcribed word
- 🌍 **Multilingual**: Support for 90+ languages with automatic detection
- 🔧 **Configurable**: Fine-tune parameters for your specific use case

## Installation

```bash
npm install @capacitor-mlkit/whisper
npx cap sync
```

## iOS Setup

### 1. Add Whisper Model to your iOS App Bundle

Download your preferred Whisper model and add it to your iOS project:

```bash
# Download a model (example: base.en model)
curl -L -o ggml-base.en.bin https://huggingface.co/ggml-org/whisper.cpp/resolve/main/ggml-base.en.bin
```

Add the `.bin` file to your iOS project bundle through Xcode:
1. Open your iOS project in Xcode (`npx cap open ios`)
2. Drag the `ggml-base.en.bin` file into your project
3. Ensure "Add to target" is checked for your app target
4. Ensure "Copy items if needed" is checked

### 2. Update Info.plist

Add microphone usage description to your `ios/App/App/Info.plist`:

```xml
<key>NSMicrophoneUsageDescription</key>
<string>This app needs access to the microphone to record audio for transcription.</string>
```

### 3. Enable Core ML (Optional but Recommended)

For maximum performance, Core ML acceleration is enabled by default. No additional setup is required.

## Usage

### Basic Transcription

```typescript
import { Whisper } from '@capacitor-mlkit/whisper';

// Load a model
await Whisper.loadModel({
  modelName: 'base.en',
  useCoreML: true
});

// Transcribe an audio file
const result = await Whisper.transcribeFile({
  filePath: '/path/to/audio/file.wav'
});

console.log('Transcription:', result.text);
console.log('Processing time:', result.processingTime, 'ms');
```

### Advanced Usage with Word Timestamps

```typescript
const result = await Whisper.transcribeFile({
  filePath: '/path/to/audio/file.wav',
  language: 'en',
  wordTimestamps: true,
  suppressNonSpeechTokens: true
});

result.segments.forEach(segment => {
  console.log(`[${segment.startTime}s - ${segment.endTime}s]: ${segment.text}`);
  
  segment.words?.forEach(word => {
    console.log(`  "${word.word}" (${word.confidence.toFixed(2)})`);
  });
});
```

### Model Management

```typescript
// Check if whisper.cpp is supported
const { supported, coreMLSupported } = await Whisper.isSupported();
console.log('Whisper supported:', supported);
console.log('Core ML supported:', coreMLSupported);

// Get model information
const modelInfo = await Whisper.getModelInfo();
console.log('Current model:', modelInfo.modelName);
console.log('Using Core ML:', modelInfo.usingCoreML);
console.log('Model size:', modelInfo.modelSize, 'bytes');

// Unload model to free memory
await Whisper.unloadModel();
```

## API Reference

### Methods

#### `transcribeFile(options: TranscribeFileOptions) => Promise<TranscribeResult>`

Transcribe audio from a file path.

#### `loadModel(options: LoadModelOptions) => Promise<void>`

Load a Whisper model for transcription.

#### `unloadModel() => Promise<void>`

Unload the currently loaded model to free up memory.

#### `getModelInfo() => Promise<ModelInfo>`

Get information about the currently loaded model.

#### `isSupported() => Promise<IsSupportedResult>`

Check if whisper.cpp is supported on this device.

#### `checkPermissions() => Promise<PermissionStatus>`

Check microphone permission status.

#### `requestPermissions() => Promise<PermissionStatus>`

Request microphone permission.

### Interfaces

#### `TranscribeFileOptions`

| Prop | Type | Description | Default |
| --- | --- | --- | --- |
| **`filePath`** | <code>string</code> | Path to the audio file to transcribe. |  |
| **`language`** | <code>string</code> | Language code for transcription (e.g., 'en', 'es', 'fr'). |  |
| **`wordTimestamps`** | <code>boolean</code> | Whether to include word-level timestamps. | `false` |
| **`translate`** | <code>boolean</code> | Whether to translate to English. | `false` |
| **`threadCount`** | <code>number</code> | Number of threads to use (iOS only). |  |
| **`maxContext`** | <code>number</code> | Maximum context length. | `224` |
| **`beamSearch`** | <code>boolean</code> | Whether to use beam search decoding. | `false` |
| **`suppressNonSpeechTokens`** | <code>boolean</code> | Whether to suppress non-speech tokens. | `true` |

#### `LoadModelOptions`

| Prop | Type | Description | Default |
| --- | --- | --- | --- |
| **`modelName`** | <code>string</code> | Name of the model to load. |  |
| **`useCoreML`** | <code>boolean</code> | Whether to use Core ML acceleration (iOS only). | `true` |
| **`allowDownload`** | <code>boolean</code> | Whether to download the model if not available locally. | `true` |

#### `TranscribeResult`

| Prop | Type | Description |
| --- | --- | --- |
| **`text`** | <code>string</code> | The transcribed text. |
| **`segments`** | <code>TranscriptionSegment[]</code> | Array of transcribed segments with timestamps. |
| **`language`** | <code>string</code> | Detected language code. |
| **`processingTime`** | <code>number</code> | Total processing time in milliseconds. |

## Supported Models

The plugin supports all standard Whisper models:

- **tiny** (39 MB) - Fastest, lowest accuracy
- **tiny.en** (39 MB) - English-only, faster than multilingual tiny
- **base** (74 MB) - Good balance of speed and accuracy
- **base.en** (74 MB) - English-only, better accuracy than multilingual base
- **small** (244 MB) - Better accuracy, slower processing
- **small.en** (244 MB) - English-only small model
- **medium** (769 MB) - High accuracy, slower processing
- **large-v3** (1550 MB) - Highest accuracy, slowest processing

## Performance Tips

1. **Use English-only models** when possible for better performance
2. **Start with smaller models** (tiny, base) and upgrade if needed
3. **Enable Core ML** for significant performance improvements on iOS
4. **Preload models** during app initialization for faster transcription
5. **Use appropriate thread counts** based on device capabilities
6. **Consider quantized models** for reduced memory usage

## Error Handling

```typescript
try {
  const result = await Whisper.transcribeFile({
    filePath: '/path/to/audio.wav'
  });
} catch (error) {
  console.error('Transcription failed:', error);
  
  // Handle specific error types
  if (error.message.includes('MODEL_NOT_LOADED')) {
    await Whisper.loadModel({ modelName: 'base.en' });
    // Retry transcription
  }
}
```

## License

Apache-2.0

## Credits

This plugin is built on top of [whisper.cpp](https://github.com/ggerganov/whisper.cpp) by Georgi Gerganov and the original [Whisper](https://github.com/openai/whisper) model by OpenAI.