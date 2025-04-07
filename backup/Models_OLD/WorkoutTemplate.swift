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