import Foundation

enum BestBeforeStatus: String, Codable {
    case none
    case fresh
    case approaching
    case expired
}

struct ContainerRecord: Identifiable, Codable, Hashable {
    let id: UUID
    let tagID: String
    var foodName: String
    var foodCategory: FoodCategory?
    var dateFrozen: Date
    var notes: String?
    var bestBeforeDate: Date?
    var isCleared: Bool
    let createdAt: Date
    var updatedAt: Date
    
    init(
        id: UUID = UUID(),
        tagID: String,
        foodName: String,
        foodCategory: FoodCategory? = nil,
        dateFrozen: Date,
        notes: String? = nil,
        bestBeforeDate: Date? = nil,
        isCleared: Bool = false,
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.tagID = tagID
        self.foodName = foodName
        self.foodCategory = foodCategory
        self.dateFrozen = dateFrozen
        self.notes = notes
        self.bestBeforeDate = bestBeforeDate
        self.isCleared = isCleared
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
    
    var isValid: Bool {
        guard !tagID.isEmpty, !foodName.isEmpty else {
            return false
        }
        
        if let notes = notes, notes.count > 200 {
            return false
        }
        
        return true
    }
    
    var formattedDateFrozen: String {
        formattedDateFrozen(in: .english)
    }
    
    var daysFrozen: Int {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.day], from: dateFrozen, to: Date())
        return components.day ?? 0
    }
    
    var daysFrozenDescription: String {
        daysFrozenDescription(in: .english)
    }
    
    var formattedBestBeforeDate: String? {
        formattedBestBeforeDate(in: .english)
    }

    func formattedBestBeforeDate(in language: AppLanguage) -> String? {
        guard let bestBeforeDate = bestBeforeDate else {
            return nil
        }
        return language.strings.dateString(bestBeforeDate)
    }
    
    var daysUntilBestBefore: Int? {
        guard let bestBeforeDate = bestBeforeDate else {
            return nil
        }
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let targetDate = calendar.startOfDay(for: bestBeforeDate)
        let components = calendar.dateComponents([.day], from: today, to: targetDate)
        return components.day ?? 0
    }
    
    var bestBeforeStatus: BestBeforeStatus {
        guard let daysUntil = daysUntilBestBefore else {
            return .none
        }
        
        if daysUntil < 0 {
            return .expired
        } else if daysUntil <= 7 {
            return .approaching
        } else {
            return .fresh
        }
    }

    func formattedDateFrozen(in language: AppLanguage) -> String {
        language.strings.frozenOn(dateFrozen)
    }

    func daysFrozenDescription(in language: AppLanguage) -> String {
        language.strings.daysFrozenDescription(daysFrozen)
    }

    func spokenSummary(
        in language: AppLanguage = .english,
        relativeTo referenceDate: Date = Date(),
        calendar: Calendar = .current
    ) -> String {
        let strings = language.strings
        var components = [foodName]

        if let foodCategory {
            components.append(strings.foodTypeSummary(foodCategory))
        }

        components.append(strings.frozenSummary(dateFrozen, referenceDate: referenceDate, calendar: calendar))

        if let bestBeforeDate {
            components.append(strings.bestQualitySummary(bestBeforeDate))
        } else {
            components.append(strings.noBestQualityDateSet)
        }

        if let notes {
            let trimmedNotes = notes.trimmingCharacters(in: .whitespacesAndNewlines)
            if !trimmedNotes.isEmpty {
                components.append(strings.notesSummary(trimmedNotes))
            }
        }

        return components.joined(separator: ". ") + "."
    }
}
