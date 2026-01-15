import Foundation

struct ContainerRecord: Identifiable, Codable, Hashable {
    let id: UUID
    let tagID: String
    var foodName: String
    var dateFrozen: Date
    var notes: String?
    var isCleared: Bool
    let createdAt: Date
    var updatedAt: Date
    
    init(
        id: UUID = UUID(),
        tagID: String,
        foodName: String,
        dateFrozen: Date,
        notes: String? = nil,
        isCleared: Bool = false,
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.tagID = tagID
        self.foodName = foodName
        self.dateFrozen = dateFrozen
        self.notes = notes
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
}
