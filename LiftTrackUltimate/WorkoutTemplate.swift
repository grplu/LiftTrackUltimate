import Foundation

struct WorkoutTemplate: Identifiable, Codable, Equatable {
    var id = UUID()
    var name: String
    var exercises: [TemplateExercise]
    
    // Add Equatable implementation
    static func == (lhs: WorkoutTemplate, rhs: WorkoutTemplate) -> Bool {
        return lhs.id == rhs.id &&
               lhs.name == rhs.name &&
               lhs.exercises == rhs.exercises
    }
}

struct TemplateExercise: Identifiable, Codable, Equatable {
    var id = UUID()
    var exercise: Exercise
    var targetSets: Int
    var targetReps: Int?
    
    // Add Equatable implementation
    static func == (lhs: TemplateExercise, rhs: TemplateExercise) -> Bool {
        return lhs.id == rhs.id &&
               lhs.exercise == rhs.exercise &&
               lhs.targetSets == rhs.targetSets &&
               lhs.targetReps == rhs.targetReps
    }
}
