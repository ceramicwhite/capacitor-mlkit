import Foundation
import AVFoundation

// C API bindings for whisper.cpp
// These will be linked through the whisper.cpp library

// MARK: - C API Declarations
typealias WhisperContext = OpaquePointer

// Whisper context functions
@_silgen_name("whisper_init_from_file_with_params")
func whisper_init_from_file_with_params(_ path: UnsafePointer<CChar>, _ params: whisper_context_params) -> WhisperContext?

@_silgen_name("whisper_free")
func whisper_free(_ ctx: WhisperContext)

@_silgen_name("whisper_context_default_params")
func whisper_context_default_params() -> whisper_context_params

@_silgen_name("whisper_full_default_params")
func whisper_full_default_params(_ strategy: whisper_sampling_strategy) -> whisper_full_params

@_silgen_name("whisper_full")
func whisper_full(_ ctx: WhisperContext, _ params: whisper_full_params, _ samples: UnsafePointer<Float>, _ n_samples: Int32) -> Int32

@_silgen_name("whisper_full_n_segments")
func whisper_full_n_segments(_ ctx: WhisperContext) -> Int32

@_silgen_name("whisper_full_get_segment_text")
func whisper_full_get_segment_text(_ ctx: WhisperContext, _ i_segment: Int32) -> UnsafePointer<CChar>

@_silgen_name("whisper_full_get_segment_t0")
func whisper_full_get_segment_t0(_ ctx: WhisperContext, _ i_segment: Int32) -> Int64

@_silgen_name("whisper_full_get_segment_t1")
func whisper_full_get_segment_t1(_ ctx: WhisperContext, _ i_segment: Int32) -> Int64

@_silgen_name("whisper_full_lang_id")
func whisper_full_lang_id(_ ctx: WhisperContext) -> Int32

@_silgen_name("whisper_lang_str")
func whisper_lang_str(_ id: Int32) -> UnsafePointer<CChar>

@_silgen_name("whisper_full_n_tokens")
func whisper_full_n_tokens(_ ctx: WhisperContext, _ i_segment: Int32) -> Int32

@_silgen_name("whisper_full_get_token_text")
func whisper_full_get_token_text(_ ctx: WhisperContext, _ i_segment: Int32, _ i_token: Int32) -> UnsafePointer<CChar>

@_silgen_name("whisper_full_get_token_data")
func whisper_full_get_token_data(_ ctx: WhisperContext, _ i_segment: Int32, _ i_token: Int32) -> whisper_token_data

// Core ML check
@_silgen_name("whisper_has_coreml")
func whisper_has_coreml() -> Bool

// MARK: - C Structs
struct whisper_context_params {
    var use_gpu: Bool
    var gpu_device: Int32
    
    init() {
        use_gpu = false
        gpu_device = 0
    }
}

struct whisper_full_params {
    var strategy: whisper_sampling_strategy
    var n_threads: Int32
    var n_max_text_ctx: Int32
    var offset_ms: Int32
    var duration_ms: Int32
    var translate: Bool
    var no_context: Bool
    var no_timestamps: Bool
    var single_segment: Bool
    var print_special: Bool
    var print_progress: Bool
    var print_realtime: Bool
    var print_timestamps: Bool
    var token_timestamps: Bool
    var thold_pt: Float
    var thold_ptsum: Float
    var max_len: Int32
    var split_on_word: Bool
    var max_tokens: Int32
    var speed_up: Bool
    var debug_mode: Bool
    var audio_ctx: Int32
    var tdrz_enable: Bool
    var suppress_blank: Bool
    var suppress_non_speech_tokens: Bool
    var temperature: Float
    var max_initial_ts: Float
    var length_penalty: Float
    var temperature_inc: Float
    var entropy_thold: Float
    var logprob_thold: Float
    var no_speech_thold: Float
    var greedy: whisper_greedy
    var beam_search: whisper_beam_search
    var language: UnsafePointer<CChar>?
    var detect_language: Bool
    var prompt_tokens: UnsafePointer<whisper_token>?
    var prompt_n_tokens: Int32
    
    init() {
        strategy = WHISPER_SAMPLING_GREEDY
        n_threads = 0
        n_max_text_ctx = 16384
        offset_ms = 0
        duration_ms = 0
        translate = false
        no_context = false
        no_timestamps = false
        single_segment = false
        print_special = false
        print_progress = false
        print_realtime = false
        print_timestamps = false
        token_timestamps = false
        thold_pt = 0.01
        thold_ptsum = 0.01
        max_len = 0
        split_on_word = false
        max_tokens = 0
        speed_up = false
        debug_mode = false
        audio_ctx = 0
        tdrz_enable = false
        suppress_blank = true
        suppress_non_speech_tokens = false
        temperature = 0.0
        max_initial_ts = 1.0
        length_penalty = -1.0
        temperature_inc = 0.2
        entropy_thold = 2.4
        logprob_thold = -1.0
        no_speech_thold = 0.6
        greedy = whisper_greedy()
        beam_search = whisper_beam_search()
        language = nil
        detect_language = false
        prompt_tokens = nil
        prompt_n_tokens = 0
    }
}

