import SwiftUI

// IMPORTANT: TemplateExercise extension was removed to fix redeclaration issue
// The targetWeight property is now properly defined in the TemplateExercise model
// IMPORTANT: WorkoutTemplate extension was removed since iconColor is now part of the model

struct TemplatesView: View {
    @EnvironmentObject var dataManager: DataManager
    @State private var showingAddTemplate = false
    @State private var selectedTab: TemplateTab = .myTemplates
    @State private var searchText = ""
    @State private var isSearching = false
    @State private var animateCards = false
    
    enum TemplateTab {
        case myTemplates, discover
    }
    
    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                gradient: Gradient(colors: [Color.black, Color("101010")]),
                startPoint: .top,
                endPoint: .bottom
            )
            .edgesIgnoringSafeArea(.all)
            
            // Rest of the view implementation...
        }
    }
    
    // Rest of the implementation...
}