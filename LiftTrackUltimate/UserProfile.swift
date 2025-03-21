import Foundation

struct UserProfile: Identifiable, Codable {
    var id = UUID()
    var name: String
    var age: Int?
    var weight: Double? // in kg
    var height: Double? // in cm
    var fitnessGoal: String
    var exerciseMemories: [ExerciseMemory] = []
    
    init(id: UUID = UUID(), name: String, age: Int? = nil, weight: Double? = nil, height: Double? = nil, fitnessGoal: String, exerciseMemories: [ExerciseMemory] = []) {
        self.id = id
        self.name = name
        self.age = age
        self.weight = weight
        self.height = height
        self.fitnessGoal = fitnessGoal
        self.exerciseMemories = exerciseMemories
    }
    
    // Method to update or add exercise memory
    mutating func updateExerciseMemory(exerciseId: UUID, reps: Int, sets: Int, weight: Double?) {
        // Find existing memory or create a new one
        if let index = exerciseMemories.firstIndex(where: { $0.exerciseId == exerciseId }) {
            exerciseMemories[index] = ExerciseMemory(
                exerciseId: exerciseId,
                lastReps: reps,
                lastSets: sets,
                lastWeight: weight,
                lastPerformanceDate: Date()
            )
        } else {
            exerciseMemories.append(
                ExerciseMemory(
                    exerciseId: exerciseId,
                    lastReps: reps,
                    lastSets: sets,
                    lastWeight: weight,
                    lastPerformanceDate: Date()
                )
            )
        }
    }
}
