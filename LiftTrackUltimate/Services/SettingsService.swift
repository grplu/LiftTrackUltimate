import Foundation
import Combine

class SettingsService: ObservableObject {
    static let shared = SettingsService()
    
    // MARK: - Published Settings
    @Published var useMetricSystem: Bool {
        didSet {
            UserDefaults.standard.set(useMetricSystem, forKey: Keys.useMetricSystem)
        }
    }
    
    @Published var showHeartRate: Bool {
        didSet {
            UserDefaults.standard.set(showHeartRate, forKey: Keys.showHeartRate)
        }
    }
    
    @Published var autoSyncWithHealthKit: Bool {
        didSet {
            UserDefaults.standard.set(autoSyncWithHealthKit, forKey: Keys.autoSyncWithHealthKit)
        }
    }
    
    @Published var defaultRestTime: TimeInterval {
        didSet {
            UserDefaults.standard.set(defaultRestTime, forKey: Keys.defaultRestTime)
        }
    }
    
    @Published var defaultSetsPerExercise: Int {
        didSet {
            UserDefaults.standard.set(defaultSetsPerExercise, forKey: Keys.defaultSetsPerExercise)
        }
    }
    
    @Published var defaultRepsPerSet: Int {
        didSet {
            UserDefaults.standard.set(defaultRepsPerSet, forKey: Keys.defaultRepsPerSet)
        }
    }
    
    @Published var theme: AppTheme {
        didSet {
            UserDefaults.standard.set(theme.rawValue, forKey: Keys.theme)
        }
    }
    
    @Published var notificationsEnabled: Bool {
        didSet {
            UserDefaults.standard.set(notificationsEnabled, forKey: Keys.notificationsEnabled)
        }
    }
    
    @Published var workoutReminders: Bool {
        didSet {
            UserDefaults.standard.set(workoutReminders, forKey: Keys.workoutReminders)
        }
    }
    
    @Published var reminderTime: Date {
        didSet {
            UserDefaults.standard.set(reminderTime, forKey: Keys.reminderTime)
        }
    }
    
    // MARK: - Private Keys
    private enum Keys {
        static let useMetricSystem = "useMetricSystem"
        static let showHeartRate = "showHeartRate"
        static let autoSyncWithHealthKit = "autoSyncWithHealthKit"
        static let defaultRestTime = "defaultRestTime"
        static let defaultSetsPerExercise = "defaultSetsPerExercise"
        static let defaultRepsPerSet = "defaultRepsPerSet"
        static let theme = "theme"
        static let notificationsEnabled = "notificationsEnabled"
        static let workoutReminders = "workoutReminders"
        static let reminderTime = "reminderTime"
    }
    
    // MARK: - Initialization
    private init() {
        // Load default values from UserDefaults
        self.useMetricSystem = UserDefaults.standard.bool(forKey: Keys.useMetricSystem)
        self.showHeartRate = UserDefaults.standard.bool(forKey: Keys.showHeartRate)
        self.autoSyncWithHealthKit = UserDefaults.standard.bool(forKey: Keys.autoSyncWithHealthKit)
        self.defaultRestTime = UserDefaults.standard.double(forKey: Keys.defaultRestTime)
        self.defaultSetsPerExercise = UserDefaults.standard.integer(forKey: Keys.defaultSetsPerExercise)
        self.defaultRepsPerSet = UserDefaults.standard.integer(forKey: Keys.defaultRepsPerSet)
        self.theme = AppTheme(rawValue: UserDefaults.standard.string(forKey: Keys.theme) ?? "") ?? .system
        self.notificationsEnabled = UserDefaults.standard.bool(forKey: Keys.notificationsEnabled)
        self.workoutReminders = UserDefaults.standard.bool(forKey: Keys.workoutReminders)
        self.reminderTime = UserDefaults.standard.object(forKey: Keys.reminderTime) as? Date ?? Calendar.current.date(from: DateComponents(hour: 9, minute: 0)) ?? Date()
        
        // Set default values if not already set
        if self.defaultRestTime == 0 {
            self.defaultRestTime = 60 // 1 minute
        }
        if self.defaultSetsPerExercise == 0 {
            self.defaultSetsPerExercise = 3
        }
        if self.defaultRepsPerSet == 0 {
            self.defaultRepsPerSet = 12
        }
    }
    
    // MARK: - Weight Conversion
    func convertWeight(_ weight: Double, to metric: Bool) -> Double {
        if metric {
            return weight * 0.453592 // lbs to kg
        } else {
            return weight * 2.20462 // kg to lbs
        }
    }
    
    // MARK: - Time Formatting
    func formatTime(_ timeInterval: TimeInterval) -> String {
        let minutes = Int(timeInterval) / 60
        let seconds = Int(timeInterval) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    // MARK: - Settings Reset
    func resetToDefaults() {
        useMetricSystem = false
        showHeartRate = true
        autoSyncWithHealthKit = true
        defaultRestTime = 60
        defaultSetsPerExercise = 3
        defaultRepsPerSet = 12
        theme = .system
        notificationsEnabled = true
        workoutReminders = true
        reminderTime = Calendar.current.date(from: DateComponents(hour: 9, minute: 0)) ?? Date()
    }
}

// MARK: - Supporting Types
enum AppTheme: String {
    case light
    case dark
    case system
} 