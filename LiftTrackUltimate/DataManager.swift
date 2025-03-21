import Foundation
import SwiftUI

class DataManager: ObservableObject {
    static let shared = DataManager()
    
    @Published var profile: UserProfile = UserProfile(name: "User", fitnessGoal: "Build Muscle")
    @Published var workouts: [AppWorkout] = []
    @Published var exercises: [Exercise] = []
    @Published var templates: [WorkoutTemplate] = []
    @Published var exercisePerformances: [ExercisePerformance] = []
    
    private let profileKey = "userProfile"
    private let workoutsKey = "userWorkouts"
    private let exercisesKey = "exercises"
    private let templatesKey = "workoutTemplates"
    private let exercisePerformancesKey = "exercisePerformances"
    
    init() {
        loadProfile()
        loadWorkouts()
        loadExercises()
        loadTemplates()
        loadExercisePerformances()
        
        // If no exercises exist, load sample data
        if exercises.isEmpty {
            loadSampleData()
        }
    }
    
    // MARK: - Profile Management
    
    func loadProfile() {
        if let data = UserDefaults.standard.data(forKey: profileKey),
           let profile = try? JSONDecoder().decode(UserProfile.self, from: data) {
            self.profile = profile
        }
    }
    
    func saveProfile(_ profile: UserProfile) {
        self.profile = profile
        if let encodedData = try? JSONEncoder().encode(profile) {
            UserDefaults.standard.set(encodedData, forKey: profileKey)
        }
    }
    
    // MARK: - Workout Management
    
    func loadWorkouts() {
        if let data = UserDefaults.standard.data(forKey: workoutsKey),
           let workouts = try? JSONDecoder().decode([AppWorkout].self, from: data) {
            self.workouts = workouts
        }
    }
    
    func saveWorkout(_ workout: AppWorkout) {
        // Add new workout to the beginning of the array
        workouts.insert(workout, at: 0)
        saveWorkouts()
        
        // Also save to HealthKit
        HealthKitManager.shared.saveWorkout(workout)
    }
    
    func updateWorkout(_ workout: AppWorkout) {
        if let index = workouts.firstIndex(where: { $0.id == workout.id }) {
            workouts[index] = workout
            saveWorkouts()
        }
    }
    
    func deleteWorkout(_ workout: AppWorkout) {
        workouts.removeAll { $0.id == workout.id }
        saveWorkouts()
    }
    
    private func saveWorkouts() {
        if let encodedData = try? JSONEncoder().encode(workouts) {
            UserDefaults.standard.set(encodedData, forKey: workoutsKey)
        }
    }
    
    // MARK: - Exercise Management
    
    func loadExercises() {
        if let data = UserDefaults.standard.data(forKey: exercisesKey),
           let exercises = try? JSONDecoder().decode([Exercise].self, from: data) {
            self.exercises = exercises
        }
    }
    
    func saveExercise(_ exercise: Exercise) {
        exercises.append(exercise)
        saveExercises()
    }
    
    func updateExercise(_ exercise: Exercise) {
        if let index = exercises.firstIndex(where: { $0.id == exercise.id }) {
            exercises[index] = exercise
            saveExercises()
        }
    }
    
    func deleteExercise(_ exercise: Exercise) {
        exercises.removeAll { $0.id == exercise.id }
        saveExercises()
    }
    
    func updateExercises(_ exercises: [Exercise]) {
        self.exercises = exercises
        saveExercises()
    }
    
    private func saveExercises() {
        if let encodedData = try? JSONEncoder().encode(exercises) {
            UserDefaults.standard.set(encodedData, forKey: exercisesKey)
        }
    }
    
    // MARK: - Template Management
    
    func loadTemplates() {
        if let data = UserDefaults.standard.data(forKey: templatesKey),
           let templates = try? JSONDecoder().decode([WorkoutTemplate].self, from: data) {
            self.templates = templates
        }
    }
    
    func saveTemplate(_ template: WorkoutTemplate) {
        templates.append(template)
        saveTemplates()
    }
    