struct whisper_greedy {
    var best_of: Int32
    
    init() {
        best_of = 5
    }
}

struct whisper_beam_search {
    var beam_size: Int32
    var patience: Float
    
    init() {
        beam_size = 5
        patience = -1.0
    }
}

struct whisper_token_data {
    var id: whisper_token
    var tid: whisper_token
    var p: Float
    var plog: Float
    var pt: Float
    var ptsum: Float
    var t0: Int64
    var t1: Int64
    var vlen: Float
    
    init() {
        id = 0
        tid = 0
        p = 0.0
        plog = 0.0
        pt = 0.0
        ptsum = 0.0
        t0 = 0
        t1 = 0
        vlen = 0.0
    }
}

typealias whisper_token = Int32

enum whisper_sampling_strategy: Int32 {
    case WHISPER_SAMPLING_GREEDY = 0
    case WHISPER_SAMPLING_BEAM_SEARCH = 1
}

/**
 * Core implementation of Whisper speech recognition using whisper.cpp
 * with Core ML acceleration support
 */
public class Whisper {
    private var whisperContext: WhisperContext?
    private var currentModel: String?
    private var isModelLoaded: Bool = false
    private var usingCoreML: Bool = false
    
    public init() {
        // Initialize any required components
    }
    
    deinit {
        unloadModel()
    }
    
    public func initialize() {
        // Perform any initialization tasks
        NSLog("Whisper implementation initialized")
    }
    
    public func transcribeFile(options: TranscribeFileOptions) throws -> TranscribeResult {
        guard isModelLoaded else {
            throw WhisperError.modelNotLoaded
        }
        
        guard let context = whisperContext else {
            throw WhisperError.modelNotLoaded
        }
        
        // Check if file exists
        guard FileManager.default.fileExists(atPath: options.filePath) else {
            throw WhisperError.fileNotFound
        }
        
        let startTime = CFAbsoluteTimeGetCurrent()
        
        // Load and convert audio file
        let audioData = try loadAudioFile(path: options.filePath)
        
        // Configure whisper parameters
        var params = whisper_full_default_params(WHISPER_SAMPLING_GREEDY)
        params.print_realtime = false
        params.print_progress = false
        params.print_timestamps = false
        params.print_special = false
        params.translate = options.translate
        params.n_threads = Int32(options.threadCount ?? 0)
        params.n_max_text_ctx = Int32(options.maxContext)
        params.suppress_non_speech_tokens = options.suppressNonSpeechTokens
        params.token_timestamps = options.wordTimestamps
        
        if let language = options.language {
            let cString = strdup(language)
            params.language = UnsafePointer(cString)
        }
        
        if options.beamSearch {
            params.strategy = WHISPER_SAMPLING_BEAM_SEARCH
            params.beam_search.beam_size = 5
        }
        
        // Run transcription
        let result = whisper_full(context, params, audioData, Int32(audioData.count))
        
        // Free language string if allocated
        if let languagePtr = params.language {
            free(UnsafeMutablePointer(mutating: languagePtr))
        }
        
        if result != 0 {
            throw WhisperError.transcriptionFailed("Whisper transcription failed with code: \(result)")
        }
        
        // Extract results
        let segmentCount = whisper_full_n_segments(context)
        var segments: [TranscriptionSegment] = []
        var fullText = ""
        
        for i in 0..<segmentCount {
            let segmentText = String(cString: whisper_full_get_segment_text(context, i))
            let startTime = whisper_full_get_segment_t0(context, i)
            let endTime = whisper_full_get_segment_t1(context, i)
            
            var words: [WordTimestamp]?
            
            if options.wordTimestamps {
                words = extractWordTimestamps(context: context, segmentIndex: i)
            }
            
            let segment = TranscriptionSegment(
                startTime: Double(startTime) / 100.0, // Convert to seconds
                endTime: Double(endTime) / 100.0,
                text: segmentText,
                words: words
            )
            
            segments.append(segment)
            fullText += segmentText
        }
        
        let processingTime = CFAbsoluteTimeGetCurrent() - startTime
        
        // Detect language
        let languageId = whisper_full_lang_id(context)
        let language = String(cString: whisper_lang_str(languageId))
        
        return TranscribeResult(
            text: fullText,
            segments: segments,
            language: language,
            processingTime: processingTime * 1000 // Convert to milliseconds
        )
    }
    
