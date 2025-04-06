import Foundation

struct WorkoutTemplate: Identifiable, Codable, Equatable {
    var id = UUID()
    var name: String
    var description: String?
    var exercises: [TemplateExercise]
    var customIcon: String?
    var createdAt: Date = Date()
    var lastModified: Date = Date()
    
    static func == (lhs: WorkoutTemplate, rhs: WorkoutTemplate) -> Bool {
        return lhs.id == rhs.id &&
               lhs.name == rhs.name &&
               lhs.description == rhs.description &&
               lhs.exercises == rhs.exercises &&
               lhs.customIcon == rhs.customIcon &&
               lhs.createdAt == rhs.createdAt &&
               lhs.lastModified == rhs.lastModified
    }
}

struct TemplateExercise: Identifiable, Codable, Equatable {
    var id = UUID()
    var exercise: Exercise
    var targetSets: Int
    var targetReps: Int?
    
    static func == (lhs: TemplateExercise, rhs: TemplateExercise) -> Bool {
        return lhs.id == rhs.id &&
               lhs.exercise == rhs.exercise &&
               lhs.targetSets == rhs.targetSets &&
               lhs.targetReps == rhs.targetReps
    }
} 