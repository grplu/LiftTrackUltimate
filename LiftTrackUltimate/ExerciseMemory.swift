import Foundation

struct ExerciseMemory: Codable, Hashable, Identifiable {
    var id: UUID
    var exerciseId: UUID
    var reps: Int
    var sets: Int
    var weight: Double?
    var lastUsed: Date
    
    // Additional properties for tracking last performance
    var lastReps: Int?
    var lastSets: Int?
    var lastWeight: Double?
    var lastPerformanceDate: Date?
    
    enum CodingKeys: String, CodingKey {
        case id
        case exerciseId
        case reps
        case sets
        case weight
        case lastUsed
        case lastReps
        case lastSets
        case lastWeight
        case lastPerformanceDate
    }
    
    init(exerciseId: UUID, reps: Int = 10, sets: Int = 3, weight: Double? = nil) {
        self.id = UUID()
        self.exerciseId = exerciseId
        self.reps = reps
        self.sets = sets
        self.weight = weight
        self.lastUsed = Date()
        
        // Initialize last performance properties
        self.lastReps = reps
        self.lastSets = sets
        self.lastWeight = weight
        self.lastPerformanceDate = Date()
    }
    
    // Method to update memory
    mutating func update(reps: Int? = nil, sets: Int? = nil, weight: Double? = nil) {
        if let newReps = reps {
            self.reps = newReps
            self.lastReps = newReps
        }
        if let newSets = sets {
            self.sets = newSets
            self.lastSets = newSets
        }
        if let newWeight = weight {
            self.weight = newWeight
            self.lastWeight = newWeight
        }
        
        self.lastUsed = Date()
        self.lastPerformanceDate = Date()
    }
}