    public func loadModel(options: LoadModelOptions) throws {
        // Unload any existing model
        unloadModel()
        
        let modelPath = try getModelPath(modelName: options.modelName, allowDownload: options.allowDownload)
        
        // Configure context parameters for Core ML if requested
        var contextParams = whisper_context_default_params()
        contextParams.use_gpu = options.useCoreML
        
        // Load the model
        let cPath = modelPath.cString(using: .utf8)!
        whisperContext = whisper_init_from_file_with_params(cPath, contextParams)
        
        guard whisperContext != nil else {
            throw WhisperError.modelLoadFailed("Failed to load model from: \(modelPath)")
        }
        
        currentModel = options.modelName
        isModelLoaded = true
        usingCoreML = options.useCoreML
        
        NSLog("Whisper model loaded successfully: \(options.modelName)")
    }
    
    public func unloadModel() {
        if let context = whisperContext {
            whisper_free(context)
            whisperContext = nil
        }
        
        currentModel = nil
        isModelLoaded = false
        usingCoreML = false
    }
    
    public func getModelInfo() -> ModelInfo {
        guard let modelName = currentModel else {
            return ModelInfo(
                modelName: "",
                isLoaded: false,
                usingCoreML: false,
                modelSize: 0,
                supportedLanguages: []
            )
        }
        
        let modelSize = getModelFileSize(modelName: modelName)
        let supportedLanguages = getSupportedLanguages()
        
        return ModelInfo(
            modelName: modelName,
            isLoaded: isModelLoaded,
            usingCoreML: usingCoreML,
            modelSize: modelSize,
            supportedLanguages: supportedLanguages
        )
    }
    
    public func isSupported() -> IsSupportedResult {
        let coreMLSupported = whisper_has_coreml()
        
        return IsSupportedResult(
            supported: true, // whisper.cpp is always supported on iOS
            coreMLSupported: coreMLSupported
        )
    }
    
    // MARK: - Private Methods
    
    private func loadAudioFile(path: String) throws -> [Float] {
        let url = URL(fileURLWithPath: path)
        
        // Read audio file using AVAudioFile
        let audioFile: AVAudioFile
        do {
            audioFile = try AVAudioFile(forReading: url)
        } catch {
            throw WhisperError.fileNotFound
        }
        
        let frameCount = AVAudioFrameCount(audioFile.length)
        guard let audioBuffer = AVAudioPCMBuffer(pcmFormat: audioFile.processingFormat, frameCapacity: frameCount) else {
            throw WhisperError.insufficientMemory
        }
        
        try audioFile.read(into: audioBuffer)
        
        // Convert to Float32 array (mono, 16kHz sample rate expected by Whisper)
        guard let floatData = audioBuffer.floatChannelData?[0] else {
            throw WhisperError.unsupportedFormat
        }
        
        let sampleCount = Int(audioBuffer.frameLength)
        var audioArray = Array(UnsafeBufferPointer(start: floatData, count: sampleCount))
        
        // Resample to 16kHz if necessary
        if audioFile.processingFormat.sampleRate != 16000 {
            audioArray = try resampleAudio(audioArray, fromSampleRate: audioFile.processingFormat.sampleRate, toSampleRate: 16000)
        }
        
        // Convert to mono if necessary
        if audioFile.processingFormat.channelCount > 1 {
            audioArray = convertToMono(audioArray, channelCount: Int(audioFile.processingFormat.channelCount))
        }
        
        return audioArray
    }
    
    private func resampleAudio(_ input: [Float], fromSampleRate: Double, toSampleRate: Double) throws -> [Float] {
        // Simple resampling implementation
        // For production, consider using more sophisticated resampling
        let ratio = fromSampleRate / toSampleRate
        let outputLength = Int(Double(input.count) / ratio)
        var output: [Float] = []
        output.reserveCapacity(outputLength)
        
        for i in 0..<outputLength {
            let index = Double(i) * ratio
            let lowerIndex = Int(floor(index))
            let upperIndex = min(lowerIndex + 1, input.count - 1)
            let fraction = index - Double(lowerIndex)
            
            let interpolated = input[lowerIndex] * Float(1.0 - fraction) + input[upperIndex] * Float(fraction)
            output.append(interpolated)
        }
        
        return output
    }
    
    private func convertToMono(_ input: [Float], channelCount: Int) -> [Float] {
        let frameCount = input.count / channelCount
        var output: [Float] = []
        output.reserveCapacity(frameCount)
        
        for frame in 0..<frameCount {
            var sum: Float = 0
            for channel in 0..<channelCount {
                sum += input[frame * channelCount + channel]
            }
            output.append(sum / Float(channelCount))
        }
        
        return output
    }
    
