import Foundation
import SwiftUI
import Combine

// Define notification names for workout session events
extension Notification.Name {
    static let workoutSessionUpdated = Notification.Name("workoutSessionUpdated")
    static let workoutSessionPaused = Notification.Name("workoutSessionPaused")
    static let workoutSessionResumed = Notification.Name("workoutSessionResumed")
    static let workoutSessionCompleted = Notification.Name("workoutSessionCompleted")
}

class WorkoutSessionManager: ObservableObject {
    static let shared = WorkoutSessionManager()
    
    // Published properties
    @Published var isWorkoutActive: Bool = false
    @Published var workoutName: String = "Quick Workout"
    @Published var startTime: Date = Date()
    @Published var elapsedTime: TimeInterval = 0
    @Published var isTimerPaused: Bool = false
    @Published var exercises: [WorkoutExercise] = []
    @Published var heartRate: Int = Int.random(in: 65...85) // Mock heart rate
    
    // Private properties
    private var timer: Timer? = nil
    private var heartRateTimer: Timer? = nil
    private var backgroundTask: UIBackgroundTaskIdentifier = .invalid
    private var lastTimestamp: Date? = nil
    
    // Timer update frequency (in seconds)
    private let timerInterval: TimeInterval = 1.0
    
    private init() {
        // Add app lifecycle observers
        setupAppLifecycleObservers()
    }
    
    // MARK: - Public Methods
    
    /// Start a new workout session
    func startWorkout(template: WorkoutTemplate? = nil) {
        // Reset and initialize workout state
        if let template = template {
            workoutName = template.name
        } else {
            workoutName = "Quick Workout"
        }
        
        startTime = Date()
        elapsedTime = 0
        isTimerPaused = false
        exercises = []
        
        // Initialize workout from template if provided
        if let template = template {
            initializeFromTemplate(template)
        }
        
        // Start timers
        startTimers()
        
        // Set workout as active
        isWorkoutActive = true
        
        // Notify observers
        NotificationCenter.default.post(name: .workoutSessionUpdated, object: nil)
    }
    
    /// Pause the current workout session
    func pauseWorkout() {
        guard isWorkoutActive else { return }
        
        isTimerPaused = true
        stopTimers()
        
        // Notify observers
        NotificationCenter.default.post(name: .workoutSessionPaused, object: nil)
    }
    
