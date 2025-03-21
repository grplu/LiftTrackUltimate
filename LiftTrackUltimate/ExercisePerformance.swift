import Foundation

struct ExercisePerformance: Codable, Identifiable {
    var id = UUID()
    var exerciseId: UUID
    var date: Date = Date()
    
    // Average performance metrics (used for tracking progress)
    var avgReps: Int?
    var avgWeight: Double?
    var totalSets: Int
    
    // Last set values (used for pre-filling new workouts)
    var lastUsedReps: Int?
    var lastUsedWeight: Double?
    
    // Array of individual set weights to remember per-set weights
    var setWeights: [Double?]
    var setReps: [Int?]
    
    init(exerciseId: UUID, reps: Int? = nil, weight: Double? = nil, sets: Int = 0) {
        self.exerciseId = exerciseId
        self.avgReps = reps
        self.avgWeight = weight
        self.totalSets = sets
        self.lastUsedReps = reps
        self.lastUsedWeight = weight
        self.setWeights = []
        self.setReps = []
    }
    
    // Computed properties for convenience
    var lastUsedWeights: [Double?] {
        return setWeights.isEmpty ? [lastUsedWeight] : setWeights
    }
    
    var lastUsedRepCounts: [Int?] {
        return setReps.isEmpty ? [lastUsedReps] : setReps
    }
}
