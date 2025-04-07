import Foundation
import SwiftUI
import Combine
import UIKit

// Define notification names for workout session events
extension Notification.Name {
    static let workoutSessionUpdated = Notification.Name("workoutSessionUpdated")
    static let workoutSessionPaused = Notification.Name("workoutSessionPaused")
    static let workoutSessionResumed = Notification.Name("workoutSessionResumed")
    static let workoutSessionCompleted = Notification.Name("workoutSessionCompleted")
}

class WorkoutSessionManager: ObservableObject {
    static let shared = WorkoutSessionManager()
    
    private let dataService: DataService
    private var cancellables = Set<AnyCancellable>()
    
    // Published properties
    @Published var isActive = false
    @Published var workoutName: String = "Quick Workout"
    @Published var startTime: Date?
    @Published var elapsedTime: TimeInterval = 0
    @Published var isTimerPaused = false
    @Published var exercises: [WorkoutExercise] = []
    @Published var currentRestTimer: TimeInterval?
    @Published var error: Error?
    @Published var heartRate: Int = 70 // Default heart rate
    
    // Timer properties
    private var timer: Timer?
    private var heartRateTimer: Timer?
    private var lastTimestamp: Date?
    private var backgroundTask: UIBackgroundTaskIdentifier = .invalid
    
    init(dataService: DataService = LocalDataService.shared) {
        self.dataService = dataService
        setupAppLifecycleObservers()
    }
    
    // MARK: - Public Methods
    
    /// Start a new workout session
    func startWorkout(name: String? = nil, template: WorkoutTemplate? = nil) {
        resetWorkoutState()
        
        if let name = name {
            workoutName = name
        }
        
        if let template = template {
            initializeFromTemplate(template)
        }
        
        isActive = true
        startTime = Date()
        startTimers()
        
        NotificationCenter.default.post(name: .workoutSessionUpdated, object: nil)
    }
    
    /// Pause the current workout session
    func pauseWorkout() {
        isTimerPaused = true
        stopTimers()
        NotificationCenter.default.post(name: .workoutSessionPaused, object: nil)
    }
    
    /// Resume the paused workout session
    func resumeWorkout() {
        isTimerPaused = false
        startTimers()
        NotificationCenter.default.post(name: .workoutSessionResumed, object: nil)
    }
    
    /// Toggle between pause and resume
    func togglePause() {
        if isTimerPaused {
            resumeWorkout()
        } else {
            pauseWorkout()
        }
    }
    
    /// Complete and save the current workout
    func completeWorkout() {
        guard isActive else { return }
        
        let workout = AppWorkout(
            name: workoutName,
            date: startTime ?? Date(),
            duration: elapsedTime,
            exercises: exercises
        )
        
        // Save the workout directly without try-catch since it doesn't throw
        dataService.saveWorkout(workout)
        resetWorkoutState()
        NotificationCenter.default.post(name: .workoutSessionCompleted, object: nil)
    }
    
    /// Cancel the current workout without saving
    func cancelWorkout() {
        resetWorkoutState()
    }
    
    /// Add an exercise to the current workout
    func addExercise(_ exercise: Exercise) {
        let workoutExercise = WorkoutExercise(exercise: exercise)
        exercises.append(workoutExercise)
        NotificationCenter.default.post(name: .workoutSessionUpdated, object: nil)
    }
    
    /// Remove an exercise from the current workout
    func removeExercise(at index: Int) {
        guard exercises.indices.contains(index) else { return }
        exercises.remove(at: index)
        NotificationCenter.default.post(name: .workoutSessionUpdated, object: nil)
    }
    
    /// Move an exercise from one position to another
    func moveExercise(from source: Int, to destination: Int) {
        guard source != destination,
              exercises.indices.contains(source),
              exercises.indices.contains(destination) else { return }
        
        let exercise = exercises.remove(at: source)
        exercises.insert(exercise, at: destination)
        NotificationCenter.default.post(name: .workoutSessionUpdated, object: nil)
    }
    
