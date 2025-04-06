import Foundation
import SwiftUI
import HealthKit

@MainActor
final class ProfileViewViewModel: ObservableObject {
    static let shared = ProfileViewViewModel()
    
    @Published private(set) var userProfile: UserProfile
    @Published var showingEditSheet: Bool
    @Published var showingSettingsSheet: Bool
    @Published var animateCards: Bool
    
    private init() {
        self.userProfile = UserProfile()
        self.showingEditSheet = false
        self.showingSettingsSheet = false
        self.animateCards = false
    }
    
    // MARK: - Profile Management
    func updateProfile(_ profile: UserProfile) {
        self.userProfile = profile
        DataManager.shared.updateProfile(profile)
    }
    
    // Load profile from DataManager
    func loadProfile() {
        // Delegate to DataManager to load the profile
        // This will trigger updateProfile through DataManager's callbacks
        DataManager.shared.loadProfile()
    }
    
    // Save the current profile
    func saveProfile() {
        // Save the current profile through DataManager
        DataManager.shared.updateProfile(userProfile)
    }
    
    // MARK: - UI State Management
    func toggleEditSheet() {
        showingEditSheet.toggle()
    }
    
    func toggleSettingsSheet() {
        showingSettingsSheet.toggle()
    }
    
    func toggleCardAnimation() {
        withAnimation {
            animateCards.toggle()
        }
    }
    
    // MARK: - Health Data Management
    func updateHealthStats() {
        // Implement health data update logic here
    }
    
    // MARK: - Achievement Management
    func checkAndUpdateAchievements() {
        // Implement achievement update logic here
    }
} 