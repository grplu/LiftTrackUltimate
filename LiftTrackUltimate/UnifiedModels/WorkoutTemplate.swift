import Foundation

public struct WorkoutTemplate: Identifiable, Codable, Equatable, Hashable {
    public var id = UUID()
    public var name: String
    public var description: String?
    public var exercises: [TemplateExercise]
    public var customIcon: String?
    public var iconColor: String?
    public var createdAt: Date = Date()
    public var lastModified: Date = Date()
    
    public static func == (lhs: WorkoutTemplate, rhs: WorkoutTemplate) -> Bool {
        return lhs.id == rhs.id &&
               lhs.name == rhs.name &&
               lhs.description == rhs.description &&
               lhs.exercises == rhs.exercises &&
               lhs.customIcon == rhs.customIcon &&
               lhs.iconColor == rhs.iconColor &&
               lhs.createdAt == rhs.createdAt &&
               lhs.lastModified == rhs.lastModified
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    public init(id: UUID = UUID(), name: String, description: String? = nil, exercises: [TemplateExercise] = [], customIcon: String? = nil, iconColor: String? = nil, createdAt: Date = Date(), lastModified: Date = Date()) {
        self.id = id
        self.name = name
        self.description = description
        self.exercises = exercises
        self.customIcon = customIcon
        self.iconColor = iconColor
        self.createdAt = createdAt
        self.lastModified = lastModified
    }
}
// TemplateExercise is now defined in Models/TemplateExercise.swift 