    /// Update a set in an exercise
    func updateSet(_ set: ExerciseSet, at setIndex: Int, in exerciseIndex: Int) {
        guard exercises.indices.contains(exerciseIndex),
              exercises[exerciseIndex].sets.indices.contains(setIndex) else { return }
        
        exercises[exerciseIndex].sets[setIndex] = set
        NotificationCenter.default.post(name: .workoutSessionUpdated, object: nil)
    }
    
    /// Add a set to an exercise
    func addSet(to exerciseIndex: Int) {
        guard exercises.indices.contains(exerciseIndex) else { return }
        
        let lastSet = exercises[exerciseIndex].sets.last
        let newSet = ExerciseSet(
            weight: lastSet?.weight,
            reps: lastSet?.reps ?? 10,
            completed: false,
            formQuality: .good
        )
        
        exercises[exerciseIndex].sets.append(newSet)
        NotificationCenter.default.post(name: .workoutSessionUpdated, object: nil)
    }
    
    /// Remove a set from an exercise
    func removeSet(at setIndex: Int, from exerciseIndex: Int) {
        guard exercises.indices.contains(exerciseIndex),
              exercises[exerciseIndex].sets.indices.contains(setIndex),
              exercises[exerciseIndex].sets.count > 1 else { return }
        
        exercises[exerciseIndex].sets.remove(at: setIndex)
        NotificationCenter.default.post(name: .workoutSessionUpdated, object: nil)
    }
    
    /// Toggle completion status of a set
    func toggleSetCompletion(for exerciseIndex: Int, setIndex: Int) {
        guard exercises.indices.contains(exerciseIndex),
              exercises[exerciseIndex].sets.indices.contains(setIndex) else { return }
        
        exercises[exerciseIndex].sets[setIndex].completed.toggle()
        NotificationCenter.default.post(name: .workoutSessionUpdated, object: nil)
    }
    
    /// Update weight for a set
    func updateWeight(_ weight: Double?, for exerciseIndex: Int, setIndex: Int) {
        guard exercises.indices.contains(exerciseIndex),
              exercises[exerciseIndex].sets.indices.contains(setIndex) else { return }
        
        exercises[exerciseIndex].sets[setIndex].weight = weight
        NotificationCenter.default.post(name: .workoutSessionUpdated, object: nil)
    }
    
    /// Update reps for a set
    func updateReps(_ reps: Int, for exerciseIndex: Int, setIndex: Int) {
        guard exercises.indices.contains(exerciseIndex),
              exercises[exerciseIndex].sets.indices.contains(setIndex) else { return }
        
        exercises[exerciseIndex].sets[setIndex].reps = reps
        NotificationCenter.default.post(name: .workoutSessionUpdated, object: nil)
    }
    
    /// Update form quality for a set
    func updateFormQuality(_ quality: FormQuality, for exerciseIndex: Int, setIndex: Int) {
        guard exercises.indices.contains(exerciseIndex),
              exercises[exerciseIndex].sets.indices.contains(setIndex) else { return }
        
        exercises[exerciseIndex].sets[setIndex].formQuality = quality
        NotificationCenter.default.post(name: .workoutSessionUpdated, object: nil)
    }
    
    /// Update elapsed time manually (for when the app comes back from background)
    func updateElapsedTime(_ newElapsedTime: TimeInterval) {
        elapsedTime = newElapsedTime
        NotificationCenter.default.post(name: .workoutSessionUpdated, object: nil)
    }
    
    // MARK: - Private Methods
    
    /// Initialize workout from template
    private func initializeFromTemplate(_ template: WorkoutTemplate) {
        // Set workout name from template
        workoutName = template.name
        
        // Create workout exercises from template
        for templateExercise in template.exercises {
            var exerciseSets: [ExerciseSet] = []
            
            for _ in 0..<templateExercise.targetSets {
                // Use default values if DataManager is not available
                let reps = templateExercise.targetReps ?? 10
                let weight: Double? = nil
                
                // Create a new set with default values
                let newSet = ExerciseSet(
                    weight: weight,
                    reps: reps,
                    completed: false,
                    formQuality: .good
                )
                exerciseSets.append(newSet)
            }
            
            let workoutExercise = WorkoutExercise(exercise: templateExercise.exercise, sets: exerciseSets)
            exercises.append(workoutExercise)
        }
    }
    
