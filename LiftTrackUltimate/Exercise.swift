import Foundation

struct Exercise: Identifiable, Codable, Equatable {
    var id = UUID()
    var name: String
    var category: String
    var muscleGroups: [String]
    var instructions: String?
    
    // Add Equatable implementation
    static func == (lhs: Exercise, rhs: Exercise) -> Bool {
        return lhs.id == rhs.id &&
               lhs.name == rhs.name &&
               lhs.category == rhs.category &&
               lhs.muscleGroups == rhs.muscleGroups &&
               lhs.instructions == rhs.instructions
    }
    
    // Method to get memory for this exercise from UserProfile
    func getMemory(from profile: UserProfile) -> ExerciseMemory? {
        return profile.exerciseMemory.first { $0.exerciseId == self.id }
    }
}