    private func extractWordTimestamps(context: WhisperContext, segmentIndex: Int32) -> [WordTimestamp] {
        let tokenCount = whisper_full_n_tokens(context, segmentIndex)
        var words: [WordTimestamp] = []
        
        for i in 0..<tokenCount {
            let tokenData = whisper_full_get_token_data(context, segmentIndex, i)
            let token = String(cString: whisper_full_get_token_text(context, segmentIndex, i))
            
            // Filter out special tokens
            if !token.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && 
               !token.hasPrefix("[") && !token.hasPrefix("<") {
                let word = WordTimestamp(
                    word: token,
                    startTime: Double(tokenData.t0) / 100.0,
                    endTime: Double(tokenData.t1) / 100.0,
                    confidence: tokenData.p
                )
                words.append(word)
            }
        }
        
        return words
    }
    
    private func getModelPath(modelName: String, allowDownload: Bool) throws -> String {
        // First, check if model exists in app bundle
        if let bundlePath = Bundle.main.path(forResource: "ggml-\(modelName)", ofType: "bin") {
            return bundlePath
        }
        
        // Check documents directory
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let modelPath = documentsPath.appendingPathComponent("ggml-\(modelName).bin").path
        
        if FileManager.default.fileExists(atPath: modelPath) {
            return modelPath
        }
        
        if allowDownload {
            // TODO: Implement model download functionality
            // For now, throw an error if model is not found
            throw WhisperError.modelNotFound("Model \(modelName) not found. Please include it in the app bundle or implement download functionality.")
        } else {
            throw WhisperError.modelNotFound("Model \(modelName) not found and download is disabled.")
        }
    }
    
    private func getModelFileSize(modelName: String) -> Int {
        do {
            let modelPath = try getModelPath(modelName: modelName, allowDownload: false)
            let attributes = try FileManager.default.attributesOfItem(atPath: modelPath)
            return attributes[.size] as? Int ?? 0
        } catch {
            return 0
        }
    }
    
    private func getSupportedLanguages() -> [String] {
        // Return common language codes supported by Whisper
        return [
            "en", "zh", "de", "es", "ru", "ko", "fr", "ja", "pt", "tr", "pl", "ca", "nl", "ar", "sv", "it", "id", "hi", "fi", "vi", "he", "uk", "el", "ms", "cs", "ro", "da", "hu", "ta", "no", "th", "ur", "hr", "bg", "lt", "la", "mi", "ml", "cy", "sk", "te", "fa", "lv", "bn", "sr", "az", "sl", "kn", "et", "mk", "br", "eu", "is", "hy", "ne", "mn", "bs", "kk", "sq", "sw", "gl", "mr", "pa", "si", "km", "sn", "yo", "so", "af", "oc", "ka", "be", "tg", "sd", "gu", "am", "yi", "lo", "uz", "fo", "ht", "ps", "tk", "nn", "mt", "sa", "lb", "my", "bo", "tl", "mg", "as", "tt", "haw", "ln", "ha", "ba", "jw", "su"
        ]
    }
}

// MARK: - Data Models

public struct TranscribeFileOptions {
    let filePath: String
    let language: String?
    let wordTimestamps: Bool
    let translate: Bool
    let threadCount: Int?
    let maxContext: Int
    let beamSearch: Bool
    let suppressNonSpeechTokens: Bool
}

public struct LoadModelOptions {
    let modelName: String
    let useCoreML: Bool
    let allowDownload: Bool
}

public struct TranscribeResult {
    let text: String
    let segments: [TranscriptionSegment]
    let language: String
    let processingTime: Double
}

public struct TranscriptionSegment {
    let startTime: Double
    let endTime: Double
    let text: String
    let words: [WordTimestamp]?
}

public struct WordTimestamp {
    let word: String
    let startTime: Double
    let endTime: Double
    let confidence: Float
}

public struct ModelInfo {
    let modelName: String
    let isLoaded: Bool
    let usingCoreML: Bool
    let modelSize: Int
    let supportedLanguages: [String]
}

public struct IsSupportedResult {
    let supported: Bool
    let coreMLSupported: Bool
}

// MARK: - Error Types

public enum WhisperError: Error {
    case modelNotLoaded
    case fileNotFound
    case unsupportedFormat
    case insufficientMemory
    case modelLoadFailed(String)
    case modelNotFound(String)
    case transcriptionFailed(String)
}

extension WhisperError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .modelNotLoaded:
            return "No model is currently loaded. Please load a model first."
        case .fileNotFound:
            return "The specified audio file could not be found."
        case .unsupportedFormat:
            return "The audio file format is not supported."
        case .insufficientMemory:
            return "Insufficient memory to process the audio file."
        case .modelLoadFailed(let message):
            return "Failed to load model: \(message)"
        case .modelNotFound(let message):
            return "Model not found: \(message)"
        case .transcriptionFailed(let message):
            return "Transcription failed: \(message)"
        }
    }
}