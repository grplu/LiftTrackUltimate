import Foundation
import SwiftUI

struct Constants {
    // App Information
    static let appName = "LiftTrackUltimate"
    static let appVersion = "1.0.0"
    
    // UI Constants
    struct UI {
        static let cornerRadius: CGFloat = 10
        static let padding: CGFloat = 16
        static let buttonHeight: CGFloat = 50
        static let cardShadowRadius: CGFloat = 2
        static let defaultAnimationDuration: Double = 0.3
    }
    
    // Workout Constants
    struct Workout {
        static let defaultWorkoutName = "New Workout"
        static let defaultRestTimeBetweenSets: TimeInterval = 60 // 60 seconds
        static let defaultSetsPerExercise = 3
        static let defaultRepsPerSet = 10
    }
    
    // Exercise Categories
    static let exerciseCategories = [
        "Strength",
        "Cardio",
        "Flexibility",
        "Core",
        "Balance",
        "Olympic",
        "Plyometric",
        "Other"
    ]
    
    // Muscle Groups
    static let muscleGroups = [
        "Chest",
        "Back",
        "Shoulders",
        "Biceps",
        "Triceps",
        "Forearms",
        "Quadriceps",
        "Hamstrings",
        "Calves",
        "Glutes",
        "Abdominals",
        "Obliques",
        "Lower Back",
        "Full Body",
        "Cardiovascular"
    ]
    
    // Fitness Goals
    static let fitnessGoals = [
        "Weight Loss",
        "Build Muscle",
        "Improve Strength",
        "Improve Endurance",
        "Increase Flexibility",
        "Maintain Fitness",
        "General Health"
    ]
    
    // HealthKit Identifiers
    struct HealthKit {
        static let workoutTypeStrengthTraining = "HKWorkoutActivityTypeTraditionalStrengthTraining"
        static let workoutTypeCardio = "HKWorkoutActivityTypeRunning"
        static let workoutTypeHIIT = "HKWorkoutActivityTypeHighIntensityIntervalTraining"
        static let workoutTypeFlexibility = "HKWorkoutActivityTypeFlexibility"
        static let workoutTypeOther = "HKWorkoutActivityTypeOther"
    }
}
