import Foundation

struct ExercisePerformance: Identifiable, Codable {
    let id: UUID
    let exerciseId: UUID
    var lastUsedReps: Int
    var lastUsedWeight: Double?
    var totalSets: Int
    var lastUsed: Date
    
    init(exerciseId: UUID, reps: Int, weight: Double? = nil, sets: Int = 3) {
        self.id = UUID()
        self.exerciseId = exerciseId
        self.lastUsedReps = reps
        self.lastUsedWeight = weight
        self.totalSets = sets
        self.lastUsed = Date()
    }
    
    // Method to update performance
    mutating func updatePerformance(reps: Int, weight: Double? = nil, sets: Int? = nil) {
        self.lastUsedReps = reps
        self.lastUsedWeight = weight
        if let sets = sets {
            self.totalSets = sets
        }
        self.lastUsed = Date()
    }
}
