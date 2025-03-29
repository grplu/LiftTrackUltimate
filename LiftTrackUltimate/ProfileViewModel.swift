import SwiftUI
import Foundation

// Define the DailyWorkoutProgress struct
struct DailyWorkoutProgress {
    let date: Date
    let plannedWorkouts: Int
    let completedWorkouts: Int
    
    var completionPercentage: Double {
        if plannedWorkouts == 0 {
            return 0
        }
        return min(Double(completedWorkouts) / Double(plannedWorkouts), 1.0)
    }
    
    var asPercentageString: String {
        if plannedWorkouts == 0 {
            return "0%"
        }
        return "\(Int(completionPercentage * 100))%"
    }
}

class ProfileViewModel: ObservableObject {
    // IMPORTANT: Make the class a singleton to prevent multiple instances
    static let shared = ProfileViewModel()
    
    @Published var userProfile: UserProfile
    @Published var totalWorkouts: Int = 0
    @Published var totalSets: Int = 0
    @Published var workoutsThisWeek: Int = 0
    @Published var weeklyProgress: [DailyWorkoutProgress] = []
    
    // Custom save function that can be modified by ContentView
    var saveProfile: () -> Void = { }
    private var dataManager = DataManager.shared
    
    // Strict throttling and caching properties
    private var lastStatsLoadTime: Date? = nil
    private let statsLoadThrottleInterval: TimeInterval = 1.0 // Increased to 1 second
    private var weeklyProgressCache: [DailyWorkoutProgress] = []
    private var weeklyProgressCacheTime: Date? = nil
    private let weeklyProgressCacheValidDuration: TimeInterval = 300 // 5 minutes
    
    // More precise debug logging
    private let debugLoggingEnabled = true
    
    // Private initializer to enforce singleton pattern
    private init() {
        print("DEBUG: ProfileViewModel singleton initialized")
        self.userProfile = UserProfile(name: "Your Name", fitnessGoal: "Strength Training")
        
        // Register for workout data change notifications
        NotificationCenter.default.addObserver(self,
                                              selector: #selector(workoutDataDidChange),
                                              name: .workoutDataChanged,
                                              object: nil)
        
        // Load stats after a delay to allow the app to finish initializing
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.loadStats()
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
        print("DEBUG: ProfileViewModel deinitialized")
    }
    
    private func debugLog(_ message: String) {
        if debugLoggingEnabled {
            print("DEBUG: \(message)")
        }
    }
    
    func loadProfile() {
        // This is now handled by ContentView passing in the dataManager.profile
        // The function remains for potential future use
    }
    
    func saveUserProfile() {
        saveProfile()
        debugLog("User profile saved")
    }
    
