import Foundation

struct AddContainerSettings: Codable, Equatable {
    var spokenGuidanceEnabled: Bool
    var spokenConfirmationsEnabled: Bool
    var hapticsEnabled: Bool
    var microphoneShortcutEnabled: Bool
    var showReadDetailsAgainButton: Bool
    var presetOverrides: [FoodCategory: Int]

    init(
        spokenGuidanceEnabled: Bool = true,
        spokenConfirmationsEnabled: Bool = true,
        hapticsEnabled: Bool = true,
        microphoneShortcutEnabled: Bool = true,
        showReadDetailsAgainButton: Bool = true,
        presetOverrides: [FoodCategory: Int] = [:]
    ) {
        self.spokenGuidanceEnabled = spokenGuidanceEnabled
        self.spokenConfirmationsEnabled = spokenConfirmationsEnabled
        self.hapticsEnabled = hapticsEnabled
        self.microphoneShortcutEnabled = microphoneShortcutEnabled
        self.showReadDetailsAgainButton = showReadDetailsAgainButton
        self.presetOverrides = presetOverrides
    }
}
