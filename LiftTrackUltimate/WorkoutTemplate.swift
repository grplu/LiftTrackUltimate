import Foundation

struct WorkoutTemplate: Identifiable, Codable {
    var id = UUID()
    var name: String
    var exercises: [TemplateExercise]
}

struct TemplateExercise: Identifiable, Codable {
    var id = UUID()
    var exercise: Exercise
    var targetSets: Int
    var targetReps: Int?
}
