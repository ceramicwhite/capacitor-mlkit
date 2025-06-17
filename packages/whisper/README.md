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

### From GitHub Repository

```bash
# Install directly from GitHub repository
npm install https://github.com/ceramicwhite/capacitor-mlkit.git#main --save
# or install the specific whisper package
npm install git+https://github.com/ceramicwhite/capacitor-mlkit.git#main:packages/whisper

# Sync with your Capacitor project
npx cap sync
```

### From npm (when published)

```bash
npm install @capacitor-mlkit/whisper
npx cap sync
```

### Local Development

```bash
# Clone the repository
git clone https://github.com/ceramicwhite/capacitor-mlkit.git

# Install from local path
npm install ./capacitor-mlkit/packages/whisper
npx cap sync
```

## iOS Setup

### 1. Add Whisper Model to your iOS App Bundle

You can use either GGML models (whisper.cpp format) or Core ML models (optimized for iOS):

#### Option A: GGML Models (whisper.cpp format)

Download standard whisper.cpp models:

```bash
# Download a model (example: base.en model ~74MB)
curl -L -o ggml-base.en.bin https://huggingface.co/ggml-org/whisper.cpp/resolve/main/ggml-base.en.bin

# Other available models:
# curl -L -o ggml-tiny.en.bin https://huggingface.co/ggml-org/whisper.cpp/resolve/main/ggml-tiny.en.bin
# curl -L -o ggml-small.en.bin https://huggingface.co/ggml-org/whisper.cpp/resolve/main/ggml-small.en.bin
```

#### Option B: Core ML Models (Recommended for iOS)

For optimal performance on iOS, use Core ML models from WhisperKit:

```bash
# Download Core ML models (better performance on iOS)
# Base English model (~74MB)
curl -L -o openai_whisper-base.en.mlmodelc.zip https://huggingface.co/argmaxinc/whisperkit-coreml/resolve/main/openai_whisper-base.en/openai_whisper-base.en.mlmodelc.zip
unzip openai_whisper-base.en.mlmodelc.zip

# Tiny English model (~39MB) - fastest
# curl -L -o openai_whisper-tiny.en.mlmodelc.zip https://huggingface.co/argmaxinc/whisperkit-coreml/resolve/main/openai_whisper-tiny.en/openai_whisper-tiny.en.mlmodelc.zip

# Small English model (~244MB) - better accuracy
# curl -L -o openai_whisper-small.en.mlmodelc.zip https://huggingface.co/argmaxinc/whisperkit-coreml/resolve/main/openai_whisper-small.en/openai_whisper-small.en.mlmodelc.zip
```

#### Add Model to Xcode Project

Add the model file to your iOS project bundle:
1. Open your iOS project in Xcode (`npx cap open ios`)
2. Drag the model file (`.bin` or `.mlmodelc`) into your project
3. ✅ Ensure "Add to target" is checked for your app target
4. ✅ Ensure "Copy items if needed" is checked
5. ✅ For `.mlmodelc` files, ensure they're added as folder references (blue folder icon)

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

The plugin supports both GGML (whisper.cpp) and Core ML models:

### GGML Models (whisper.cpp format)
- **tiny** (39 MB) - Fastest, lowest accuracy
- **tiny.en** (39 MB) - English-only, faster than multilingual tiny
- **base** (74 MB) - Good balance of speed and accuracy
- **base.en** (74 MB) - English-only, better accuracy than multilingual base
- **small** (244 MB) - Better accuracy, slower processing
- **small.en** (244 MB) - English-only small model
- **medium** (769 MB) - High accuracy, slower processing
- **large-v3** (1550 MB) - Highest accuracy, slowest processing

### Core ML Models (iOS Optimized)
Available from [WhisperKit Core ML Models](https://huggingface.co/argmaxinc/whisperkit-coreml):
- **openai_whisper-tiny.en** (39 MB) - Hardware-accelerated tiny model
- **openai_whisper-base.en** (74 MB) - Hardware-accelerated base model
- **openai_whisper-small.en** (244 MB) - Hardware-accelerated small model
- **openai_whisper-large-v3** (1550 MB) - Hardware-accelerated large model

> **Recommendation**: Use Core ML models (`.mlmodelc`) for best performance on iOS devices with Apple Neural Engine acceleration.

## Performance Tips

1. **Use Core ML models** (`.mlmodelc`) for maximum performance on iOS
2. **Use English-only models** when possible for better performance
3. **Start with smaller models** (tiny, base) and upgrade if needed
4. **Enable Core ML acceleration** for significant performance improvements
5. **Preload models** during app initialization for faster transcription
6. **Use appropriate thread counts** based on device capabilities
7. **Consider model size vs accuracy tradeoffs** based on your use case

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