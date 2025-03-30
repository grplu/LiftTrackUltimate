import Foundation

struct WorkoutTemplate: Identifiable, Codable, Equatable {
    var id = UUID()
    var name: String
    var description: String? // Added optional description
    var exercises: [TemplateExercise]
    var customIcon: String? // New property for template icon
    
    // Custom initializer with optional id, description, and customIcon
    init(id: UUID = UUID(), name: String, description: String? = nil, exercises: [TemplateExercise], customIcon: String? = nil) {
        self.id = id
        self.name = name
        self.description = description
        self.exercises = exercises
        self.customIcon = customIcon
    }
    
    // Add Equatable implementation
    static func == (lhs: WorkoutTemplate, rhs: WorkoutTemplate) -> Bool {
        return lhs.id == rhs.id &&
               lhs.name == rhs.name &&
               lhs.description == rhs.description &&
               lhs.exercises == rhs.exercises &&
               lhs.customIcon == rhs.customIcon
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
