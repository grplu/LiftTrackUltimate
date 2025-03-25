import Foundation

struct WorkoutTemplate: Identifiable, Codable, Equatable {
    var id = UUID()
    var name: String
    var description: String? // Added optional description
    var exercises: [TemplateExercise]
    
    // Custom initializer with optional id and description
    init(id: UUID = UUID(), name: String, description: String? = nil, exercises: [TemplateExercise]) {
        self.id = id
        self.name = name
        self.description = description
        self.exercises = exercises
    }
    
    // Add Equatable implementation
    static func == (lhs: WorkoutTemplate, rhs: WorkoutTemplate) -> Bool {
        return lhs.id == rhs.id &&
               lhs.name == rhs.name &&
               lhs.description == rhs.description &&
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