    func updateTemplate(_ template: WorkoutTemplate) {
        if let index = templates.firstIndex(where: { $0.id == template.id }) {
            templates[index] = template
            saveTemplates()
        }
    }
    
    func deleteTemplate(_ template: WorkoutTemplate) {
        templates.removeAll { $0.id == template.id }
        saveTemplates()
    }
    
    private func saveTemplates() {
        if let encodedData = try? JSONEncoder().encode(templates) {
            UserDefaults.standard.set(encodedData, forKey: templatesKey)
        }
    }
    
    // MARK: - Exercise Performance Management
    
    func saveExercisePerformance(from workoutExercise: WorkoutExercise) {
        let exerciseId = workoutExercise.exercise.id
        
        // Extract completed sets (only save data from completed sets)
        let completedSets = workoutExercise.sets.filter { $0.completed }
        guard !completedSets.isEmpty else { return }
        
        // Extract weights and reps from sets
        let setWeights = completedSets.map { $0.weight }
        let setReps = completedSets.map { $0.reps }
        
        // Calculate averages for progress tracking
        let avgReps = setReps.compactMap { $0 }.isEmpty ? nil :
                     Int(Double(setReps.compactMap { $0 }.reduce(0, +)) / Double(setReps.compactMap { $0 }.count))
        let avgWeight = setWeights.compactMap { $0 }.isEmpty ? nil :
                       setWeights.compactMap { $0 }.reduce(0, +) / Double(setWeights.compactMap { $0 }.count)
        
        // Get the last reps and weight (from the last set)
        let lastUsedReps = completedSets.last?.reps
        let lastUsedWeight = completedSets.last?.weight
        
        // Create or update performance object
        var performance: ExercisePerformance
        
        if let existingIndex = exercisePerformances.firstIndex(where: { $0.exerciseId == exerciseId }) {
            // Update existing performance
            performance = exercisePerformances[existingIndex]
            performance.date = Date()
            performance.avgReps = avgReps
            performance.avgWeight = avgWeight
            performance.totalSets = completedSets.count
            performance.lastUsedReps = lastUsedReps
            performance.lastUsedWeight = lastUsedWeight
            performance.setWeights = setWeights
            performance.setReps = setReps
            
            exercisePerformances[existingIndex] = performance
        } else {
            // Create new performance
            performance = ExercisePerformance(
                exerciseId: exerciseId,
                reps: avgReps,
                weight: avgWeight,
                sets: completedSets.count
            )
            performance.setWeights = setWeights
            performance.setReps = setReps
            
            exercisePerformances.append(performance)
        }
        
        // Save to UserDefaults
        saveExercisePerformances()
    }
    
    func saveExercisePerformance(_ performance: ExercisePerformance) {
        // Find index of existing performance for this exercise
        if let index = exercisePerformances.firstIndex(where: { $0.exerciseId == performance.exerciseId }) {
            // Update existing performance
            exercisePerformances[index] = performance
        } else {
            // Add new performance
            exercisePerformances.append(performance)
        }
        
        // Save to UserDefaults
        saveExercisePerformances()
        
        // Update profile's exercise memory if a profile exists
        var updatedProfile = profile
        updatedProfile.updateExerciseMemory(
            exerciseId: performance.exerciseId,
            reps: performance.lastUsedReps,
            sets: performance.totalSets > 0 ? performance.totalSets : nil,
            weight: performance.lastUsedWeight
        )
        saveProfile(updatedProfile)
    }
    
