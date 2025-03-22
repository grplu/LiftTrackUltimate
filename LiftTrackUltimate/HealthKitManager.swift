import HealthKit
import Foundation
import Combine

class HealthKitManager: ObservableObject {
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
    @Published var workoutStats: WorkoutStatistics = WorkoutStatistics()
    
    // Struct to hold workout statistics
    struct WorkoutStatistics {
        var totalWorkouts: Int = 0
        var totalDuration: TimeInterval = 0
        var totalCalories: Double = 0
        var lastWorkoutDate: Date? = nil
    }
    
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
        var stats = WorkoutStatistics()
        
        stats.totalWorkouts = workouts.count
        
        for workout in workouts {
            stats.totalDuration += workout.duration
            
            if let calories = workout.totalEnergyBurned?.doubleValue(for: .kilocalorie()) {
                stats.totalCalories += calories
            }
            
            if let lastWorkoutDate = stats.lastWorkoutDate {
                if workout.endDate > lastWorkoutDate {
                    stats.lastWorkoutDate = workout.endDate
                }
            } else {
                stats.lastWorkoutDate = workout.endDate
            }
        }
        
        self.workoutStats = stats
    }
    
    // MARK: - Save Workout Data
    
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
        
        // Create the HKWorkout object
        let hkWorkout = HKWorkout(
            activityType: .traditionalStrengthTraining,
            start: startDate,
            end: endDate,
            duration: workout.duration,
            totalEnergyBurned: calories,
            totalDistance: nil,
            metadata: metadata
        )
        
        // Save to HealthKit
        healthStore.save(hkWorkout) { [weak self] (success, error) in
            DispatchQueue.main.async {
                if success {
                    // Refresh the list of workouts
                    self?.fetchRecentWorkouts(completion: { _, _ in })
                }
                completion(success, error)
            }
        }
    }
    
    // MARK: - Heart Rate Monitoring
    
    func startHeartRateQuery(quantityTypeIdentifier: HKQuantityTypeIdentifier, completion: @escaping (Double) -> Void) {
        let devicePredicate = HKQuery.predicateForObjects(from: [HKDevice.local()])
        let updateHandler: (HKAnchoredObjectQuery, [HKSample]?, [HKDeletedObject]?, HKQueryAnchor?, Error?) -> Void = {
            query, samples, deletedObjects, queryAnchor, error in
            
            guard let samples = samples as? [HKQuantitySample] else { return }
            
            DispatchQueue.main.async {
                for sample in samples {
                    let heartRateUnit = HKUnit.count().unitDivided(by: HKUnit.minute())
                    let heartRate = sample.quantity.doubleValue(for: heartRateUnit)
                    completion(heartRate)
                }
            }
        }
        
        let heartRateType = HKObjectType.quantityType(forIdentifier: quantityTypeIdentifier)!
        
        let query = HKAnchoredObjectQuery(
            type: heartRateType,
            predicate: devicePredicate,
            anchor: nil,
            limit: HKObjectQueryNoLimit,
            resultsHandler: updateHandler
        )
        
        query.updateHandler = updateHandler
        
        // Execute the heart rate query
        healthStore.execute(query)
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
}
