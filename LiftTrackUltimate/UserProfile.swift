import Foundation

struct UserProfile: Codable {
    var id = UUID()
    var name: String
    var fitnessGoal: String
    
    // Add any other user profile information here
    var height: Double?
    var weight: Double?
    var birthDate: Date?
    
    // Exercise memory for each exercise
    var exerciseMemory: [ExerciseMemory] = []
    
    // Helper property for easier access
    var exerciseMemories: [ExerciseMemory] {
        return exerciseMemory
    }
    
    // Coding keys for encoder/decoder
    enum CodingKeys: String, CodingKey {
        case id, name, fitnessGoal, height, weight, birthDate, exerciseMemory
    }
    
    // Manual implementation of Codable protocol
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        fitnessGoal = try container.decode(String.self, forKey: .fitnessGoal)
        height = try container.decodeIfPresent(Double.self, forKey: .height)
        weight = try container.decodeIfPresent(Double.self, forKey: .weight)
        birthDate = try container.decodeIfPresent(Date.self, forKey: .birthDate)
        exerciseMemory = try container.decodeIfPresent([ExerciseMemory].self, forKey: .exerciseMemory) ?? []
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encode(fitnessGoal, forKey: .fitnessGoal)
        try container.encodeIfPresent(height, forKey: .height)
        try container.encodeIfPresent(weight, forKey: .weight)
        try container.encodeIfPresent(birthDate, forKey: .birthDate)
        try container.encode(exerciseMemory, forKey: .exerciseMemory)
    }
    
    // Standard initializer
    init(name: String, fitnessGoal: String) {
        self.name = name
        self.fitnessGoal = fitnessGoal
    }
    
    // Function to update exercise memory
    mutating func updateExerciseMemory(exerciseId: UUID, reps: Int?, sets: Int?, weight: Double?) {
        // Find index of existing memory for this exercise
        if let index = exerciseMemory.firstIndex(where: { $0.exerciseId == exerciseId }) {
            // Update existing memory
            var updatedMemory = exerciseMemory[index]
            updatedMemory.reps = reps ?? updatedMemory.reps
            updatedMemory.sets = sets ?? updatedMemory.sets
            updatedMemory.weight = weight ?? updatedMemory.weight
            updatedMemory.lastUsed = Date()
            updatedMemory.lastReps = reps
            updatedMemory.lastSets = sets
            updatedMemory.lastWeight = weight
            updatedMemory.lastPerformanceDate = Date()
            exerciseMemory[index] = updatedMemory
        } else {
            // Add new memory
            exerciseMemory.append(
                ExerciseMemory(
                    exerciseId: exerciseId,
                    reps: reps ?? 10,
                    sets: sets ?? 3,
                    weight: weight
                )
            )
        }
    }
}
