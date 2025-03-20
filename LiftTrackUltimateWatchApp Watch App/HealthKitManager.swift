import HealthKit
import Foundation

class HealthKitManager {
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
    
    // Watch-specific method for active workout session
    func startWorkoutSession(workoutType: String, completion: @escaping (Bool, Error?) -> Void = {_, _ in }) {
        // In a real app, this would start an HKWorkoutSession
        // For demo purposes, we'll just simulate success
        completion(true, nil)
    }
    
    func startHeartRateQuery(quantityTypeIdentifier: HKQuantityTypeIdentifier, completion: @escaping (Double) -> Void) {
        // This would start a heart rate query to get real-time updates on the watch
        // For demo, we'll simulate with random values
        Timer.scheduledTimer(withTimeInterval: 3, repeats: true) { _ in
            let heartRate = Double.random(in: 80...160)
            completion(heartRate)
        }
    }
}
