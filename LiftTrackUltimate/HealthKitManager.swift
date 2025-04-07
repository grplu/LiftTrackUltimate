import HealthKit
import Foundation
import Combine

// Make HealthKitManager conform to Sendable
@MainActor
class HealthKitManager: ObservableObject, @unchecked Sendable {
    // Use a shared instance to avoid ambiguity
    static let shared = HealthKitManager()
    
    private let healthStore = HKHealthStore()
    
    // Types to read from and write to HealthKit
    private let typesToRead: Set<HKObjectType> = [
        HKObjectType.quantityType(forIdentifier: .heartRate)!,
        HKObjectType.quantityType(forIdentifier: .activeEnergyBurned)!,
        HKObjectType.workoutType()
    ]
    
    private let typesToWrite: Set<HKSampleType> = [
        HKObjectType.quantityType(forIdentifier: .activeEnergyBurned)!,
        HKObjectType.workoutType()
    ]
    
    // Published properties for UI binding
    @Published var isHealthKitAvailable = false
    @Published var isAuthorized = false
    @Published var authorizationStatus: HKAuthorizationStatus = .notDetermined
    @Published var recentWorkouts: [HKWorkout] = []
    @Published var workoutStats = WorkoutStatistics()
    
    // Private initializer to enforce singleton pattern
    private init() {
        checkHealthKitAvailability()
    }
    
    // MARK: - Setup and Authorization
    
    private func checkHealthKitAvailability() {
        isHealthKitAvailable = HKHealthStore.isHealthDataAvailable()
    }
    
    func requestAuthorization(completion: @escaping (Bool, Error?) -> Void = {_, _ in }) {
        // Check if HealthKit is available
        guard HKHealthStore.isHealthDataAvailable() else {
            DispatchQueue.main.async {
                self.isHealthKitAvailable = false
                completion(false, nil)
            }
            return
        }
        
        healthStore.requestAuthorization(toShare: typesToWrite, read: typesToRead) { [weak self] success, error in
            DispatchQueue.main.async {
                if success {
                    self?.isAuthorized = true
                    self?.getAuthorizationStatus()
                }
                completion(success, error)
            }
        }
    }
    
    func getAuthorizationStatus() {
        let workoutType = HKObjectType.workoutType()
        authorizationStatus = healthStore.authorizationStatus(for: workoutType)
        isAuthorized = authorizationStatus == .sharingAuthorized
    }
    
    // MARK: - Fetch Health Data
    
    func fetchRecentWorkouts(limit: Int = 10, completion: @escaping (Bool, Error?) -> Void) {
        // Create the predicate for date range (last 30 days)
        let calendar = Calendar.current
        let now = Date()
        let startDate = calendar.date(byAdding: .day, value: -30, to: now)!
        let datePredicate = HKQuery.predicateForSamples(withStart: startDate, end: now, options: .strictStartDate)
        
        // Create the workout predicate for strength training workouts
        let workoutPredicate = HKQuery.predicateForWorkouts(with: .traditionalStrengthTraining)
        
        // Combine the predicates
        let compoundPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [datePredicate, workoutPredicate])
        
