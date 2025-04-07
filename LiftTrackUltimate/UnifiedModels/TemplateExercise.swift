import Foundation

// Using `targetWeight` and `notes` as properties, for consistency across the app
public struct TemplateExercise: Identifiable, Equatable {
    public var id = UUID()
    public var exercise: Exercise
    public var targetSets: Int
    public var targetReps: Int?
    public var targetWeight: Double?
    public var notes: String?
    
    // Equatable implementation
    public static func == (lhs: TemplateExercise, rhs: TemplateExercise) -> Bool {
        return lhs.id == rhs.id &&
               lhs.exercise == rhs.exercise &&
               lhs.targetSets == rhs.targetSets &&
               lhs.targetReps == rhs.targetReps &&
               lhs.targetWeight == rhs.targetWeight &&
               lhs.notes == rhs.notes
    }
    
    // Initialization with default values
    public init(exercise: Exercise, targetSets: Int = 3, targetReps: Int? = 10, targetWeight: Double? = nil, notes: String? = nil) {
        self.id = UUID()
        self.exercise = exercise
        self.targetSets = targetSets
        self.targetReps = targetReps
        self.targetWeight = targetWeight
        self.notes = notes
    }
    
    // Initialize with id for compatibility
    public init(id: UUID = UUID(), exercise: Exercise, targetSets: Int, targetReps: Int?) {
        self.id = id
        self.exercise = exercise
        self.targetSets = targetSets
        self.targetReps = targetReps
        self.targetWeight = nil
        self.notes = nil
    }
}

// MARK: - Codable Implementation
extension TemplateExercise: Codable {
    enum CodingKeys: String, CodingKey {
        case id, exercise, targetSets, targetReps, targetWeight, notes
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        id = try container.decode(UUID.self, forKey: .id)
        exercise = try container.decode(Exercise.self, forKey: .exercise)
        targetSets = try container.decode(Int.self, forKey: .targetSets)
        targetReps = try container.decodeIfPresent(Int.self, forKey: .targetReps)
        targetWeight = try container.decodeIfPresent(Double.self, forKey: .targetWeight)
        notes = try container.decodeIfPresent(String.self, forKey: .notes)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(id, forKey: .id)
        try container.encode(exercise, forKey: .exercise)
        try container.encode(targetSets, forKey: .targetSets)
        try container.encodeIfPresent(targetReps, forKey: .targetReps)
        try container.encodeIfPresent(targetWeight, forKey: .targetWeight)
        try container.encodeIfPresent(notes, forKey: .notes)
    }
} 