import Foundation

// Renamed to make it distinct from HKWorkout
struct AppWorkout: Identifiable, Codable {
    var id = UUID()
    var name: String
    var date: Date
    var duration: TimeInterval
    var exercises: [WorkoutExercise]
    var notes: String?
    
    // New properties for template tracking
    var templateId: UUID?
    var templateIcon: String?
    
    // Helper to get the workout icon
    func getIcon() -> String {
        // If workout has a stored template icon, use it
        if let icon = templateIcon, !icon.isEmpty {
            return icon
        }
        
        // Otherwise determine based on exercises (similar to template logic)
        return determineMuscleBasedIcon()
    }
    
    // Determine icon based on primary muscle group
    func determineMuscleBasedIcon() -> String {
        // Count occurrences of each muscle group
        var muscleGroupCounts: [String: Int] = [:]
        
        for exercise in exercises {
            for muscleGroup in exercise.exercise.muscleGroups {
                muscleGroupCounts[muscleGroup, default: 0] += 1
            }
        }
        
        // Get the primary muscle group
        let primaryMuscleGroup = muscleGroupCounts.max(by: { $0.value < $1.value })?.key ?? "Mixed"
        let mainMuscle = primaryMuscleGroup.lowercased()
        
        // Return appropriate icon
        if mainMuscle.contains("chest") {
            return "heart.fill"
        } else if mainMuscle.contains("back") {
            return "figure.strengthtraining.traditional"
        } else if mainMuscle.contains("shoulder") || mainMuscle.contains("delt") {
            return "person.bust"
        } else if mainMuscle.contains("bicep") || mainMuscle.contains("tricep") || mainMuscle.contains("arm") {
            return "figure.arms.open"
        } else if mainMuscle.contains("core") || mainMuscle.contains("ab") {
            return "figure.core.training"
        } else if mainMuscle.contains("leg") || mainMuscle.contains("quad") || mainMuscle.contains("hamstring") {
            return "figure.walk"
        } else {
            return "figure.mixed.cardio"
        }
    }
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
