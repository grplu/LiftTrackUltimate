import SwiftUI

struct ContentView: View {
    @StateObject private var dataManager = DataManager.shared
    
    var body: some View {
        TabView {
            // Updated ProfileView with a ProfileViewModel that uses the dataManager.profile
            ProfileView(viewModel: createProfileViewModel())
                .tabItem {
                    Label("Profile", systemImage: "person.fill")
                }
            
            HistoryView()
                .tabItem {
                    Label("History", systemImage: "clock.fill")
                }
            
            WorkoutView()
                .tabItem {
                    Label("Workout", systemImage: "figure.run")
                }
            
            ExercisesView()
                .tabItem {
                    Label("Exercises", systemImage: "dumbbell.fill")
                }
            
            TemplatesView()
                .tabItem {
                    Label("Templates", systemImage: "doc.fill")
                }
        }
        .environmentObject(dataManager)
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
