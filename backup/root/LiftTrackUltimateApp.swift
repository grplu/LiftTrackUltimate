import SwiftUI

@main
struct LiftTrackUltimateApp: App {
    @StateObject private var dataManager = DataManager.shared
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(dataManager)
        }
    }
}

// Add a type alias for clarity
typealias LTTemplateExercise = TemplateExercise 