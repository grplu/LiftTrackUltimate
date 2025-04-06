import Foundation
import SwiftUI

// Add this method to your DataManager class
extension DataManager {
    func resetAllData() {
        // Reset user profile to default
        var newProfile = UserProfile()
        newProfile.name = "Your Name"
        updateProfile(newProfile)
        
        // Reset all workouts
        workouts = []
        // Clear workouts from UserDefaults directly using the known key names
        UserDefaults.standard.removeObject(forKey: "userWorkouts")
        
        // Reset exercises
        exercises = []
        UserDefaults.standard.removeObject(forKey: "exercises")
        
        // Reset templates
        templates = []
        UserDefaults.standard.removeObject(forKey: "workoutTemplates")
        
        // Reset exercise performances
        exercisePerformances = []
        UserDefaults.standard.removeObject(forKey: "exercisePerformances")
        
        // Reset any exercise memory if implemented
        // If profile has exercise memory, reset it in the new profile before updating
        // For example: newProfile.exerciseMemory = []
        
        // Reset any templates or other stored data
        // Add reset code for any other data types your app stores
        
        // Clear relevant UserDefaults
        let defaults = UserDefaults.standard
        let dictionary = defaults.dictionaryRepresentation()
        
        // List of keys to preserve (add any app settings you want to keep)
        let keysToPreserve = [
            "useMetricSystem",
            "prefersDarkMode",
            "notificationsEnabled"
        ]
        
        for key in dictionary.keys {
            // Only remove keys that aren't in our preserve list
            if !keysToPreserve.contains(key) {
                defaults.removeObject(forKey: key)
            }
        }
        
        // Reload the sample exercises
        loadSampleData()
        
        // Post notification that data has been reset (optional)
        NotificationCenter.default.post(name: NSNotification.Name("DataResetCompleted"), object: nil)
        
        // Clear all caches
        clearCaches()
        
        print("All app data has been reset.")
    }
}
