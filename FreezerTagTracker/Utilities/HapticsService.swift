import Foundation
import UIKit

enum HapticsEvent: Equatable {
    case presetSelection
    case primaryAction
    case writeStart
    case writeSuccess
    case writeFailure
    case validationError
    case replayDetails
}

protocol HapticsServing {
    func play(_ event: HapticsEvent)
}

final class HapticsService: HapticsServing {
    func play(_ event: HapticsEvent) {
        let perform = {
            switch event {
            case .presetSelection, .primaryAction, .replayDetails:
                UIImpactFeedbackGenerator(style: .light).impactOccurred()
            case .writeStart:
                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
            case .writeSuccess:
                UINotificationFeedbackGenerator().notificationOccurred(.success)
            case .writeFailure:
                UINotificationFeedbackGenerator().notificationOccurred(.error)
            case .validationError:
                UINotificationFeedbackGenerator().notificationOccurred(.warning)
            }
        }

        if Thread.isMainThread {
            perform()
        } else {
            DispatchQueue.main.async(execute: perform)
        }
    }
}
