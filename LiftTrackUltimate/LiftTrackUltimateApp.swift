import SwiftUI

@main
struct LiftTrackUltimateApp: App {
    // Create a StateObject for DataManager
    @StateObject private var dataManager = DataManager()
    
    // Initialize the session manager
    private let sessionManager = WorkoutSessionManager.shared
    
    init() {
        // Ensure the session manager is initialized at app startup
        _ = sessionManager
        
        // NO UI MODIFICATIONS HERE - keep everything as it was
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(dataManager)
        }
    }
}
