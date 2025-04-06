import Foundation

protocol DataService {
    // Profile
    func loadProfile() -> UserProfile
    func saveProfile(_ profile: UserProfile)
    
    // Workouts
    func loadWorkouts() -> [AppWorkout]
    func saveWorkout(_ workout: AppWorkout)
    func updateWorkout(_ workout: AppWorkout)
    func deleteWorkout(_ workout: AppWorkout)
    
    // Exercises
    func loadExercises() -> [Exercise]
    func saveExercise(_ exercise: Exercise)
    func updateExercise(_ exercise: Exercise)
    func deleteExercise(_ exercise: Exercise)
    
    // Templates
    func loadTemplates() -> [WorkoutTemplate]
    func saveTemplate(_ template: WorkoutTemplate)
    func updateTemplate(_ template: WorkoutTemplate)
    func deleteTemplate(_ template: WorkoutTemplate)
    
    // Exercise Performances
    func loadExercisePerformances() -> [ExercisePerformance]
    func saveExercisePerformance(_ performance: ExercisePerformance)
    func updateExercisePerformance(_ performance: ExercisePerformance)
    func deleteExercisePerformance(_ performance: ExercisePerformance)
    
    // Achievements
    func isAchievementUnlocked(_ achievementId: String) -> Bool
    func unlockAchievement(_ achievementId: String)
    
    // Cache Management
    func clearCaches()
    func invalidateCache(for date: Date)
}

// MARK: - Error Types
enum DataServiceError: Error {
    case saveFailed
    case loadFailed
    case invalidData
    case notFound
    case unknown
} 