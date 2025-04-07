import Foundation

/// Represents the quality of form during an exercise set
public enum FormQuality: String, Codable {
    case poor
    case good
    case perfect
}

/// Represents a single set within an exercise
struct ExerciseSet: Identifiable, Codable {
    var id = UUID()
    var weight: Double?
    var reps: Int
    var completed: Bool
    var formQuality: FormQuality
    var duration: TimeInterval?
    var distance: Double?
    
    init(weight: Double? = nil, reps: Int = 10, completed: Bool = false, formQuality: FormQuality = .good, duration: TimeInterval? = nil, distance: Double? = nil) {
        self.weight = weight
        self.reps = reps
        self.completed = completed
        self.formQuality = formQuality
        self.duration = duration
        self.distance = distance
    }
    
    // Convenience initializer for cardio exercises
    init(duration: TimeInterval, distance: Double? = nil, completed: Bool = false, formQuality: FormQuality = .good) {
        self.id = UUID()
        self.weight = nil
        self.reps = 1
        self.completed = completed
        self.formQuality = formQuality
        self.duration = duration
        self.distance = distance
    }
} 