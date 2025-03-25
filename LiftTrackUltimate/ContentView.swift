import SwiftUI

struct ContentView: View {
    @StateObject private var dataManager = DataManager.shared
    
    // Add a state variable to track the selected tab
    // Setting initial value to 2 (the middle "Workout" tab)
    @State private var selectedTab = 2
    
    var body: some View {
        TabView(selection: $selectedTab) {
            // Updated ProfileView with a ProfileViewModel that uses the dataManager.profile
            ProfileView(viewModel: createProfileViewModel())
                .tabItem {
                    Label("Profile", systemImage: "person.fill")
                }
                .tag(0)
            
            HistoryView()
                .tabItem {
                    Label("History", systemImage: "clock.fill")
                }
                .tag(1)
            
            WorkoutView()
                .tabItem {
                    Label("Workout", systemImage: "figure.strengthtraining.traditional")
                }
                .tag(2)
            
            ExercisesView()
                .tabItem {
                    Label("Exercises", systemImage: "dumbbell.fill")
                }
                .tag(3)
            
            TemplatesView()
                .tabItem {
                    Label("Templates", systemImage: "doc.fill")
                }
                .tag(4)
        }
        .environmentObject(dataManager)
        .onAppear {
            // Ensure the tab selection applies on startup
            selectedTab = 2
        }
    }
    
    // Create a ProfileViewModel that is connected to dataManager.profile
    private func createProfileViewModel() -> ProfileViewModel {
        let viewModel = ProfileViewModel()
        viewModel.userProfile = dataManager.profile
        
        // Add a custom save implementation that updates dataManager.profile
        viewModel.saveProfile = {
            // This ensures changes in viewModel.userProfile are saved back to dataManager
            self.dataManager.profile = viewModel.userProfile
        }
        
        return viewModel
    }
}