        // Create the sort descriptor
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: false)
        
        // Create the query
        let query = HKSampleQuery(
            sampleType: HKObjectType.workoutType(),
            predicate: compoundPredicate,
            limit: limit,
            sortDescriptors: [sortDescriptor]
        ) { [weak self] (_, results, error) in
            guard let workouts = results as? [HKWorkout], error == nil else {
                DispatchQueue.main.async {
                    completion(false, error)
                }
                return
            }
            
            DispatchQueue.main.async {
                self?.recentWorkouts = workouts
                self?.calculateWorkoutStatistics(from: workouts)
                completion(true, nil)
            }
        }
        
        // Execute the query
        healthStore.execute(query)
    }
    
    private func calculateWorkoutStatistics(from workouts: [HKWorkout]) {
        let totalWorkouts = workouts.count
        var totalDuration: TimeInterval = 0
        var totalCalories: Double = 0
        var lastWorkoutDate: Date? = nil
        
        for workout in workouts {
            totalDuration += workout.duration
            
            if let calories = workout.statistics(for: HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned)!)?.sumQuantity()?.doubleValue(for: .kilocalorie()) {
                totalCalories += calories
            }
            
            if let currentLastWorkoutDate = lastWorkoutDate {
                if workout.endDate > currentLastWorkoutDate {
                    lastWorkoutDate = workout.endDate
                }
            } else {
                lastWorkoutDate = workout.endDate
            }
        }
        
        self.workoutStats = WorkoutStatistics(
            totalWorkouts: totalWorkouts,
            totalDuration: totalDuration,
            totalCalories: totalCalories,
            lastWorkoutDate: lastWorkoutDate
        )
    }
    
    // MARK: - Save Workout Data
    
    // New async throwing version that doesn't use completion handlers
    func saveWorkout(_ workout: AppWorkout) async throws {
        // Check if HealthKit is available and authorized
        guard isHealthKitAvailable, isAuthorized else {
            throw NSError(domain: "HealthKitManager", code: 1, userInfo: [NSLocalizedDescriptionKey: "HealthKit is not available or not authorized"])
        }
        
        // Create a proper HKWorkout to save to HealthKit
        let workoutConfiguration = HKWorkoutConfiguration()
        workoutConfiguration.activityType = .traditionalStrengthTraining
        workoutConfiguration.locationType = .indoor
        
        // Get start date from the workout
        let startDate = workout.date
        let endDate = Date(timeInterval: workout.duration, since: startDate)
        
        // Calculate calories based on workout duration
        var calories: HKQuantity? = nil
        let estimatedCalories = calculateEstimatedCalories(for: workout)
        if estimatedCalories > 0 {
            calories = HKQuantity(unit: .kilocalorie(), doubleValue: estimatedCalories)
        }
        
        // Create metadata
        var metadata: [String: Any] = [
            "com.lift.workoutId": workout.id.uuidString,
            "com.lift.workoutName": workout.name
        ]
        
        // Add exercises information if available
        if !workout.exercises.isEmpty {
            let exerciseNames = workout.exercises.map { $0.exercise.name }.joined(separator: ", ")
            metadata["com.lift.exercises"] = exerciseNames
        }
        
        // Add notes if available
        if let notes = workout.notes, !notes.isEmpty {
            metadata["com.lift.notes"] = notes
        }
        
        // Create workout builder
        let builder = HKWorkoutBuilder(healthStore: healthStore, configuration: workoutConfiguration, device: nil)
        
        // Begin collection
        try await builder.beginCollection(at: startDate)
        
        // Add active energy burned if available
        if let calories = calories {
            let energyQuantityType = HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned)!
            let energySample = HKQuantitySample(
                type: energyQuantityType,
                quantity: calories,
                start: startDate,
                end: endDate
            )
            
            // Use withCheckedThrowingContinuation to bridge async and completion handler approaches
            _ = try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Bool, Error>) in
                builder.add([energySample]) { success, error in
                    if let error = error {
                        continuation.resume(throwing: error)
                    } else {
                        continuation.resume(returning: success)
                    }
                }
            }
        }
        
        // End collection
        try await builder.endCollection(at: endDate)
        
        // Add metadata
        try await builder.addMetadata(metadata)
        
        // Finish the workout
        // Use withCheckedThrowingContinuation to bridge async and completion handler approaches 
        let workout = try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<HKWorkout, Error>) in
            builder.finishWorkout { workout, error in
                if let error = error {
                    continuation.resume(throwing: error)
                } else if let workout = workout {
                    continuation.resume(returning: workout)
                } else {
                    continuation.resume(throwing: NSError(domain: "HealthKitManager", code: 1, userInfo: [NSLocalizedDescriptionKey: "Unknown error finishing workout"]))
                }
            }
        }
        
        // Success - refresh the recent workouts list
        await self.fetchRecentWorkouts(completion: { _, _ in })
        
        return
    }
    
    // Keep the completion handler version for backward compatibility
    func saveWorkout(_ workout: AppWorkout, completion: @escaping (Bool, Error?) -> Void = {_, _ in }) {
        // Check if HealthKit is available and authorized
        guard isHealthKitAvailable, isAuthorized else {
            // If HealthKit is not available or not authorized, just return without error
            completion(false, nil)
            return
        }
        
        // Create a proper HKWorkout to save to HealthKit
        let workoutConfiguration = HKWorkoutConfiguration()
        workoutConfiguration.activityType = .traditionalStrengthTraining
        workoutConfiguration.locationType = .indoor
        
        // Get start date from the workout
        let startDate = workout.date
        let endDate = Date(timeInterval: workout.duration, since: startDate)
        
        // Calculate calories based on workout duration
        var calories: HKQuantity? = nil
        let estimatedCalories = calculateEstimatedCalories(for: workout)
        if estimatedCalories > 0 {
            calories = HKQuantity(unit: .kilocalorie(), doubleValue: estimatedCalories)
        }
        
        // Create metadata
        var metadata: [String: Any] = [
            "com.lift.workoutId": workout.id.uuidString,
            "com.lift.workoutName": workout.name
        ]
        
        // Add exercises information if available
        if !workout.exercises.isEmpty {
            let exerciseNames = workout.exercises.map { $0.exercise.name }.joined(separator: ", ")
            metadata["com.lift.exercises"] = exerciseNames
        }
        
        // Add notes if available
        if let notes = workout.notes, !notes.isEmpty {
            metadata["com.lift.notes"] = notes
        }
        
        // Create workout builder
        let builder = HKWorkoutBuilder(healthStore: healthStore, configuration: workoutConfiguration, device: nil)
        
        // Use Task to manage async operations without mixing async/await with completion handlers
        Task {
            do {
                // Begin collection
                try await builder.beginCollection(at: startDate)
                
                // Add active energy burned if available
                if let calories = calories {
                    let energyQuantityType = HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned)!
                    let energySample = HKQuantitySample(
                        type: energyQuantityType,
                        quantity: calories,
                        start: startDate,
                        end: endDate
                    )
                    
                    // Use withCheckedThrowingContinuation to bridge async and completion handler approaches
                    _ = try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Bool, Error>) in
                        builder.add([energySample]) { success, error in
                            if let error = error {
                                continuation.resume(throwing: error)
                            } else {
                                continuation.resume(returning: success)
                            }
                        }
                    }
                }
                
                // End collection
                try await builder.endCollection(at: endDate)
                
                // Add metadata
                try await builder.addMetadata(metadata)
                
                // Finish the workout
                // Use withCheckedThrowingContinuation to bridge async and completion handler approaches 
                _ = try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<HKWorkout, Error>) in
                    builder.finishWorkout { workout, error in
                        if let error = error {
                            continuation.resume(throwing: error)
                        } else if let workout = workout {
                            continuation.resume(returning: workout)
                        } else {
                            continuation.resume(throwing: NSError(domain: "HealthKitManager", code: 1, userInfo: [NSLocalizedDescriptionKey: "Unknown error finishing workout"]))
                        }
                    }
                }
                
                // Success path
                DispatchQueue.main.async { [weak self] in
                    guard let self = self else { return }
                    
                    // Use Task.detached to avoid capturing self directly
                    Task.detached {
                        // Capture only what's needed from self
                        await MainActor.run {
                            self.fetchRecentWorkouts(completion: { _, _ in })
                            completion(true, nil)
                        }
                    }
                }
            } catch {
                // Error path
                DispatchQueue.main.async {
                    // Use Task to keep consistency with the success path
                    Task.detached {
                        await MainActor.run {
                            completion(false, error)
                        }
                    }
                }
            }
        }
    }
    
    // MARK: - Heart Rate Monitoring
    
    func startHeartRateQuery(quantityTypeIdentifier: HKQuantityTypeIdentifier, completion: @escaping (Double) -> Void) async {
        // Ensure HealthKit is available and authorized
        guard HKHealthStore.isHealthDataAvailable() else { return }
        
        let heartRateType = HKObjectType.quantityType(forIdentifier: quantityTypeIdentifier)!
        
        // Predicate to get recent heart rate samples (last 5 minutes)
        let predicate = HKQuery.predicateForSamples(
            withStart: Date().addingTimeInterval(-300),
            end: Date(),
            options: .strictStartDate
        )
        
        // Sort descriptor to get the most recent sample
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)
        
        // Use Task-based approach to execute the query
        Task { @MainActor in
            // Create a sample query to fetch the most recent heart rate
            let query = HKSampleQuery(
                sampleType: heartRateType,
                predicate: predicate,
                limit: 1,
                sortDescriptors: [sortDescriptor]
            ) { (query, samples, error) in
                guard let samples = samples as? [HKQuantitySample], !samples.isEmpty else {
                    return
                }
                
                let heartRateUnit = HKUnit.count().unitDivided(by: HKUnit.minute())
                let heartRate = samples.first!.quantity.doubleValue(for: heartRateUnit)
                
                completion(heartRate)
            }
            
            // Execute the query
            self.healthStore.execute(query)
        }
    }
    
    // MARK: - Continuous Heart Rate Monitoring
    
    func setupContinuousHeartRateObserver(updateHandler: @escaping (Double) -> Void) async -> HKQuery {
        // Ensure HealthKit is available and authorized
        guard HKHealthStore.isHealthDataAvailable() else {
            // Create a dummy query that won't do anything
            let heartRateType = HKObjectType.quantityType(forIdentifier: .heartRate)!
            return HKObserverQuery(sampleType: heartRateType, predicate: nil) { _, _, _ in }
        }
        
        let heartRateType = HKObjectType.quantityType(forIdentifier: .heartRate)!
        
        // Create an anchor date 1 minute in the past
        let anchorDate = Date().addingTimeInterval(-60)
        let predicate = HKQuery.predicateForSamples(withStart: anchorDate, end: nil, options: .strictEndDate)
        
        // Set up a continuous query
        let query = HKAnchoredObjectQuery(
            type: heartRateType,
            predicate: predicate,
            anchor: nil,
            limit: HKObjectQueryNoLimit
        ) { (query, samples, deletedObjects, anchor, error) in
            // Initial query results handler
            guard let samples = samples as? [HKQuantitySample], !samples.isEmpty else {
                return
            }
            
            // Use Task to dispatch to MainActor
            Task { @MainActor in
                self.processHeartRateSamples(samples, updateHandler: updateHandler)
            }
        }
        
        // Set up continuous updates
        query.updateHandler = { (query, samples, deletedObjects, anchor, error) in
            guard let samples = samples as? [HKQuantitySample], !samples.isEmpty else {
                return
            }
            
            // Instead of directly calling actor-isolated method, use Task
            Task { @MainActor in
                self.processHeartRateSamples(samples, updateHandler: updateHandler)
            }
        }
        
        // Execute the query
        healthStore.execute(query)
        
        return query
    }
    
    private func processHeartRateSamples(_ samples: [HKQuantitySample], updateHandler: @escaping (Double) -> Void) {
        // No need for DispatchQueue.main.async here as we're now always called from MainActor context
        // Process the new heart rate samples
        let heartRateUnit = HKUnit.count().unitDivided(by: HKUnit.minute())
        
        // Get the most recent sample
        if let mostRecentSample = samples.last {
            let heartRate = mostRecentSample.quantity.doubleValue(for: heartRateUnit)
            updateHandler(heartRate)
        }
    }
    
    func stopQuery(_ query: HKQuery) {
        healthStore.stop(query)
    }
    
    // MARK: - Utility Functions
    
    // Calculate estimated calories for a workout
    private func calculateEstimatedCalories(for workout: AppWorkout) -> Double {
        // Get workout duration in hours
        let durationHours = workout.duration / 3600
        
        // MET value for strength training is typically 3.5-5.0
        let metValue: Double = 4.0
        
        // Assume a default weight of 70kg if not available
        // In a real app, you'd get this from the user profile
        let weight: Double = 70
        
        // Estimated calories = MET × Weight (kg) × Duration (hours)
        return metValue * weight * durationHours
    }
    
    func formattedDuration(from timeInterval: TimeInterval) -> String {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.hour, .minute]
        formatter.unitsStyle = .abbreviated
        return formatter.string(from: timeInterval) ?? "0m"
    }
    
    func formattedDate(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
    
    // Non-actor-isolated method that can be safely called from deinit
    nonisolated func safeStopQuery(_ query: HKQuery) {
        // This is safe to call from any context since HKHealthStore.stop is thread-safe
        let healthStore = HKHealthStore()
        healthStore.stop(query)
    }
}
