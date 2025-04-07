import Foundation

// MARK: - WorkoutExercise
struct WorkoutExercise: Identifiable, Codable {
    var id = UUID()
    var exerciseId: UUID
    var name: String
    var sets: [ExerciseSet]
    var notes: String?
    var exercise: Exercise
    
    init(exerciseId: UUID, name: String, sets: [ExerciseSet] = [], notes: String? = nil, exercise: Exercise) {
        self.exerciseId = exerciseId
        self.name = name
        self.sets = sets
        self.notes = notes
        self.exercise = exercise
    }
    
    init(exercise: Exercise, sets: [ExerciseSet] = []) {
        self.exerciseId = exercise.id
        self.name = exercise.name
        self.sets = sets
        self.exercise = exercise
    }
} 