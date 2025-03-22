import Foundation
import SwiftUI

// Add this method to your DataManager class
extension DataManager {
    func resetAllData() {
        // Reset user profile to default
        self.profile = UserProfile(name: "Your Name", fitnessGoal: "Strength Training")
        
        // Reset all workouts
        // Add any additional workout reset code you need based on your app structure
        
        // Reset all exercise memory
        self.profile.exerciseMemory = []
        
        // Reset any templates or other stored data
        // Add reset code for any other data types your app stores
        
        // Save the changes to persistent storage
        saveProfile(self.profile)
        
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
        
        // Post notification that data has been reset (optional)
        NotificationCenter.default.post(name: NSNotification.Name("DataResetCompleted"), object: nil)
        
        print("All app data has been reset.")
    }
}
