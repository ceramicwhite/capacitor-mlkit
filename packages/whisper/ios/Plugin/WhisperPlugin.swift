import Foundation
import Capacitor
import AVFoundation

/**
 * Please read the Capacitor iOS Plugin Development Guide
 * here: https://capacitorjs.com/docs/plugins/ios
 */
@objc(WhisperPlugin)
public class WhisperPlugin: CAPPlugin, CAPBridgedPlugin {
    public let identifier = "WhisperPlugin"
    public let jsName = "Whisper"
    public let pluginMethods: [CAPPluginMethod] = [
        CAPPluginMethod(name: "transcribeFile", returnType: CAPPluginReturnPromise),
        CAPPluginMethod(name: "loadModel", returnType: CAPPluginReturnPromise),
        CAPPluginMethod(name: "unloadModel", returnType: CAPPluginReturnPromise),
        CAPPluginMethod(name: "getModelInfo", returnType: CAPPluginReturnPromise),
        CAPPluginMethod(name: "isSupported", returnType: CAPPluginReturnPromise),
        CAPPluginMethod(name: "checkPermissions", returnType: CAPPluginReturnPromise),
        CAPPluginMethod(name: "requestPermissions", returnType: CAPPluginReturnPromise)
    ]
    
    private let implementation = Whisper()

    override public func load() {
        // Initialize the Whisper implementation
        implementation.initialize()
    }

    @objc func transcribeFile(_ call: CAPPluginCall) {
        guard let filePath = call.getString("filePath") else {
            call.reject("Must provide a file path")
            return
        }

        let language = call.getString("language")
        let wordTimestamps = call.getBool("wordTimestamps", false)
        let translate = call.getBool("translate", false)
        let threadCount = call.getInt("threadCount")
        let maxContext = call.getInt("maxContext", 224)
        let beamSearch = call.getBool("beamSearch", false)
        let suppressNonSpeechTokens = call.getBool("suppressNonSpeechTokens", true)

        let options = TranscribeFileOptions(
            filePath: filePath,
            language: language,
            wordTimestamps: wordTimestamps,
            translate: translate,
            threadCount: threadCount,
            maxContext: maxContext,
            beamSearch: beamSearch,
            suppressNonSpeechTokens: suppressNonSpeechTokens
        )

        // Perform transcription on background queue
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else { return }
            
            do {
                let result = try self.implementation.transcribeFile(options: options)
                
                DispatchQueue.main.async {
                    call.resolve([
                        "text": result.text,
                        "segments": result.segments.map { segment in
                            var segmentDict: [String: Any] = [
                                "startTime": segment.startTime,
                                "endTime": segment.endTime,
                                "text": segment.text
                            ]
                            
                            if let words = segment.words {
                                segmentDict["words"] = words.map { word in
                                    [
                                        "word": word.word,
                                        "startTime": word.startTime,
                                        "endTime": word.endTime,
                                        "confidence": word.confidence
                                    ]
                                }
                            }
                            
                            return segmentDict
                        },
                        "language": result.language,
                        "processingTime": result.processingTime
                    ])
                }
            } catch {
                DispatchQueue.main.async {
                    call.reject("Transcription failed: \(error.localizedDescription)")
                }
            }
        }
    }

    @objc func loadModel(_ call: CAPPluginCall) {
        guard let modelName = call.getString("modelName") else {
            call.reject("Must provide a model name")
            return
        }

        let useCoreML = call.getBool("useCoreML", true)
        let allowDownload = call.getBool("allowDownload", true)

        let options = LoadModelOptions(
            modelName: modelName,
            useCoreML: useCoreML,
            allowDownload: allowDownload
        )

        // Load model on background queue
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else { return }
            
            do {
                try self.implementation.loadModel(options: options)
                
                DispatchQueue.main.async {
                    call.resolve()
                }
            } catch {
                DispatchQueue.main.async {
                    call.reject("Model loading failed: \(error.localizedDescription)")
                }
            }
        }
    }

    @objc func unloadModel(_ call: CAPPluginCall) {
        implementation.unloadModel()
        call.resolve()
    }

    @objc func getModelInfo(_ call: CAPPluginCall) {
        let modelInfo = implementation.getModelInfo()
        
        call.resolve([
            "modelName": modelInfo.modelName,
            "isLoaded": modelInfo.isLoaded,
            "usingCoreML": modelInfo.usingCoreML,
            "modelSize": modelInfo.modelSize,
            "supportedLanguages": modelInfo.supportedLanguages
        ])
    }

    @objc func isSupported(_ call: CAPPluginCall) {
        let supportInfo = implementation.isSupported()
        
        call.resolve([
            "supported": supportInfo.supported,
            "coreMLSupported": supportInfo.coreMLSupported
        ])
    }

    @objc func checkPermissions(_ call: CAPPluginCall) {
        let microphoneStatus = AVAudioSession.sharedInstance().recordPermission
        let permission: String
        
        switch microphoneStatus {
        case .granted:
            permission = "granted"
        case .denied:
            permission = "denied"
        case .undetermined:
            permission = "prompt"
        @unknown default:
            permission = "prompt"
        }
        
        call.resolve([
            "microphone": permission
        ])
    }

    @objc func requestPermissions(_ call: CAPPluginCall) {
        AVAudioSession.sharedInstance().requestRecordPermission { granted in
            DispatchQueue.main.async {
                call.resolve([
                    "microphone": granted ? "granted" : "denied"
                ])
            }
        }
    }
}