import Foundation

struct Exercise: Identifiable, Codable, Equatable {
    var id = UUID()
    var name: String
    var category: String
    var muscleGroups: [String]
    var instructions: String?
    var isFavorite: Bool = false
    var equipment: String?
    
    // Add Equatable implementation
    static func == (lhs: Exercise, rhs: Exercise) -> Bool {
        return lhs.id == rhs.id &&
               lhs.name == rhs.name &&
               lhs.category == rhs.category &&
               lhs.muscleGroups == rhs.muscleGroups &&
               lhs.instructions == rhs.instructions &&
               lhs.isFavorite == rhs.isFavorite &&
               lhs.equipment == rhs.equipment
    }
    
    // Toggle favorite status
    mutating func toggleFavorite() {
        isFavorite.toggle()
    }
} 