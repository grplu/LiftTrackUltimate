import Foundation

// Renamed to make it distinct from HKWorkout
struct AppWorkout: Identifiable, Codable {
    var id = UUID()
    var name: String
    var date: Date
    var duration: TimeInterval
    var exercises: [WorkoutExercise]
    var notes: String?
}

struct WorkoutExercise: Identifiable, Codable {
    var id = UUID()
    var exercise: Exercise
    var sets: [ExerciseSet]
}

struct ExerciseSet: Identifiable, Codable {
    var id = UUID()
    var reps: Int?
    var weight: Double?
    var duration: TimeInterval?
    var distance: Double?
    var completed: Bool = false
}
