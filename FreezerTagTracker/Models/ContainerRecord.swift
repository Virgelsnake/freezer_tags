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
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return "Frozen on \(formatter.string(from: dateFrozen))"
    }
    
    var daysFrozen: Int {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.day], from: dateFrozen, to: Date())
        return components.day ?? 0
    }
    
    var daysFrozenDescription: String {
        let days = daysFrozen
        if days == 0 {
            return "Frozen today"
        } else if days == 1 {
            return "1 day ago"
        } else {
            return "\(days) days ago"
        }
    }
    
    var formattedBestBeforeDate: String? {
        guard let bestBeforeDate = bestBeforeDate else {
            return nil
        }
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: bestBeforeDate)
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

    func spokenSummary(
        relativeTo referenceDate: Date = Date(),
        calendar: Calendar = .current
    ) -> String {
        var components = [foodName]

        if let foodCategory {
            components.append("Food type \(foodCategory.displayName)")
        }

        let frozenText: String
        if calendar.isDate(dateFrozen, inSameDayAs: referenceDate) {
            frozenText = "Frozen today"
        } else {
            frozenText = "Frozen \(Self.summaryDateFormatter.string(from: dateFrozen))"
        }
        components.append(frozenText)

        if let bestBeforeDate {
            components.append("Best quality by \(Self.summaryDateFormatter.string(from: bestBeforeDate))")
        } else {
            components.append("No best-quality date set")
        }

        if let notes {
            let trimmedNotes = notes.trimmingCharacters(in: .whitespacesAndNewlines)
            if !trimmedNotes.isEmpty {
                components.append("Notes: \(trimmedNotes)")
            }
        }

        return components.joined(separator: ". ") + "."
    }

    private static let summaryDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter
    }()
}
