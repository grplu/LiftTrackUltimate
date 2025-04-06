import Foundation
import HealthKit

// MARK: - HealthKit Errors
public enum HealthKitError: Error {
    case notAvailable
    case notAuthorized
    case invalidData
}

// MARK: - HealthKit Statistics
public struct HealthKitWorkoutStatistics {
    public let totalWorkouts: Int
    public let totalDuration: TimeInterval
    public let totalCalories: Double
    
    public init(totalWorkouts: Int, totalDuration: TimeInterval, totalCalories: Double) {
        self.totalWorkouts = totalWorkouts
        self.totalDuration = totalDuration
        self.totalCalories = totalCalories
    }
} 