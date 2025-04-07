import Foundation
import Combine

class WorkoutViewModel: ObservableObject {
    private let dataService: DataService
    private var cancellables = Set<AnyCancellable>()
    
    @Published var workouts: [AppWorkout] = []
    @Published var currentWorkout: AppWorkout?
    @Published var isLoading = false
    @Published var error: Error?
    
    init(dataService: DataService = LocalDataService.shared) {
        self.dataService = dataService
        loadWorkouts()
    }
    
    // MARK: - Workout Management
    func loadWorkouts() {
        isLoading = true
        workouts = dataService.loadWorkouts()
        isLoading = false
    }
    
    func startWorkout(name: String, template: WorkoutTemplate? = nil) {
        let workout = AppWorkout(
            id: UUID(),
            name: name,
            date: Date(),
            duration: 0, // Will be updated as workout progresses
            exercises: template?.exercises.map { templateExercise in
                WorkoutExercise(
                    exercise: templateExercise.exercise,
                    sets: Array(repeating: ExerciseSet(weight: 0, reps: 0, completed: false), count: templateExercise.targetSets)
                )
            } ?? []
        )
        currentWorkout = workout
    }
    
    func saveWorkout() {
        guard let workout = currentWorkout else { return }
        dataService.saveWorkout(workout)
        loadWorkouts()
        currentWorkout = nil
    }
    
    func updateWorkout(_ workout: AppWorkout) {
        dataService.updateWorkout(workout)
        loadWorkouts()
    }
    
    func deleteWorkout(_ workout: AppWorkout) {
        dataService.deleteWorkout(workout)
        loadWorkouts()
    }
    
    // MARK: - Exercise Management
    func addSet(to exerciseIndex: Int) {
        guard var workout = currentWorkout else { return }
        guard workout.exercises.indices.contains(exerciseIndex) else { return }
        
        var exercise = workout.exercises[exerciseIndex]
        exercise.sets.append(ExerciseSet(weight: 0, reps: 0, completed: false))
        workout.exercises[exerciseIndex] = exercise
        currentWorkout = workout
    }
    
    func addExercise(_ exercise: Exercise) {
        guard var workout = currentWorkout else { return }
        
        let workoutExercise = WorkoutExercise(
            exercise: exercise,
            sets: [ExerciseSet(weight: 0, reps: 0, completed: false)]
        )
        
        workout.exercises.append(workoutExercise)
        currentWorkout = workout
    }
    
    func updateExerciseSet(_ exerciseIndex: Int, setIndex: Int, reps: Int, weight: Double, completed: Bool, formQuality: FormQuality = .good) {
        guard var workout = currentWorkout else { return }
        guard workout.exercises.indices.contains(exerciseIndex),
              workout.exercises[exerciseIndex].sets.indices.contains(setIndex) else { return }
        
        var exercise = workout.exercises[exerciseIndex]
        let updatedSet = ExerciseSet(
            weight: weight,
            reps: reps,
            completed: completed,
            formQuality: formQuality
        )
        exercise.sets[setIndex] = updatedSet
        workout.exercises[exerciseIndex] = exercise
        currentWorkout = workout
    }
    
    func removeExercise(at index: Int) {
        guard var workout = currentWorkout else { return }
        guard workout.exercises.indices.contains(index) else { return }
        workout.exercises.remove(at: index)
        currentWorkout = workout
    }
    
    // MARK: - Workout Statistics
    func getWorkoutStats(for workout: AppWorkout) -> WorkoutStats {
        // Calculate total weight lifted
        let totalWeight = workout.exercises.reduce(0.0) { total, exercise in
            total + exercise.sets.reduce(0.0) { $0 + ($1.weight ?? 0.0) }
        }
        
        // Create PersonalBests dictionary
        var personalBests: [String: Double] = [:]
        for exercise in workout.exercises {
            let maxWeight = exercise.sets.compactMap { $0.weight }.max() ?? 0.0
            if maxWeight > 0 {
                personalBests[exercise.exercise.name] = maxWeight
            }
        }
        
        var stats = WorkoutStats()
        stats.totalWorkouts = 1
        stats.totalDuration = workout.duration
        stats.caloriesBurned = 0 // Would need heart rate data for better estimate
        stats.averageHeartRate = 0 // Would come from HealthKit
        stats.personalBests = personalBests
        stats.totalWeight = totalWeight // Add the total weight to the stats
        
        return stats
    }
} 