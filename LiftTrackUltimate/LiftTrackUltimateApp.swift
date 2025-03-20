import SwiftUI

@main
struct LiftTrackUltimateApp: App {
    // Create a StateObject for DataManager that will persist for the lifetime of the app
    @StateObject private var dataManager = DataManager()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(dataManager) // Inject DataManager as an environment object
        }
    }
}
