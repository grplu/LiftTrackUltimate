import SwiftUI

struct ContentView: View {
    @StateObject private var dataManager = DataManager.shared
    
    // Add a state variable to track the selected tab
    @State private var selectedTab = 2
    
    var body: some View {
        // Main TabView with PageTabViewStyle for native swiping
        ZStack {
            // Use TabView with PageTabViewStyle for native full-screen swiping
            TabView(selection: $selectedTab) {
                ProfileView(viewModel: createProfileViewModel())
                    .tag(0)
                
                HistoryView()
                    .tag(1)
                
                WorkoutView()
                    .tag(2)
                
                ExercisesView()
                    .tag(3)
                
                TemplatesView()
                    .tag(4)
            }
            // This is the key for smooth swiping - PageTabViewStyle
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            .environmentObject(dataManager)
            .ignoresSafeArea(edges: .top)
            
            // Custom tab bar overlay at bottom
            VStack {
                Spacer()
                CustomTabBar(selectedTab: $selectedTab)
            }
            .ignoresSafeArea(.keyboard)
        }
        .onAppear {
            // Ensure the tab selection applies on startup
            selectedTab = 2
            
            // Configure UI appearance
            UIPageControl.appearance().isHidden = true // Hide default page indicator dots
        }
    }
    
    private func createProfileViewModel() -> ProfileViewModel {
        let viewModel = ProfileViewModel()
        viewModel.userProfile = dataManager.profile
        
        viewModel.saveProfile = {
            self.dataManager.profile = viewModel.userProfile
        }
        
        return viewModel
    }
}

// Custom tab bar that looks like the standard iOS tab bar
struct CustomTabBar: View {
    @Binding var selectedTab: Int
    
    // Tab data
    private let tabs = [
        (title: "Profile", icon: "person.fill", selectedIcon: "person.fill"),
        (title: "History", icon: "clock.fill", selectedIcon: "clock.fill"),
        (title: "Workout", icon: "figure.strengthtraining.traditional", selectedIcon: "figure.strengthtraining.traditional"),
        (title: "Exercises", icon: "dumbbell.fill", selectedIcon: "dumbbell.fill"),
        (title: "Templates", icon: "doc.fill", selectedIcon: "doc.fill")
    ]
    
    var body: some View {
        ZStack {
            // Background
            Rectangle()
                .fill(Color.black)
                .frame(height: 49) // Standard height
                .shadow(color: Color.black.opacity(0.2), radius: 4, x: 0, y: -2)
            
            // Tab items
            HStack(spacing: 0) {
                ForEach(0..<tabs.count, id: \.self) { index in
                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            selectedTab = index
                        }
                    }) {
                        VStack(spacing: 4) {
                            Image(systemName: selectedTab == index ? tabs[index].selectedIcon : tabs[index].icon)
                                .font(.system(size: 22))
                                .foregroundColor(selectedTab == index ? .blue : .gray)
                            
                            Text(tabs[index].title)
                                .font(.system(size: 10))
                                .foregroundColor(selectedTab == index ? .blue : .gray)
                        }
                        .frame(maxWidth: .infinity)
                        .contentShape(Rectangle())
                    }
                }
            }
            .padding(.bottom, UIApplication.shared.windows.first?.safeAreaInsets.bottom == 0 ? 0 : 16)
        }
        .edgesIgnoringSafeArea(.bottom)
    }
}
