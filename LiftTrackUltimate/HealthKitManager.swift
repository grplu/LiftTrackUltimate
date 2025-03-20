import HealthKit
import Foundation

class HealthKitManager {
    // Use a different pattern for the shared instance to avoid ambiguity
    static let shared = HealthKitManager()
    
    private let healthStore = HKHealthStore()
    private let typesToRead: Set<HKObjectType> = [
        HKObjectType.quantityType(forIdentifier: .heartRate)!,
        HKObjectType.quantityType(forIdentifier: .activeEnergyBurned)!,
        HKObjectType.workoutType()
    ]
    private let typesToWrite: Set<HKSampleType> = [
        HKObjectType.quantityType(forIdentifier: .activeEnergyBurned)!,
        HKObjectType.workoutType()
    ]
    
    // Private initializer to enforce singleton pattern
    private init() {}
    
    func requestAuthorization(completion: @escaping (Bool, Error?) -> Void = {_, _ in }) {
        // Check if HealthKit is available
        guard HKHealthStore.isHealthDataAvailable() else {
            completion(false, nil)
            return
        }
        
        healthStore.requestAuthorization(toShare: typesToWrite, read: typesToRead) { success, error in
            completion(success, error)
        }
    }
    
    // Updated to use AppWorkout instead of Workout
    func saveWorkout(_ workout: AppWorkout, completion: @escaping (Bool, Error?) -> Void = {_, _ in }) {
        // This would save the workout to HealthKit
        // For simplicity, we'll just simulate success
        completion(true, nil)
    }
    
    func startHeartRateQuery(quantityTypeIdentifier: HKQuantityTypeIdentifier, completion: @escaping (Double) -> Void) {
        // This would start a heart rate query to get real-time updates
        // For demo, we'll simulate with random values
        Timer.scheduledTimer(withTimeInterval: 3, repeats: true) { _ in
            let heartRate = Double.random(in: 80...160)
            completion(heartRate)
        }
    }
}