    /// Start timer and heart rate simulation
    private func startTimers() {
        lastTimestamp = Date()
        
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.updateElapsedTime()
        }
        
        RunLoop.current.add(timer!, forMode: .common)
        
        // Start heart rate simulation
        heartRateTimer = Timer.scheduledTimer(withTimeInterval: 3.0, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            // Simulate slight heart rate changes
            self.heartRate = max(60, min(180, self.heartRate + Int.random(in: -3...5)))
            NotificationCenter.default.post(name: .workoutSessionUpdated, object: nil)
        }
        
        RunLoop.current.add(heartRateTimer!, forMode: .common)
    }
    
    /// Stop all timers
    private func stopTimers() {
        // Update elapsed time one final time
        if let lastTimestamp = lastTimestamp, !isTimerPaused {
            let now = Date()
            elapsedTime += now.timeIntervalSince(lastTimestamp)
        }
        
        timer?.invalidate()
        timer = nil
        
        heartRateTimer?.invalidate()
        heartRateTimer = nil
        
        lastTimestamp = nil
    }
    
    /// Reset the workout state
    private func resetWorkoutState() {
        isActive = false
        isTimerPaused = false
        workoutName = "Quick Workout"
        startTime = nil
        elapsedTime = 0
        exercises = []
        currentRestTimer = nil
        stopTimers()
    }
    
    // MARK: - App Lifecycle Management
    
    /// Setup observers for app lifecycle events
    private func setupAppLifecycleObservers() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(appWillResignActive),
            name: UIApplication.willResignActiveNotification,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(appDidBecomeActive),
            name: UIApplication.didBecomeActiveNotification,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(appDidEnterBackground),
            name: UIApplication.didEnterBackgroundNotification,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(appWillEnterForeground),
            name: UIApplication.willEnterForegroundNotification,
            object: nil
        )
    }
    
    @objc private func appWillResignActive() {
        print("App will resign active - ensuring workout session state is saved")
        lastTimestamp = Date()
        beginBackgroundTask()
    }
    
    @objc private func appDidBecomeActive() {
        print("App did become active - resuming workout session if active")
        
        if isActive && !isTimerPaused {
            if let lastTimestamp = lastTimestamp {
                let now = Date()
                elapsedTime += now.timeIntervalSince(lastTimestamp)
                self.lastTimestamp = now
                NotificationCenter.default.post(name: .workoutSessionUpdated, object: nil)
            }
        }
        
        endBackgroundTask()
    }
    
    @objc private func appDidEnterBackground() {
        print("App did enter background - beginning background task for workout session")
        beginBackgroundTask()
        lastTimestamp = Date()
    }
    
    @objc private func appWillEnterForeground() {
        print("App will enter foreground - updating workout session time")
        
        if isActive && !isTimerPaused {
            if let lastTimestamp = lastTimestamp {
                let now = Date()
                elapsedTime += now.timeIntervalSince(lastTimestamp)
                self.lastTimestamp = now
                NotificationCenter.default.post(name: .workoutSessionUpdated, object: nil)
            }
        }
        
        endBackgroundTask()
    }
    
    // MARK: - Timer Management
    
    /// Update the elapsed time for the timer
    private func updateElapsedTime() {
        guard isActive, !isTimerPaused, let lastTimestamp = lastTimestamp else { return }
        
        let now = Date()
        elapsedTime += now.timeIntervalSince(lastTimestamp)
        self.lastTimestamp = now
        
        NotificationCenter.default.post(name: .workoutSessionUpdated, object: nil)
    }
    
    // MARK: - Background Task Management
    
    /// Begin a background task to keep timing accurate
    private func beginBackgroundTask() {
        endBackgroundTask()
        
        backgroundTask = UIApplication.shared.beginBackgroundTask { [weak self] in
            self?.endBackgroundTask()
        }
    }
    
    /// End the current background task
    private func endBackgroundTask() {
        guard backgroundTask != .invalid else { return }
        UIApplication.shared.endBackgroundTask(backgroundTask)
        backgroundTask = .invalid
    }
}
