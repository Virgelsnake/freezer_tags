import AVFoundation
import Foundation
import Speech

@MainActor
final class SpeechToTextRecognizer: ObservableObject {
    struct Copy {
        let idleButtonTitle: String
        let listeningStatusMessage: String
        let speechPermissionMessage: String
        let microphonePermissionMessage: String
        let uiTestTranscriptEnvironmentKey: String
    }

    @Published private(set) var isListening = false
    @Published private(set) var statusMessage: String?
    @Published private(set) var isShowingError = false

    let copy: Copy

    var buttonTitle: String {
        isListening ? "Stop listening" : copy.idleButtonTitle
    }

    var buttonSystemImage: String {
        isListening ? "waveform.circle.fill" : "mic.fill"
    }

    private let speechRecognizer: SFSpeechRecognizer?
    private let audioEngine: AVAudioEngine
    private let audioSession: AVAudioSession
    private let environment: [String: String]

    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private var activeSessionID: UUID?

    private enum SpeechRecognitionError: LocalizedError {
        case microphoneInputUnavailable

        var errorDescription: String? {
            switch self {
            case .microphoneInputUnavailable:
                return "Microphone input is unavailable right now. Please try again on your iPhone."
            }
        }
    }

    init(
        copy: Copy,
        speechRecognizer: SFSpeechRecognizer? = SFSpeechRecognizer(locale: Locale.current),
        audioEngine: AVAudioEngine = AVAudioEngine(),
        audioSession: AVAudioSession = .sharedInstance(),
        environment: [String: String] = ProcessInfo.processInfo.environment
    ) {
        self.copy = copy
        self.speechRecognizer = speechRecognizer
        self.audioEngine = audioEngine
        self.audioSession = audioSession
        self.environment = environment
    }

    func toggleListening(onTranscription: @escaping (String) -> Void) {
        if isListening {
            stopListening()
            return
        }

        if let testTranscript = environment[copy.uiTestTranscriptEnvironmentKey], !testTranscript.isEmpty {
            statusMessage = nil
            isShowingError = false
            onTranscription(testTranscript)
            return
        }

        Task {
            await startListening(onTranscription: onTranscription)
        }
    }

    func stopListening() {
        activeSessionID = nil
        recognitionTask?.cancel()
        recognitionTask = nil
        recognitionRequest?.endAudio()
        recognitionRequest = nil

        if audioEngine.isRunning {
            audioEngine.stop()
        }

        audioEngine.inputNode.removeTap(onBus: 0)

        do {
            try audioSession.setActive(false, options: [.notifyOthersOnDeactivation])
        } catch {
            // No-op: a failed deactivation should not block the UI from recovering.
        }

        isListening = false

        if !isShowingError {
            statusMessage = nil
        }
    }

    private func startListening(onTranscription: @escaping (String) -> Void) async {
        guard speechRecognizer != nil else {
            presentError("Speech recognition is unavailable on this device.")
            return
        }

        statusMessage = "Preparing microphone..."
        isShowingError = false

        let speechAuthorization = await requestSpeechAuthorization()

        guard speechAuthorization == .authorized else {
            presentError(copy.speechPermissionMessage)
            return
        }

        let microphoneAuthorized = await requestRecordPermission()

        guard microphoneAuthorized else {
            presentError(copy.microphonePermissionMessage)
            return
        }

        do {
            try startRecognitionSession(onTranscription: onTranscription)
        } catch {
            let message = (error as? LocalizedError)?.errorDescription ?? "We couldn't start listening right now. Please try again."
            presentError(message)
        }
    }

    private func startRecognitionSession(onTranscription: @escaping (String) -> Void) throws {
        stopListening()

        try audioSession.setCategory(.record, mode: .measurement, options: [.duckOthers])
        try audioSession.setActive(true, options: .notifyOthersOnDeactivation)

        let request = SFSpeechAudioBufferRecognitionRequest()
        request.shouldReportPartialResults = true
        recognitionRequest = request
        let sessionID = UUID()
        activeSessionID = sessionID

        let inputNode = audioEngine.inputNode
        let format = try recordingFormat(for: inputNode)
        inputNode.removeTap(onBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1_024, format: format) { [weak request] buffer, _ in
            request?.append(buffer)
        }

        audioEngine.prepare()
        try audioEngine.start()

        isListening = true
        statusMessage = copy.listeningStatusMessage
        isShowingError = false

        recognitionTask = speechRecognizer?.recognitionTask(with: request) { [weak self] result, error in
            guard let self else {
                return
            }

            Task { @MainActor in
                guard self.activeSessionID == sessionID else {
                    return
                }

                if let result {
                    onTranscription(result.bestTranscription.formattedString)
                }

                if let error {
                    self.presentError(error.localizedDescription)
                    return
                }

                if result?.isFinal == true {
                    self.stopListening()
                }
            }
        }
    }

    private func presentError(_ message: String) {
        stopListening()
        statusMessage = message
        isShowingError = true
    }

    private func recordingFormat(for inputNode: AVAudioInputNode) throws -> AVAudioFormat {
        let candidateFormats = [
            inputNode.inputFormat(forBus: 0),
            inputNode.outputFormat(forBus: 0)
        ]

        guard let validFormat = candidateFormats.first(where: Self.isValidRecordingFormat) else {
            throw SpeechRecognitionError.microphoneInputUnavailable
        }

        return validFormat
    }

    private static func isValidRecordingFormat(_ format: AVAudioFormat) -> Bool {
        format.sampleRate > 0 && format.channelCount > 0
    }

    private func requestSpeechAuthorization() async -> SFSpeechRecognizerAuthorizationStatus {
        await withCheckedContinuation { continuation in
            SFSpeechRecognizer.requestAuthorization { status in
                continuation.resume(returning: status)
            }
        }
    }

    private func requestRecordPermission() async -> Bool {
        await withCheckedContinuation { continuation in
            audioSession.requestRecordPermission { granted in
                continuation.resume(returning: granted)
            }
        }
    }
}

extension SpeechToTextRecognizer.Copy {
    static let foodName = Self(
        idleButtonTitle: "Speak food name",
        listeningStatusMessage: "Listening for food name.",
        speechPermissionMessage: "Allow speech recognition in Settings to use Speak food name.",
        microphonePermissionMessage: "Allow microphone access in Settings to use Speak food name.",
        uiTestTranscriptEnvironmentKey: "UITEST_SPOKEN_FOOD_NAME"
    )

    static let notes = Self(
        idleButtonTitle: "Speak to add note",
        listeningStatusMessage: "Listening for note.",
        speechPermissionMessage: "Allow speech recognition in Settings to use Speak to add note.",
        microphonePermissionMessage: "Allow microphone access in Settings to use Speak to add note.",
        uiTestTranscriptEnvironmentKey: "UITEST_SPOKEN_NOTE"
    )
}