    /// Resume the paused workout session
    func resumeWorkout() {
        guard isWorkoutActive && isTimerPaused else { return }
        
        isTimerPaused = false
        startTimers()
        
        // Notify observers
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
    func completeWorkout(dataManager: DataManager) {
        guard isWorkoutActive else { return }
        
        // Stop timers
        stopTimers()
        
        // Create the completed workout
        let completedWorkout = AppWorkout(
            id: UUID(),
            name: workoutName,
            date: startTime,
            duration: elapsedTime,
            exercises: exercises
        )
        
        // Save the workout data
        dataManager.saveWorkout(completedWorkout)
        
        // Save performance data for each exercise
        for exercise in exercises {
            dataManager.saveExercisePerformance(from: exercise)
        }
        
        // Reset workout state
        resetWorkoutState()
        
        // Notify observers
        NotificationCenter.default.post(name: .workoutSessionCompleted, object: nil)
    }
    
    /// Cancel the current workout without saving
    func cancelWorkout() {
        guard isWorkoutActive else { return }
        
        // Stop timers
        stopTimers()
        
        // Reset workout state
        resetWorkoutState()
        
        // Notify observers (using the same notification as completion for simplicity)
        NotificationCenter.default.post(name: .workoutSessionCompleted, object: nil)
    }
    
    /// Add an exercise to the current workout
    func addExercise(_ exercise: Exercise) {
        // Default to 3 sets of 10 reps
        let sets = [
            ExerciseSet(reps: 10, weight: nil),
            ExerciseSet(reps: 10, weight: nil),
            ExerciseSet(reps: 10, weight: nil)
        ]
        
        let workoutExercise = WorkoutExercise(exercise: exercise, sets: sets)
        exercises.append(workoutExercise)
        
        // Notify observers
        NotificationCenter.default.post(name: .workoutSessionUpdated, object: nil)
    }
    
    /// Add a set to an exercise
    func addSet(to exercise: WorkoutExercise) {
        if let index = exercises.firstIndex(where: { $0.id == exercise.id }) {
            // Get the last set (if any)
            let lastSet = exercises[index].sets.last
            
            // Create new set with parameters from last set
            let reps = lastSet?.reps ?? 10
            let weight = lastSet?.weight
            
            let newSet = ExerciseSet(reps: reps, weight: weight)
            
            exercises[index].sets.append(newSet)
            
            // Notify observers
            NotificationCenter.default.post(name: .workoutSessionUpdated, object: nil)
        }
    }
    
    /// Toggle completion status of a set
    func toggleSetCompletion(for exercise: WorkoutExercise, setIndex: Int, isComplete: Bool) {
        if let exerciseIndex = exercises.firstIndex(where: { $0.id == exercise.id }),
           setIndex < exercises[exerciseIndex].sets.count {
            exercises[exerciseIndex].sets[setIndex].completed = isComplete
            
            // Notify observers
            NotificationCenter.default.post(name: .workoutSessionUpdated, object: nil)
        }
    }
    
    /// Update weight for a set
    func updateWeight(for exercise: WorkoutExercise, setIndex: Int, weight: Double?) {
        if let exerciseIndex = exercises.firstIndex(where: { $0.id == exercise.id }),
           setIndex < exercises[exerciseIndex].sets.count {
            exercises[exerciseIndex].sets[setIndex].weight = weight
            
            // Notify observers
            NotificationCenter.default.post(name: .workoutSessionUpdated, object: nil)
        }
    }
    
    /// Update reps for a set
    func updateReps(for exercise: WorkoutExercise, setIndex: Int, reps: Int?) {
        if let exerciseIndex = exercises.firstIndex(where: { $0.id == exercise.id }),
           setIndex < exercises[exerciseIndex].sets.count {
            exercises[exerciseIndex].sets[setIndex].reps = reps
            
            // Notify observers
            NotificationCenter.default.post(name: .workoutSessionUpdated, object: nil)
        }
    }
    
    // MARK: - Private Methods
    
    /// Initialize workout from template
    private func initializeFromTemplate(_ template: WorkoutTemplate) {
        // Set workout name from template
        workoutName = template.name
        
        // Create workout exercises from template
        for templateExercise in template.exercises {
            var exerciseSets: [ExerciseSet] = []
            
            for i in 0..<templateExercise.targetSets {
                // CHANGED: Get specific set data from the DataManager instead of just the default values
                let dataManager = DataManager.shared
                
                // Try to get the specific reps used for this set in the past
                let reps = dataManager.getSetReps(for: templateExercise.exercise, setIndex: i) ?? templateExercise.targetReps ?? 10
                
                // Try to get the specific weight used for this set in the past
                let weight = dataManager.getSetWeight(for: templateExercise.exercise, setIndex: i)
                
                // Create a new set with historical values (or defaults if not available)
                let newSet = ExerciseSet(reps: reps, weight: weight)
                exerciseSets.append(newSet)
            }
            
            let workoutExercise = WorkoutExercise(exercise: templateExercise.exercise, sets: exerciseSets)
            exercises.append(workoutExercise)
        }
    }
    
    /// Start timer and heart rate simulation
    private func startTimers() {
        // Start main timer
        lastTimestamp = Date()
        timer = Timer.scheduledTimer(withTimeInterval: timerInterval, repeats: true) { [weak self] _ in
            guard let self = self, !self.isTimerPaused else { return }
            
            // Calculate elapsed time since last update
            let now = Date()
            if let lastTimestamp = self.lastTimestamp {
                let timeSinceLastUpdate = now.timeIntervalSince(lastTimestamp)
                self.elapsedTime += timeSinceLastUpdate
            }
            self.lastTimestamp = now
            
            // Notify observers
            NotificationCenter.default.post(name: .workoutSessionUpdated, object: nil)
        }
        
        // Make sure timer runs even when scrolling
        RunLoop.current.add(timer!, forMode: .common)
        
        // Start heart rate simulation
        heartRateTimer = Timer.scheduledTimer(withTimeInterval: 3.0, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            // Simulate slight heart rate changes
            self.heartRate = max(60, min(180, self.heartRate + Int.random(in: -3...5)))
            
            // Notify observers
            NotificationCenter.default.post(name: .workoutSessionUpdated, object: nil)
        }
        
        // Make heart rate timer run even when scrolling
        RunLoop.current.add(heartRateTimer!, forMode: .common)
    }
    
    /// Stop all timers
    private func stopTimers() {
        // Update elapsed time one final time
        if let lastTimestamp = lastTimestamp, !isTimerPaused {
            let now = Date()
            let timeSinceLastUpdate = now.timeIntervalSince(lastTimestamp)
            elapsedTime += timeSinceLastUpdate
        }
        
        // Invalidate timers
        timer?.invalidate()
        timer = nil
        
        heartRateTimer?.invalidate()
        heartRateTimer = nil
        
        lastTimestamp = nil
    }
    
    /// Reset the workout state
    private func resetWorkoutState() {
        isWorkoutActive = false
        isTimerPaused = false
        elapsedTime = 0
        exercises = []
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
        // When app is no longer active (switching apps, receiving call, etc.)
        print("App will resign active - ensuring workout session state is saved")
        
        // Store current timestamp for accurate time tracking
        lastTimestamp = Date()
    }
    
    @objc private func appDidBecomeActive() {
        // When app becomes active again
        print("App did become active - resuming workout session if active")
        
        if isWorkoutActive && !isTimerPaused {
            // Calculate elapsed time since last timestamp
            if let lastTimestamp = lastTimestamp {
                let now = Date()
                let additionalTime = now.timeIntervalSince(lastTimestamp)
                elapsedTime += additionalTime
                self.lastTimestamp = now
                
                // Notify observers
                NotificationCenter.default.post(name: .workoutSessionUpdated, object: nil)
            }
        }
    }
    
    @objc private func appDidEnterBackground() {
        // When app enters background
        print("App did enter background - beginning background task for workout session")
        
        // Start background task to get additional execution time
        beginBackgroundTask()
        
        // Store current timestamp
        lastTimestamp = Date()
    }
    
    @objc private func appWillEnterForeground() {
        // When app will enter foreground
        print("App will enter foreground - updating workout session time")
        
        if isWorkoutActive && !isTimerPaused {
            // Calculate elapsed time since last timestamp
            if let lastTimestamp = lastTimestamp {
                let now = Date()
                let additionalTime = now.timeIntervalSince(lastTimestamp)
                elapsedTime += additionalTime
                self.lastTimestamp = now
                
                // Notify observers
                NotificationCenter.default.post(name: .workoutSessionUpdated, object: nil)
            }
        }
        
        // End background task if one was started
        endBackgroundTask()
    }
    
    // MARK: - Background Task Management
    
    /// Begin a background task to keep timing accurate
    private func beginBackgroundTask() {
        // End any existing background task first
        endBackgroundTask()
        
        // Start a new background task
        backgroundTask = UIApplication.shared.beginBackgroundTask { [weak self] in
            // Time expired, end the task
            self?.endBackgroundTask()
        }
    }
    
    /// End the current background task
    private func endBackgroundTask() {
        // Only end the task if it's valid
        if backgroundTask != .invalid {
            UIApplication.shared.endBackgroundTask(backgroundTask)
            backgroundTask = .invalid
        }
    }
}
