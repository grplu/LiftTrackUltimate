import Foundation

struct Exercise: Identifiable, Codable {
    var id = UUID()
    var name: String
    var category: String
    var muscleGroups: [String]
    var instructions: String?
    
    // Method to get memory for this exercise from UserProfile
    func getMemory(from profile: UserProfile) -> ExerciseMemory? {
        return profile.exerciseMemory.first { $0.exerciseId == self.id }
    }
}