    // OPTIMIZED: Load all workout statistics with strict throttling
    func loadStats() {
        // STRICT throttling to prevent multiple calls
        let now = Date()
        if let lastLoad = lastStatsLoadTime {
            let interval = now.timeIntervalSince(lastLoad)
            if interval < statsLoadThrottleInterval {
                debugLog("loadStats - STRICTLY Throttled, skipping (interval: \(interval)s)")
                return
            }
        }
        
        // Update the timestamp IMMEDIATELY to prevent race conditions
        lastStatsLoadTime = now
        
        debugLog("loadStats - Starting to load all stats")
        
        // Get all workouts
        let workouts = dataManager.workouts
        debugLog("loadStats - Total workouts: \(workouts.count)")
        
        // Calculate total workouts
        totalWorkouts = workouts.count
        
        // Calculate total sets - OPTIMIZATION: More efficient calculation
        let completedSets = workouts.reduce(0) { count, workout in
            return count + workout.exercises.reduce(0) { count, exercise in
                return count + exercise.sets.filter { $0.completed }.count
            }
        }
        totalSets = completedSets
        debugLog("loadStats - Total completed sets: \(completedSets)")
        
        // OPTIMIZATION: More efficient calculation of workouts this week
        let calendar = Calendar.current
        let today = Date()
        let startOfWeek = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: today))!
        
        let workoutsThisWeekCount = workouts.filter { workout in
            return workout.date >= startOfWeek && workout.date <= today
        }.count
        
        workoutsThisWeek = workoutsThisWeekCount
        debugLog("loadStats - Workouts this week: \(workoutsThisWeekCount)")
        
        // Load weekly workout progress
        loadWeeklyProgress()
        
        debugLog("loadStats - Finished loading all stats")
    }
    
    // OPTIMIZED: Load weekly workout progress with strict caching
    func loadWeeklyProgress() {
        let now = Date()
        
        // STRICT cache check - log details about why cache is/isn't valid
        let shouldUseCache = !weeklyProgressCache.isEmpty &&
                            weeklyProgressCacheTime != nil &&
                            now.timeIntervalSince(weeklyProgressCacheTime!) < weeklyProgressCacheValidDuration
        
        if shouldUseCache {
            if let lastModified = dataManager.getLastWorkoutModificationTime() {
                if lastModified < weeklyProgressCacheTime! {
                    debugLog("Using cached weekly progress - Valid cache")
                    self.weeklyProgress = weeklyProgressCache
                    
                    // Print the weekly progress for debugging
                    for (index, progress) in weeklyProgressCache.enumerated() {
                        let weekdayName = getWeekdayName(for: index)
                        debugLog("Weekly Progress - \(weekdayName): Planned: \(progress.plannedWorkouts), Completed: \(progress.completedWorkouts)")
                    }
                    return
                } else {
                    debugLog("Cache invalidated - Workouts modified after cache time")
                }
            } else {
                debugLog("Cache invalid - No workout modification time available")
            }
        } else {
            if weeklyProgressCache.isEmpty {
                debugLog("Cache invalid - Empty cache")
            } else if weeklyProgressCacheTime == nil {
                debugLog("Cache invalid - No cache time")
            } else {
                debugLog("Cache expired - \(now.timeIntervalSince(weeklyProgressCacheTime!)) seconds old")
            }
        }
        
        let calendar = Calendar.current
        debugLog("Loading weekly progress at \(now)")
        
        // Get the date for Monday of the current week
        var components = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: now)
        components.weekday = 2 // Monday
        guard let mondayDate = calendar.date(from: components) else {
            debugLog("Failed to calculate Monday date")
            return
        }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        debugLog("Monday date for this week is \(dateFormatter.string(from: mondayDate))")
        
        // Create entries for each day of the week
        var weekProgress: [DailyWorkoutProgress] = []
        
        // Pre-calculate all dates for the week at once
        var weekDates: [Date] = []
        for dayOffset in 0..<7 {
            if let date = calendar.date(byAdding: .day, value: dayOffset, to: mondayDate) {
                weekDates.append(date)
            }
        }
        
        // Process workout data for all days in a single pass
        var dayStats: [(planned: Int, completed: Int)] = Array(repeating: (0, 0), count: 7)
        
        // Process each workout just once
        for workout in dataManager.workouts {
            for (index, date) in weekDates.enumerated() {
                if calendar.isDate(workout.date, inSameDayAs: date) {
                    // Count as planned
                    dayStats[index].planned += 1
                    
                    // Check if any set is completed
                    let hasCompletedSets = workout.exercises.contains { exercise in
                        exercise.sets.contains { $0.completed }
                    }
                    
                    if hasCompletedSets {
                        dayStats[index].completed += 1
                    }
                    
                    // Break out of the loop once we've found the matching day
                    break
                }
            }
        }
        
        // Create the final progress objects
        for (index, date) in weekDates.enumerated() {
            let (planned, completed) = dayStats[index]
            
            // Print debug information
            debugLog("Day \(index): \(dateFormatter.string(from: date)), Planned: \(planned), Completed: \(completed)")
            
            weekProgress.append(DailyWorkoutProgress(
                date: date,
                plannedWorkouts: planned,
                completedWorkouts: completed
            ))
        }
        
        // Update the published property to trigger UI refresh
        debugLog("Setting weeklyProgress with \(weekProgress.count) entries")
        self.weeklyProgress = weekProgress
        
        // Update cache - Mark exact time for precise cache expiration
        weeklyProgressCache = weekProgress
        weeklyProgressCacheTime = Date() // Use current time to be extra precise
        
        // Print the weekly progress for debugging
        for (index, progress) in weekProgress.enumerated() {
            let weekdayName = getWeekdayName(for: index)
            debugLog("Weekly Progress - \(weekdayName): Planned: \(progress.plannedWorkouts), Completed: \(progress.completedWorkouts)")
        }
    }
    
    private func getWeekdayName(for index: Int) -> String {
        let weekdays = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"]
        return index < weekdays.count ? weekdays[index] : "Unknown"
    }
    
    @objc private func workoutDataDidChange() {
        debugLog("workoutDataDidChange notification received")
        
        // Clear caches when data changes
        weeklyProgressCache.removeAll()
        weeklyProgressCacheTime = nil
        
        // Reload with a slight delay to prevent multiple rapid reloads
        // Use a longer delay to prevent excessive reloads
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
            guard let self = self else { return }
            self.debugLog("Reloading stats from workoutDataDidChange")
            self.loadStats()
        }
    }
    
    func checkHealthKitStatus(completion: @escaping (Bool) -> Void) {
        // Check if HealthKit is available and authorized
        // This is a placeholder implementation
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            completion(false)
        }
    }
    
    func connectToHealthKit(completion: @escaping (Bool) -> Void) {
        // Request HealthKit authorization
        // This is a placeholder implementation
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            completion(true)
        }
    }
}
