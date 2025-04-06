import Foundation

class LocalDataService: DataService {
    static let shared = LocalDataService()
    
    // MARK: - Storage Keys
    private let profileKey = "userProfile"
    private let workoutsKey = "userWorkouts"
    private let exercisesKey = "exercises"
    private let templatesKey = "workoutTemplates"
    private let exercisePerformancesKey = "exercisePerformances"
    
    // MARK: - Cache Properties
    private var workoutDataCache: [String: (planned: Int, completed: Int)] = [:]
    private var performanceCache: [UUID: ExercisePerformance] = [:]
    private var lastWorkoutModificationTime: Date?
    private var weeklyProgressCache: [(planned: Int, completed: Int)] = []
    private var weeklyProgressCacheDate: Date?
    
    private let weeklyProgressCacheValidDuration: TimeInterval = 300 // 5 minutes
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter
    }()
    
    private let calendar = Calendar.current
    
    // MARK: - Profile Management
    func loadProfile() -> UserProfile {
        if let data = UserDefaults.standard.data(forKey: profileKey) {
            do {
                let decoder = JSONDecoder()
                let profile = try decoder.decode(UserProfile.self, from: data)
                return profile
            } catch {
                print("Error decoding profile: \(error)")
            }
        }
        
        // Create a default profile
        var profile = UserProfile()
        profile.name = "User"
        return profile
    }
    
    func saveProfile(_ profile: UserProfile) {
        if let encodedData = try? JSONEncoder().encode(profile) {
            UserDefaults.standard.set(encodedData, forKey: profileKey)
        }
    }
    
    // MARK: - Workout Management
    func loadWorkouts() -> [AppWorkout] {
        if let data = UserDefaults.standard.data(forKey: workoutsKey),
           let workouts = try? JSONDecoder().decode([AppWorkout].self, from: data) {
            return workouts
        }
        return []
    }
    
    func saveWorkout(_ workout: AppWorkout) {
        var workouts = loadWorkouts()
        workouts.insert(workout, at: 0)
        saveWorkouts(workouts)
        invalidateCache(for: workout.date)
    }
    
    func updateWorkout(_ workout: AppWorkout) {
        var workouts = loadWorkouts()
        if let index = workouts.firstIndex(where: { $0.id == workout.id }) {
            workouts[index] = workout
            saveWorkouts(workouts)
            invalidateCache(for: workout.date)
        }
    }
    
    func deleteWorkout(_ workout: AppWorkout) {
        var workouts = loadWorkouts()
        workouts.removeAll { $0.id == workout.id }
        saveWorkouts(workouts)
        invalidateCache(for: workout.date)
    }
    
    private func saveWorkouts(_ workouts: [AppWorkout]) {
        if let encodedData = try? JSONEncoder().encode(workouts) {
            UserDefaults.standard.set(encodedData, forKey: workoutsKey)
        }
    }
    
    // MARK: - Exercise Management
    func loadExercises() -> [Exercise] {
        if let data = UserDefaults.standard.data(forKey: exercisesKey),
           let exercises = try? JSONDecoder().decode([Exercise].self, from: data) {
            return exercises
        }
        return []
    }
    
    func saveExercise(_ exercise: Exercise) {
        var exercises = loadExercises()
        exercises.append(exercise)
        saveExercises(exercises)
    }
    
    func updateExercise(_ exercise: Exercise) {
        var exercises = loadExercises()
        if let index = exercises.firstIndex(where: { $0.id == exercise.id }) {
            exercises[index] = exercise
            saveExercises(exercises)
        }
    }
    
    func deleteExercise(_ exercise: Exercise) {
        var exercises = loadExercises()
        exercises.removeAll { $0.id == exercise.id }
        saveExercises(exercises)
    }
    
    private func saveExercises(_ exercises: [Exercise]) {
        if let encodedData = try? JSONEncoder().encode(exercises) {
            UserDefaults.standard.set(encodedData, forKey: exercisesKey)
        }
    }
    
    // MARK: - Template Management
    func loadTemplates() -> [WorkoutTemplate] {
        if let data = UserDefaults.standard.data(forKey: templatesKey),
           let templates = try? JSONDecoder().decode([WorkoutTemplate].self, from: data) {
            return templates
        }
        return []
    }
    
    func saveTemplate(_ template: WorkoutTemplate) {
        var templates = loadTemplates()
        templates.append(template)
        saveTemplates(templates)
    }
    
    func updateTemplate(_ template: WorkoutTemplate) {
        var templates = loadTemplates()
        if let index = templates.firstIndex(where: { $0.id == template.id }) {
            templates[index] = template
            saveTemplates(templates)
        }
    }
    
    func deleteTemplate(_ template: WorkoutTemplate) {
        var templates = loadTemplates()
        templates.removeAll { $0.id == template.id }
        saveTemplates(templates)
    }
    
    private func saveTemplates(_ templates: [WorkoutTemplate]) {
        if let encodedData = try? JSONEncoder().encode(templates) {
            UserDefaults.standard.set(encodedData, forKey: templatesKey)
        }
    }
    
    // MARK: - Exercise Performance Management
    func loadExercisePerformances() -> [ExercisePerformance] {
        if let data = UserDefaults.standard.data(forKey: exercisePerformancesKey),
           let performances = try? JSONDecoder().decode([ExercisePerformance].self, from: data) {
            return performances
        }
        return []
    }
    
    func saveExercisePerformance(_ performance: ExercisePerformance) {
        var performances = loadExercisePerformances()
        performances.append(performance)
        saveExercisePerformances(performances)
    }
    
    func updateExercisePerformance(_ performance: ExercisePerformance) {
        var performances = loadExercisePerformances()
        if let index = performances.firstIndex(where: { $0.id == performance.id }) {
            performances[index] = performance
            saveExercisePerformances(performances)
        }
    }
    
    func deleteExercisePerformance(_ performance: ExercisePerformance) {
        var performances = loadExercisePerformances()
        performances.removeAll { $0.id == performance.id }
        saveExercisePerformances(performances)
    }
    
    private func saveExercisePerformances(_ performances: [ExercisePerformance]) {
        if let encodedData = try? JSONEncoder().encode(performances) {
            UserDefaults.standard.set(encodedData, forKey: exercisePerformancesKey)
        }
    }
    
    // MARK: - Cache Management
    func clearCaches() {
        workoutDataCache.removeAll()
        performanceCache.removeAll()
        weeklyProgressCache.removeAll()
        weeklyProgressCacheDate = nil
    }
    
    func invalidateCache(for date: Date) {
        let dateKey = formattedDateKey(from: date)
        workoutDataCache.removeValue(forKey: dateKey)
        
        let currentWeekStart = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: Date()))!
        let currentWeekEnd = calendar.date(byAdding: .day, value: 7, to: currentWeekStart)!
        
        if date >= currentWeekStart && date < currentWeekEnd {
            weeklyProgressCacheDate = nil
            weeklyProgressCache.removeAll()
        }
        
        lastWorkoutModificationTime = Date()
    }
    
    private func formattedDateKey(from date: Date) -> String {
        let components = calendar.dateComponents([.year, .month, .day], from: date)
        return "\(components.year ?? 0)-\(components.month ?? 0)-\(components.day ?? 0)"
    }
    
    // MARK: - Achievements
    func isAchievementUnlocked(_ achievementId: String) -> Bool {
        UserDefaults.standard.bool(forKey: "achievement_unlocked_\(achievementId)")
    }
    
    func unlockAchievement(_ achievementId: String) {
        UserDefaults.standard.set(true, forKey: "achievement_unlocked_\(achievementId)")
        NotificationCenter.default.post(name: .workoutDataDidChange, object: nil)
    }
} 