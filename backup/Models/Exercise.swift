import Foundation

public struct Exercise: Identifiable, Codable, Equatable {
    public var id = UUID()
    public var name: String
    public var category: String
    public var muscleGroups: [String]
    public var instructions: String?
    public var isFavorite: Bool = false
    public var equipment: String?
    
    // Add Equatable implementation
    public static func == (lhs: Exercise, rhs: Exercise) -> Bool {
        return lhs.id == rhs.id &&
               lhs.name == rhs.name &&
               lhs.category == rhs.category &&
               lhs.muscleGroups == rhs.muscleGroups &&
               lhs.instructions == rhs.instructions &&
               lhs.isFavorite == rhs.isFavorite &&
               lhs.equipment == rhs.equipment
    }
    
    // Toggle favorite status
    public mutating func toggleFavorite() {
        isFavorite.toggle()
    }
    
    // Initializer with default values
    public init(id: UUID = UUID(), name: String, category: String, muscleGroups: [String], instructions: String? = nil, isFavorite: Bool = false, equipment: String? = nil) {
        self.id = id
        self.name = name
        self.category = category
        self.muscleGroups = muscleGroups
        self.instructions = instructions
        self.isFavorite = isFavorite
        self.equipment = equipment
    }
} 