import SwiftUI

struct ContentView: View {
    @StateObject private var dataManager = DataManager.shared
    
    var body: some View {
        TabView {
            ProfileView(profile: $dataManager.profile)
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
}
