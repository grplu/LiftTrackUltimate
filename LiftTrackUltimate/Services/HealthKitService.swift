import Foundation
import HealthKit
import Combine

class HealthKitService: NSObject, ObservableObject {
    static let shared = HealthKitService()
    
    private let healthStore = HKHealthStore()
    private let requiredTypes: Set<HKSampleType> = [
        HKObjectType.workoutType(),
        HKObjectType.quantityType(forIdentifier: .heartRate)!,
        HKObjectType.quantityType(forIdentifier: .activeEnergyBurned)!
    ]
    
    @Published private(set) var authorizationStatus: Bool = false
    @Published private(set) var currentHeartRate: Double?
    @Published private(set) var error: Error?
    
    private var heartRateQuery: HKQuery?
    private var cancellables = Set<AnyCancellable>()
    
    private override init() {
        super.init()
        checkAuthorizationStatus()
    }
    
    // MARK: - Authorization
    func requestAuthorization() {
        healthStore.requestAuthorization(toShare: nil, read: requiredTypes) { [weak self] success, error in
            DispatchQueue.main.async {
                self?.authorizationStatus = success
                self?.error = error
            }
        }
    }
    
    private func checkAuthorizationStatus() {
        let status = requiredTypes.map { healthStore.authorizationStatus(for: $0) }
        let authorized = status.allSatisfy { $0 == .sharingAuthorized }
        
        DispatchQueue.main.async {
            self.authorizationStatus = authorized
        }
    }
    
    // MARK: - Heart Rate Monitoring
    func startHeartRateMonitoring() {
        guard let heartRateType = HKObjectType.quantityType(forIdentifier: .heartRate) else { return }
        
        let query = HKAnchoredObjectQuery(
            type: heartRateType,
            predicate: nil,
            anchor: nil,
            limit: HKObjectQueryNoLimit
        ) { [weak self] query, samples, deletedObjects, anchor, error in
            self?.handleHeartRateSamples(samples)
        }
        
        query.updateHandler = { [weak self] query, samples, deletedObjects, anchor, error in
            self?.handleHeartRateSamples(samples)
        }
        
        healthStore.execute(query)
        heartRateQuery = query
    }
    
    func stopHeartRateMonitoring() {
        if let query = heartRateQuery {
            healthStore.stop(query)
            heartRateQuery = nil
        }
    }
    
    private func handleHeartRateSamples(_ samples: [HKSample]?) {
        guard let heartRateSamples = samples as? [HKQuantitySample] else { return }
        
        DispatchQueue.main.async {
            if let mostRecentSample = heartRateSamples.last {
                self.currentHeartRate = mostRecentSample.quantity.doubleValue(for: HKUnit.count().unitDivided(by: .minute()))
            }
        }
    }
    
    // MARK: - Workout Management
    func saveWorkout(_ workout: AppWorkout) async throws {
        guard authorizationStatus else {
            throw HealthKitError.notAuthorized
        }
        
        let configuration = HKWorkoutConfiguration()
        configuration.activityType = .traditionalStrengthTraining
        
        let startDate = workout.date
        let endDate = workout.date.addingTimeInterval(workout.duration)
        
        // Create a workout builder with the configuration
        let builder = HKWorkoutBuilder(healthStore: healthStore, configuration: configuration, device: nil)
        
        // Begin the workout builder
        try await builder.beginCollection(at: startDate)
        
        // End the workout builder
        try await builder.endCollection(at: endDate)
        
        // Add metadata
        try await builder.addMetadata([
            "workoutName": workout.name,
            "workoutId": workout.id.uuidString
        ])
        
        // Finish and save the workout
        try await builder.finishWorkout()
    }
    
    // MARK: - Statistics
    func fetchWorkoutStatistics(for period: DateInterval) async throws -> HealthKitWorkoutStatistics {
        guard authorizationStatus else {
            throw HealthKitError.notAuthorized
        }
        
        let workoutType = HKObjectType.workoutType()
        let predicate = HKQuery.predicateForSamples(withStart: period.start, end: period.end, options: .strictStartDate)
        
        let statistics: HealthKitWorkoutStatistics = try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<HealthKitWorkoutStatistics, Error>) in
            let query = HKSampleQuery(
                sampleType: workoutType,
                predicate: predicate,
                limit: HKObjectQueryNoLimit,
                sortDescriptors: [NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)]
            ) { _, samples, error in
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }
                
                let workouts = samples as? [HKWorkout] ?? []
                let stats = HealthKitWorkoutStatistics(
                    totalWorkouts: workouts.count,
                    totalDuration: workouts.reduce(0) { $0 + $1.duration },
                    totalCalories: workouts.reduce(0) { $0 + ($1.statistics(for: HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned)!)?.sumQuantity()?.doubleValue(for: .kilocalorie()) ?? 0) }
                )
                
                continuation.resume(returning: stats)
            }
            
            healthStore.execute(query)
        }
        
        return statistics
    }
} 