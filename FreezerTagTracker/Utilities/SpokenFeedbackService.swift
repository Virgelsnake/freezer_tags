import AVFoundation
import Foundation

protocol SpokenFeedbackServing {
    func speak(_ message: String)
}

final class SpokenFeedbackService: NSObject, SpokenFeedbackServing {
    private let synthesizer: AVSpeechSynthesizer
    private let audioSession: AVAudioSession

    init(
        synthesizer: AVSpeechSynthesizer = AVSpeechSynthesizer(),
        audioSession: AVAudioSession = .sharedInstance()
    ) {
        self.synthesizer = synthesizer
        self.audioSession = audioSession
        super.init()
        self.synthesizer.delegate = self
    }

    func speak(_ message: String) {
        guard !message.isEmpty else {
            return
        }

        activateAudioSession()

        if synthesizer.isSpeaking {
            synthesizer.stopSpeaking(at: .immediate)
        }

        let utterance = AVSpeechUtterance(string: message)
        utterance.rate = AVSpeechUtteranceDefaultSpeechRate
        utterance.voice = AVSpeechSynthesisVoice(language: Locale.current.identifier)
        synthesizer.speak(utterance)
    }

    private func activateAudioSession() {
        do {
            try audioSession.setCategory(.playback, mode: .spokenAudio, options: [.duckOthers])
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        } catch {
            // If activation fails, still attempt to speak so the UI is not blocked.
        }
    }

    private func deactivateAudioSessionIfIdle() {
        guard !synthesizer.isSpeaking else {
            return
        }

        do {
            try audioSession.setActive(false, options: [.notifyOthersOnDeactivation])
        } catch {
            // No-op: cleanup failure should not affect app behavior.
        }
    }
}

extension SpokenFeedbackService: AVSpeechSynthesizerDelegate {
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        deactivateAudioSessionIfIdle()
    }

    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didCancel utterance: AVSpeechUtterance) {
        deactivateAudioSessionIfIdle()
    }
}
