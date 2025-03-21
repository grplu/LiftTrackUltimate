import Foundation

struct ExerciseMemory: Codable, Hashable {
    let exerciseId: UUID
    var lastReps: Int?
    var lastSets: Int?
    var lastWeight: Double?
    var lastPerformanceDate: Date?
}

struct Exercise: Identifiable, Codable {
    var id = UUID()
    var name: String
    var category: String
    var muscleGroups: [String]
    var instructions: String?
    
    // Method to get memory for this exercise
    func getMemory(from profile: UserProfile) -> ExerciseMemory? {
        return profile.exerciseMemories.first { $0.exerciseId == self.id }
    }
}
