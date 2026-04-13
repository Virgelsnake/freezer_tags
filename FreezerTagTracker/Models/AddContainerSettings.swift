import Foundation

struct AddContainerSettings: Codable, Equatable {
    var spokenGuidanceEnabled: Bool
    var spokenConfirmationsEnabled: Bool
    var hapticsEnabled: Bool
    var microphoneShortcutEnabled: Bool
    var showReadDetailsAgainButton: Bool
    var language: AppLanguage
    var presetOverrides: [FoodCategory: Int]

    init(
        spokenGuidanceEnabled: Bool = true,
        spokenConfirmationsEnabled: Bool = true,
        hapticsEnabled: Bool = true,
        microphoneShortcutEnabled: Bool = true,
        showReadDetailsAgainButton: Bool = true,
        language: AppLanguage = .english,
        presetOverrides: [FoodCategory: Int] = [:]
    ) {
        self.spokenGuidanceEnabled = spokenGuidanceEnabled
        self.spokenConfirmationsEnabled = spokenConfirmationsEnabled
        self.hapticsEnabled = hapticsEnabled
        self.microphoneShortcutEnabled = microphoneShortcutEnabled
        self.showReadDetailsAgainButton = showReadDetailsAgainButton
        self.language = language
        self.presetOverrides = presetOverrides
    }

    private enum CodingKeys: String, CodingKey {
        case spokenGuidanceEnabled
        case spokenConfirmationsEnabled
        case hapticsEnabled
        case microphoneShortcutEnabled
        case showReadDetailsAgainButton
        case language
        case presetOverrides
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        spokenGuidanceEnabled = try container.decodeIfPresent(Bool.self, forKey: .spokenGuidanceEnabled) ?? true
        spokenConfirmationsEnabled = try container.decodeIfPresent(Bool.self, forKey: .spokenConfirmationsEnabled) ?? true
        hapticsEnabled = try container.decodeIfPresent(Bool.self, forKey: .hapticsEnabled) ?? true
        microphoneShortcutEnabled = try container.decodeIfPresent(Bool.self, forKey: .microphoneShortcutEnabled) ?? true
        showReadDetailsAgainButton = try container.decodeIfPresent(Bool.self, forKey: .showReadDetailsAgainButton) ?? true
        language = try container.decodeIfPresent(AppLanguage.self, forKey: .language) ?? .english
        presetOverrides = try container.decodeIfPresent([FoodCategory: Int].self, forKey: .presetOverrides) ?? [:]
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(spokenGuidanceEnabled, forKey: .spokenGuidanceEnabled)
        try container.encode(spokenConfirmationsEnabled, forKey: .spokenConfirmationsEnabled)
        try container.encode(hapticsEnabled, forKey: .hapticsEnabled)
        try container.encode(microphoneShortcutEnabled, forKey: .microphoneShortcutEnabled)
        try container.encode(showReadDetailsAgainButton, forKey: .showReadDetailsAgainButton)
        try container.encode(language, forKey: .language)
        try container.encode(presetOverrides, forKey: .presetOverrides)
    }
}
