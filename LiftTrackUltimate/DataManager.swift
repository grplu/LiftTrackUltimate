import Foundation
import SwiftUI

extension Notification.Name {
    static let workoutDataChanged = Notification.Name("workoutDataChanged")
}

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
        
        print("DEBUG: saveWorkout - Saved workout \(workout.name) with date \(workout.date)")
        print("DEBUG: saveWorkout - Total exercises: \(workout.exercises.count)")
        
        // Print completed sets information
        for (index, exercise) in workout.exercises.enumerated() {
            let completedSets = exercise.sets.filter { $0.completed }.count
            print("DEBUG: saveWorkout - Exercise \(index + 1): \(exercise.exercise.name), Completed sets: \(completedSets)/\(exercise.sets.count)")
        }
        
        // Notify observers about the workout data change
        print("DEBUG: saveWorkout - Posting workoutDataChanged notification")
        NotificationCenter.default.post(name: .workoutDataChanged, object: nil)
    }
    
    func updateWorkout(_ workout: AppWorkout) {
        if let index = workouts.firstIndex(where: { $0.id == workout.id }) {
            workouts[index] = workout
            saveWorkouts()
            
            print("DEBUG: updateWorkout - Updated workout \(workout.name)")
            
            // Notify observers about the workout data change
            print("DEBUG: updateWorkout - Posting workoutDataChanged notification")
            NotificationCenter.default.post(name: .workoutDataChanged, object: nil)
        }
    }
    
    func deleteWorkout(_ workout: AppWorkout) {
        workouts.removeAll { $0.id == workout.id }
        saveWorkouts()
        
        print("DEBUG: deleteWorkout - Deleted workout \(workout.name)")
        
        // Notify observers about the workout data change
        print("DEBUG: deleteWorkout - Posting workoutDataChanged notification")
        NotificationCenter.default.post(name: .workoutDataChanged, object: nil)
    }
    
    private func saveWorkouts() {
        if let encodedData = try? JSONEncoder().encode(workouts) {
            UserDefaults.standard.set(encodedData, forKey: workoutsKey)
            print("DEBUG: saveWorkouts - Saved \(workouts.count) workouts to UserDefaults")
        } else {
            print("DEBUG: saveWorkouts - Failed to encode workouts")
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
        
        print("DEBUG: saveExercisePerformance - Saving performance for \(workoutExercise.exercise.name) with \(completedSets.count) completed sets")
        
        // Extract weights and reps from sets
        let setWeights = completedSets.map { $0.weight }
        let setReps = completedSets.map { $0.reps }
        
        // CHANGED: Find maximum weight instead of average
        let maxWeight = setWeights.compactMap { $0 }.max()
        
        // Keep average reps for statistics purposes
        let avgReps = setReps.compactMap { $0 }.isEmpty ? nil :
                     Int(Double(setReps.compactMap { $0 }.reduce(0, +)) / Double(setReps.compactMap { $0 }.count))
        
        // Get the last reps and weight (from the last set)
        let lastUsedReps = completedSets.last?.reps
        let lastUsedWeight = maxWeight // CHANGED: Use max weight instead of last weight
        
        // Create or update performance object
        var performance: ExercisePerformance
        
        if let existingIndex = exercisePerformances.firstIndex(where: { $0.exerciseId == exerciseId }) {
            // Update existing performance
            performance = exercisePerformances[existingIndex]
            performance.date = Date()
            performance.avgReps = avgReps
            performance.avgWeight = maxWeight // CHANGED: Use max weight
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
                weight: maxWeight, // CHANGED: Use max weight
                sets: completedSets.count
            )
            performance.setWeights = setWeights
            performance.setReps = setReps
            
            exercisePerformances.append(performance)
        }
        
        // Save to UserDefaults
        saveExercisePerformances()
        
        // Notify observers about the workout data change
        print("DEBUG: saveExercisePerformance - Posting workoutDataChanged notification")
        NotificationCenter.default.post(name: .workoutDataChanged, object: nil)
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
        
        // Notify observers about the workout data change
        print("DEBUG: saveExercisePerformance - Posting workoutDataChanged notification")
        NotificationCenter.default.post(name: .workoutDataChanged, object: nil)
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
        
        // Notify observers about the data change
        NotificationCenter.default.post(name: .workoutDataChanged, object: nil)
    }
    
    // MARK: - Workout Progress Data
    
    func getWorkoutData(for date: Date) -> (planned: Int, completed: Int) {
        let calendar = Calendar.current
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        
        print("DEBUG: Getting workout data for date: \(dateFormatter.string(from: date))")
        
        // Filter workouts for the specified date
        let workoutsOnDate = workouts.filter { workout in
            let isOnSameDay = calendar.isDate(workout.date, inSameDayAs: date)
            print("DEBUG: Checking workout from \(dateFormatter.string(from: workout.date)), same day? \(isOnSameDay)")
            return isOnSameDay
        }
        
        // If there are no workouts on this date, return zeros
        if workoutsOnDate.isEmpty {
            print("DEBUG: No workouts found for this date")
            return (0, 0)
        }
        
        // Each workout counts as one planned unit
        let plannedCount = workoutsOnDate.count
        
        // Count workouts with completed sets as completed
        let completedCount = workoutsOnDate.filter { workout in
            let hasCompletedSets = workout.exercises.flatMap { $0.sets }.contains { $0.completed }
            print("DEBUG: Workout \(workout.name) has completed sets? \(hasCompletedSets)")
            return hasCompletedSets
        }.count
        
        print("DEBUG: Found \(plannedCount) planned and \(completedCount) completed workouts")
        return (plannedCount, completedCount)
    }
    
    // MARK: - Sample Data
    
    func loadSampleData() {
        // Comprehensive Exercise List
        let sampleExercises = [
            // Chest Exercises
            Exercise(name: "Bench Press", category: "Strength", muscleGroups: ["Chest", "Triceps"], instructions: "Lie on bench, lower barbell to chest, press up."),
            Exercise(name: "Incline Bench Press", category: "Strength", muscleGroups: ["Chest", "Shoulders", "Triceps"], instructions: "Lie on incline bench, lower barbell to upper chest, press up."),
            Exercise(name: "Decline Bench Press", category: "Strength", muscleGroups: ["Chest", "Triceps"], instructions: "Lie on decline bench, lower barbell to lower chest, press up."),
            Exercise(name: "Dumbbell Flyes", category: "Strength", muscleGroups: ["Chest"], instructions: "Lie on bench, hold dumbbells with arms extended above chest, lower to sides in arc motion, return to start."),
            Exercise(name: "Cable Crossover", category: "Strength", muscleGroups: ["Chest"], instructions: "Stand between cable stations with arms extended to sides, bring hands together in front of body."),
            Exercise(name: "Push-Ups", category: "Strength", muscleGroups: ["Chest", "Shoulders", "Triceps"], instructions: "Start in plank position, lower body to ground by bending elbows, push back up."),
            
            // Back Exercises
            Exercise(name: "Deadlift", category: "Strength", muscleGroups: ["Back", "Legs"], instructions: "Stand over barbell, bend and grip bar, lift by extending hips and knees."),
            Exercise(name: "Pull-Up", category: "Strength", muscleGroups: ["Back", "Biceps"], instructions: "Hang from bar, pull body up until chin clears bar."),
            Exercise(name: "Bent Over Row", category: "Strength", muscleGroups: ["Back", "Biceps"], instructions: "Bend at hips, keep back straight, pull barbell or dumbbells to lower chest."),
            Exercise(name: "Lat Pulldown", category: "Strength", muscleGroups: ["Back", "Biceps"], instructions: "Sit at machine, grasp bar, pull down to upper chest."),
            Exercise(name: "T-Bar Row", category: "Strength", muscleGroups: ["Back"], instructions: "Straddle a bar with one end fixed, bend at hips, pull free end to chest."),
            Exercise(name: "Face Pull", category: "Strength", muscleGroups: ["Back", "Shoulders"], instructions: "Pull rope attachment to face with high elbows, focusing on rear deltoids."),
            
            // Shoulder Exercises
            Exercise(name: "Overhead Press", category: "Strength", muscleGroups: ["Shoulders", "Triceps"], instructions: "Stand with barbell at shoulders, press overhead."),
            Exercise(name: "Lateral Raise", category: "Strength", muscleGroups: ["Shoulders"], instructions: "Hold dumbbells at sides, raise arms out to sides until parallel with floor."),
            Exercise(name: "Front Raise", category: "Strength", muscleGroups: ["Shoulders"], instructions: "Hold dumbbells in front of thighs, raise arms forward until parallel with floor."),
            Exercise(name: "Rear Delt Flye", category: "Strength", muscleGroups: ["Shoulders"], instructions: "Bend at hips, hold dumbbells below chest, raise to sides focusing on rear delts."),
            Exercise(name: "Arnold Press", category: "Strength", muscleGroups: ["Shoulders", "Triceps"], instructions: "Hold dumbbells with palms facing you, press overhead while rotating palms forward."),
            
            // Arm Exercises
            Exercise(name: "Bicep Curl", category: "Strength", muscleGroups: ["Biceps"], instructions: "Hold weights at sides, curl up by bending elbows, lower back down."),
            Exercise(name: "Hammer Curl", category: "Strength", muscleGroups: ["Biceps", "Forearms"], instructions: "Hold dumbbells with palms facing each other, curl up by bending elbows."),
            Exercise(name: "Tricep Pushdown", category: "Strength", muscleGroups: ["Triceps"], instructions: "Push cable attachment down by extending elbows, keep upper arms stationary."),
            Exercise(name: "Tricep Extension", category: "Strength", muscleGroups: ["Triceps"], instructions: "Hold weight behind head with bent elbows, extend arms overhead."),
            Exercise(name: "Preacher Curl", category: "Strength", muscleGroups: ["Biceps"], instructions: "Rest arms on preacher bench, curl weight up by bending elbows."),
            Exercise(name: "Skull Crusher", category: "Strength", muscleGroups: ["Triceps"], instructions: "Lie on bench, hold weight above face, lower to forehead by bending elbows."),
            
            // Leg Exercises
            Exercise(name: "Squat", category: "Strength", muscleGroups: ["Quadriceps", "Glutes"], instructions: "Stand with feet shoulder-width apart, bend knees, lower body as if sitting."),
            Exercise(name: "Leg Press", category: "Strength", muscleGroups: ["Quadriceps", "Glutes", "Hamstrings"], instructions: "Sit at machine, push platform away by extending knees."),
            Exercise(name: "Leg Extension", category: "Strength", muscleGroups: ["Quadriceps"], instructions: "Sit at machine, extend knees to raise weight."),
            Exercise(name: "Leg Curl", category: "Strength", muscleGroups: ["Hamstrings"], instructions: "Lie face down on machine, bend knees to raise weight."),
            Exercise(name: "Calf Raise", category: "Strength", muscleGroups: ["Calves"], instructions: "Stand with weight, raise heels off floor by extending ankles."),
            Exercise(name: "Lunges", category: "Strength", muscleGroups: ["Quadriceps", "Glutes", "Hamstrings"], instructions: "Step forward, lower back knee toward ground, return to standing."),
            Exercise(name: "Romanian Deadlift", category: "Strength", muscleGroups: ["Hamstrings", "Back"], instructions: "Hold weight in front of thighs, bend at hips while keeping legs nearly straight."),
            Exercise(name: "Hip Thrust", category: "Strength", muscleGroups: ["Glutes", "Hamstrings"], instructions: "Sit with upper back against bench, weight on hips, thrust hips upward."),
            
            // Core Exercises
            Exercise(name: "Plank", category: "Core", muscleGroups: ["Abdominals", "Lower Back"], instructions: "Hold push-up position on forearms, keep body straight."),
            Exercise(name: "Crunch", category: "Core", muscleGroups: ["Abdominals"], instructions: "Lie on back, knees bent, curl shoulders off floor."),
            Exercise(name: "Leg Raise", category: "Core", muscleGroups: ["Abdominals"], instructions: "Lie on back, lift legs to vertical position."),
            Exercise(name: "Russian Twist", category: "Core", muscleGroups: ["Abdominals", "Obliques"], instructions: "Sit with knees bent, twist torso side to side."),
            Exercise(name: "Side Plank", category: "Core", muscleGroups: ["Obliques"], instructions: "Support body on one forearm and side of feet, keep body straight."),
            Exercise(name: "Mountain Climber", category: "Core", muscleGroups: ["Abdominals"], instructions: "Start in plank position, rapidly alternate bringing knees to chest."),
            
            // Cardio Exercises
            Exercise(name: "Running", category: "Cardio", muscleGroups: ["Full Body"], instructions: "Run at comfortable pace, maintain good posture."),
            Exercise(name: "Cycling", category: "Cardio", muscleGroups: ["Legs", "Cardiovascular"], instructions: "Maintain steady cadence, adjust resistance as needed."),
            Exercise(name: "Rowing", category: "Cardio", muscleGroups: ["Back", "Arms", "Legs"], instructions: "Pull handle to chest, extend legs simultaneously, return in reverse order."),
            Exercise(name: "Jumping Rope", category: "Cardio", muscleGroups: ["Legs", "Cardiovascular"], instructions: "Jump rope with both feet or alternating feet, maintain steady rhythm."),
            Exercise(name: "Elliptical", category: "Cardio", muscleGroups: ["Full Body"], instructions: "Follow machine's natural motion, adjust resistance as needed."),
            Exercise(name: "Stair Climber", category: "Cardio", muscleGroups: ["Legs", "Cardiovascular"], instructions: "Step on moving stairs, maintain upright posture.")
        ]
        
        self.exercises = sampleExercises
        saveExercises()
        
        // Updated Templates with more exercises
        let upperBodyTemplate = WorkoutTemplate(
            name: "Upper Body Strength",
            exercises: [
                TemplateExercise(exercise: sampleExercises.first(where: { $0.name == "Bench Press" })!, targetSets: 3, targetReps: 10),
                TemplateExercise(exercise: sampleExercises.first(where: { $0.name == "Pull-Up" })!, targetSets: 3, targetReps: 8),
                TemplateExercise(exercise: sampleExercises.first(where: { $0.name == "Overhead Press" })!, targetSets: 3, targetReps: 10),
                TemplateExercise(exercise: sampleExercises.first(where: { $0.name == "Bent Over Row" })!, targetSets: 3, targetReps: 10),
                TemplateExercise(exercise: sampleExercises.first(where: { $0.name == "Bicep Curl" })!, targetSets: 3, targetReps: 12)
            ]
        )
        
        let lowerBodyTemplate = WorkoutTemplate(
            name: "Lower Body Strength",
            exercises: [
                TemplateExercise(exercise: sampleExercises.first(where: { $0.name == "Squat" })!, targetSets: 4, targetReps: 8),
                TemplateExercise(exercise: sampleExercises.first(where: { $0.name == "Deadlift" })!, targetSets: 3, targetReps: 6),
                TemplateExercise(exercise: sampleExercises.first(where: { $0.name == "Lunges" })!, targetSets: 3, targetReps: 12),
                TemplateExercise(exercise: sampleExercises.first(where: { $0.name == "Leg Press" })!, targetSets: 3, targetReps: 10)
            ]
        )
        
        let pushTemplate = WorkoutTemplate(
            name: "Push Day",
            exercises: [
                TemplateExercise(exercise: sampleExercises.first(where: { $0.name == "Bench Press" })!, targetSets: 4, targetReps: 8),
                TemplateExercise(exercise: sampleExercises.first(where: { $0.name == "Incline Bench Press" })!, targetSets: 3, targetReps: 10),
                TemplateExercise(exercise: sampleExercises.first(where: { $0.name == "Overhead Press" })!, targetSets: 3, targetReps: 10),
                TemplateExercise(exercise: sampleExercises.first(where: { $0.name == "Tricep Pushdown" })!, targetSets: 3, targetReps: 12),
                TemplateExercise(exercise: sampleExercises.first(where: { $0.name == "Lateral Raise" })!, targetSets: 3, targetReps: 15)
            ]
        )
        
        let pullTemplate = WorkoutTemplate(
            name: "Pull Day",
            exercises: [
                TemplateExercise(exercise: sampleExercises.first(where: { $0.name == "Deadlift" })!, targetSets: 3, targetReps: 6),
                TemplateExercise(exercise: sampleExercises.first(where: { $0.name == "Pull-Up" })!, targetSets: 3, targetReps: 8),
                TemplateExercise(exercise: sampleExercises.first(where: { $0.name == "Bent Over Row" })!, targetSets: 3, targetReps: 10),
                TemplateExercise(exercise: sampleExercises.first(where: { $0.name == "Bicep Curl" })!, targetSets: 3, targetReps: 12),
                TemplateExercise(exercise: sampleExercises.first(where: { $0.name == "Face Pull" })!, targetSets: 3, targetReps: 15)
            ]
        )
        
        let coreTemplate = WorkoutTemplate(
            name: "Core Workout",
            exercises: [
                TemplateExercise(exercise: sampleExercises.first(where: { $0.name == "Plank" })!, targetSets: 3, targetReps: 1),
                TemplateExercise(exercise: sampleExercises.first(where: { $0.name == "Crunch" })!, targetSets: 3, targetReps: 15),
                TemplateExercise(exercise: sampleExercises.first(where: { $0.name == "Russian Twist" })!, targetSets: 3, targetReps: 20),
                TemplateExercise(exercise: sampleExercises.first(where: { $0.name == "Leg Raise" })!, targetSets: 3, targetReps: 12)
            ]
        )
        
        self.templates = [upperBodyTemplate, lowerBodyTemplate, pushTemplate, pullTemplate, coreTemplate]
        saveTemplates()
    }
}
