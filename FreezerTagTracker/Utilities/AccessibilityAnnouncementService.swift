import Foundation
import UIKit

protocol AccessibilityAnnouncementServing {
    func announce(_ message: String, language: AppLanguage)
}

protocol AccessibilityStatusProviding {
    var isVoiceOverRunning: Bool { get }
}

struct SystemAccessibilityStatusProvider: AccessibilityStatusProviding {
    var isVoiceOverRunning: Bool {
        UIAccessibility.isVoiceOverRunning
    }
}

final class AccessibilityAnnouncementService: AccessibilityAnnouncementServing {
    func announce(_ message: String, language: AppLanguage) {
        guard !message.isEmpty else {
            return
        }

        let attributedMessage = NSAttributedString(
            string: message,
            attributes: [.accessibilitySpeechLanguage: language.speechIdentifier]
        )
        UIAccessibility.post(notification: .announcement, argument: attributedMessage)
    }
}