    // Save all performances at once
    private func saveExercisePerformances() {
        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(exercisePerformances)
            UserDefaults.standard.set(data, forKey: exercisePerformancesKey)
        } catch {
            print("Error saving exercise performances: \(error)")
        }
    }
    
    private func loadExercisePerformances() {
        if let data = UserDefaults.standard.data(forKey: exercisePerformancesKey) {
            do {
                let decoder = JSONDecoder()
                let performances = try decoder.decode([ExercisePerformance].self, from: data)
                self.exercisePerformances = performances
            } catch {
                print("Error decoding exercise performances: \(error)")
                self.exercisePerformances = []
            }
        }
    }
    
    // Get the last performance for an exercise
    func getLastPerformance(for exercise: Exercise) -> ExercisePerformance? {
        return exercisePerformances.first { $0.exerciseId == exercise.id }
    }
    
    // Get weight for a specific set
    func getSetWeight(for exercise: Exercise, setIndex: Int) -> Double? {
        guard let performance = getLastPerformance(for: exercise) else {
            return nil
        }
        
        // If we have saved weights for each set
        if setIndex < performance.setWeights.count {
            return performance.setWeights[setIndex]
        }
        
        // Otherwise use the last weight
        return performance.lastUsedWeight
    }
    
    // Get reps for a specific set
    func getSetReps(for exercise: Exercise, setIndex: Int) -> Int? {
        guard let performance = getLastPerformance(for: exercise) else {
            return nil
        }
        
        // If we have saved reps for each set
        if setIndex < performance.setReps.count {
            return performance.setReps[setIndex]
        }
        
        // Otherwise use the last reps
        return performance.lastUsedReps
    }
    
    func clearExercisePerformances() {
        exercisePerformances.removeAll()
        UserDefaults.standard.removeObject(forKey: exercisePerformancesKey)
    }
    
    // MARK: - Sample Data
    
    func loadSampleData() {
        // Sample Exercises
        let sampleExercises = [
            Exercise(name: "Bench Press", category: "Strength", muscleGroups: ["Chest", "Triceps"], instructions: "Lie on bench, lower barbell to chest, press up."),
            Exercise(name: "Squat", category: "Strength", muscleGroups: ["Quadriceps", "Glutes"], instructions: "Stand with feet shoulder-width apart, bend knees, lower body as if sitting."),
            Exercise(name: "Deadlift", category: "Strength", muscleGroups: ["Back", "Legs"], instructions: "Stand over barbell, bend and grip bar, lift by extending hips and knees."),
            Exercise(name: "Pull-up", category: "Strength", muscleGroups: ["Back", "Biceps"], instructions: "Hang from bar, pull body up until chin clears bar."),
            Exercise(name: "Overhead Press", category: "Strength", muscleGroups: ["Shoulders", "Triceps"], instructions: "Stand with barbell at shoulders, press overhead."),
            Exercise(name: "Running", category: "Cardio", muscleGroups: ["Full Body"], instructions: "Run at comfortable pace, maintain good posture."),
            Exercise(name: "Cycling", category: "Cardio", muscleGroups: ["Legs", "Cardiovascular"], instructions: "Maintain steady cadence, adjust resistance as needed."),
            Exercise(name: "Plank", category: "Core", muscleGroups: ["Abdominals", "Lower Back"], instructions: "Hold push-up position on forearms, keep body straight."),
            Exercise(name: "Lunges", category: "Strength", muscleGroups: ["Quadriceps", "Glutes", "Hamstrings"], instructions: "Step forward, lower back knee toward ground, return to standing.")
        ]
        
        self.exercises = sampleExercises
        saveExercises()
        
        // Sample Templates
        let upperBodyTemplate = WorkoutTemplate(
            name: "Upper Body Strength",
            exercises: [
                TemplateExercise(exercise: sampleExercises[0], targetSets: 3, targetReps: 10),
                TemplateExercise(exercise: sampleExercises[3], targetSets: 3, targetReps: 8),
                TemplateExercise(exercise: sampleExercises[4], targetSets: 3, targetReps: 10)
            ]
        )
        
        let lowerBodyTemplate = WorkoutTemplate(
            name: "Lower Body Strength",
            exercises: [
                TemplateExercise(exercise: sampleExercises[1], targetSets: 4, targetReps: 8),
                TemplateExercise(exercise: sampleExercises[2], targetSets: 3, targetReps: 6),
                TemplateExercise(exercise: sampleExercises[8], targetSets: 3, targetReps: 12)
            ]
        )
        
        self.templates = [upperBodyTemplate, lowerBodyTemplate]
        saveTemplates()
    }
}
