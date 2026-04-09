import Foundation
import UIKit

protocol AccessibilityAnnouncementServing {
    func announce(_ message: String)
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
    func announce(_ message: String) {
        guard !message.isEmpty else {
            return
        }

        UIAccessibility.post(notification: .announcement, argument: message)
    }
}
