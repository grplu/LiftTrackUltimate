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
    @Published var userProfile: UserProfile
    @Published var totalWorkouts: Int = 0
    @Published var totalSets: Int = 0
    @Published var workoutsThisWeek: Int = 0
    @Published var weeklyProgress: [DailyWorkoutProgress] = []
    
    // Custom save function that can be modified by ContentView
    var saveProfile: () -> Void = { }
    private var dataManager = DataManager.shared
    
    init() {
        // Initialize with default profile - this will be immediately replaced by the ContentView
        self.userProfile = UserProfile(name: "Your Name", fitnessGoal: "Strength Training")
        loadStats()
        
        // Register for workout data change notifications
        NotificationCenter.default.addObserver(self,
                                              selector: #selector(workoutDataDidChange),
                                              name: .workoutDataChanged,
                                              object: nil)
        
        print("DEBUG: ProfileViewModel initialized")
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
        print("DEBUG: ProfileViewModel deinitialized")
    }
    
    func loadProfile() {
        // This is now handled by ContentView passing in the dataManager.profile
        // The function remains for potential future use
    }
    
    func saveUserProfile() {
        saveProfile()
        print("DEBUG: User profile saved")
    }
    
    // Load all workout statistics
    func loadStats() {
        print("DEBUG: loadStats - Starting to load all stats")
        
        // Get all workouts
        let workouts = dataManager.workouts
        print("DEBUG: loadStats - Total workouts: \(workouts.count)")
        
        // Calculate total workouts
        totalWorkouts = workouts.count
        
        // Calculate total sets
        let completedSets = workouts.flatMap { $0.exercises }.flatMap { $0.sets }.filter { $0.completed }.count
        totalSets = completedSets
        print("DEBUG: loadStats - Total completed sets: \(completedSets)")
        
        // Calculate workouts this week
        let calendar = Calendar.current
        let today = Date()
        let startOfWeek = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: today))!
        let workoutsThisWeekCount = workouts.filter { workout in
            calendar.isDate(workout.date, inSameDayAs: today) ||
            (workout.date >= startOfWeek && workout.date < today)
        }.count
        workoutsThisWeek = workoutsThisWeekCount
        print("DEBUG: loadStats - Workouts this week: \(workoutsThisWeekCount)")
        
        // Load weekly workout progress
        loadWeeklyProgress()
        
        print("DEBUG: loadStats - Finished loading all stats")
    }
    
    // Load weekly workout progress
    func loadWeeklyProgress() {
        let calendar = Calendar.current
        let today = Date()
        
        print("DEBUG: Loading weekly progress at \(today)")
        
        // Get the date for Monday of the current week
        var mondayComponents = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: today)
        mondayComponents.weekday = 2 // Monday
        guard let mondayDate = calendar.date(from: mondayComponents) else {
            print("DEBUG: Failed to calculate Monday date")
            return
        }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        print("DEBUG: Monday date for this week is \(dateFormatter.string(from: mondayDate))")
        
        // Create entries for each day of the week
        var weekProgress: [DailyWorkoutProgress] = []
        
        for dayOffset in 0..<7 {
            guard let date = calendar.date(byAdding: .day, value: dayOffset, to: mondayDate) else {
                print("DEBUG: Failed to calculate date for offset \(dayOffset)")
                continue
            }
            
            // Get actual workout data for this date
            let (planned, completed) = dataManager.getWorkoutData(for: date)
            
            // Print debug information
            print("DEBUG: Day \(dayOffset): \(dateFormatter.string(from: date)), Planned: \(planned), Completed: \(completed)")
            
            weekProgress.append(DailyWorkoutProgress(
                date: date,
                plannedWorkouts: planned,
                completedWorkouts: completed
            ))
        }
        
        // Update the published property to trigger UI refresh
        print("DEBUG: Setting weeklyProgress with \(weekProgress.count) entries")
        self.weeklyProgress = weekProgress
        
        // Print the weekly progress for debugging
        for (index, progress) in weekProgress.enumerated() {
            let weekdayName = getWeekdayName(for: index)
            print("DEBUG: Weekly Progress - \(weekdayName): Planned: \(progress.plannedWorkouts), Completed: \(progress.completedWorkouts)")
        }
    }
    
    private func getWeekdayName(for index: Int) -> String {
        let weekdays = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"]
        return weekdays[index]
    }
    
    @objc private func workoutDataDidChange() {
        print("DEBUG: workoutDataDidChange notification received")
        DispatchQueue.main.async {
            print("DEBUG: Reloading stats from workoutDataDidChange")
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
