import SwiftUI
import HealthKit

struct UserProfileView: View {
    @EnvironmentObject private var dataManager: DataManager
    @StateObject private var viewModel = ProfileViewViewModel.shared
    
    var body: some View {
        ZStack {
            // Background with subtle gradient
            LinearGradient(
                gradient: Gradient(colors: [Color.black, Color(red: 0.1, green: 0.1, blue: 0.15)]),
                startPoint: .top,
                endPoint: .bottom
            )
            .edgesIgnoringSafeArea(.all)
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    // Top section with header and buttons
                    ProfileHeader(
                        showingEditSheet: $viewModel.showingEditSheet,
                        showingSettingsSheet: $viewModel.showingSettingsSheet
                    )
                    
                    // Stats cards section
                    StatsCardsSection(
                        profile: viewModel.userProfile,
                        animate: viewModel.animateCards
                    )
                    
                    // Goals section
                    GoalsSection(profile: viewModel.userProfile)
                    
                    // Achievements section
                    AchievementsSection(profile: viewModel.userProfile)
                }
                .padding()
            }
        }
        .sheet(isPresented: $viewModel.showingEditSheet) {
            EditProfileView(profile: viewModel.userProfile) { updatedProfile in
                viewModel.updateProfile(updatedProfile)
            }
        }
        .sheet(isPresented: $viewModel.showingSettingsSheet) {
            SettingsView()
        }
        .onAppear {
            // Use the DataManager directly to load profile data
            dataManager.loadProfile()
            
            // Just animate the cards without loading profile
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                viewModel.toggleCardAnimation()
            }
        }
    }
}

// MARK: - Preview
struct UserProfileView_Previews: PreviewProvider {
    static var previews: some View {
        UserProfileView()
    }
} 