import SwiftUI

@main
struct LiftTrackUltimateApp: App {
    // Create a StateObject for DataManager that will persist for the lifetime of the app
    @StateObject private var dataManager = DataManager()
    
    // Initialize the session manager
    private let sessionManager = WorkoutSessionManager.shared
    
    init() {
        // Ensure the session manager is initialized at app startup
        _ = sessionManager
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(dataManager) // Inject DataManager as an environment object
        }
    }
}
