import SwiftUI

struct ContentView: View {
    @StateObject private var dataManager = DataManager.shared
    @State private var selectedTab = 2
    
    var body: some View {
        NavigationView {
            ZStack(alignment: .bottom) {
                // Main content
                TabView(selection: $selectedTab) {
                    // CHANGED: Don't pass any viewModel to ProfileView
                    ProfileView()
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
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                .navigationBarHidden(true)
                .environmentObject(dataManager)
                .ignoresSafeArea(.keyboard)
                
                // Fixed position tab bar
                HStack(spacing: 0) {
                    ForEach(0..<tabs.count, id: \.self) { index in
                        Button(action: {
                            selectedTab = index
                            let generator = UIImpactFeedbackGenerator(style: .light)
                            generator.impactOccurred()
                        }) {
                            VStack(spacing: 4) {
                                Image(systemName: index == selectedTab ?
                                      (tabs[index].icon == "figure.strengthtraining.traditional" ?
                                       tabs[index].icon : tabs[index].icon + ".fill") :
                                       tabs[index].icon)
                                    .font(.system(size: 22))
                                    .foregroundColor(index == selectedTab ? .blue : .gray)
                                
                                Text(tabs[index].title)
                                    .font(.system(size: 10))
                                    .foregroundColor(index == selectedTab ? .blue : .gray)
                            }
                            .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .frame(height: 49)
                .background(
                    ZStack(alignment: .top) {
                        // Main tab bar background
                        Rectangle()
                            .fill(Color.black)
                            .frame(height: 49)
                        
                        // Safe area extension
                        Rectangle()
                            .fill(Color.black)
                            .frame(height: getSafeAreaBottom())
                            .offset(y: 49)
                    }
                )
                .edgesIgnoringSafeArea(.bottom)
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .accentColor(.blue)
        .onAppear {
            selectedTab = 2
            UIPageControl.appearance().isHidden = true
            
            // Reset any problematic UIKit settings
            resetScrollViewAppearance()
            
            // Initialize the ProfileViewModel with the user profile from DataManager
            ProfileViewModel.shared.userProfile = dataManager.profile
            ProfileViewModel.shared.saveProfile = {
                self.dataManager.profile = ProfileViewModel.shared.userProfile
            }
        }
    }
    
    // Tab items
    private let tabs = [
        (title: "Profile", icon: "person"),
        (title: "History", icon: "clock"),
        (title: "Workout", icon: "figure.strengthtraining.traditional"),
        (title: "Exercises", icon: "dumbbell"),
        (title: "Templates", icon: "doc")
    ]
    
    // Helper function for safe area
    private func getSafeAreaBottom() -> CGFloat {
        let keyWindow = UIApplication.shared.connectedScenes
            .filter { $0.activationState == .foregroundActive }
            .compactMap { $0 as? UIWindowScene }
            .first?.windows
            .filter { $0.isKeyWindow }
            .first
        
        return keyWindow?.safeAreaInsets.bottom ?? 0
    }
    
    // Reset any problematic scrolling settings
    private func resetScrollViewAppearance() {
        // Make sure scrolling works correctly
        UIScrollView.appearance().bounces = true
        UIScrollView.appearance().isPagingEnabled = false
        
        // Fix tab appearance for iOS 15+
        if #available(iOS 15.0, *) {
            let appearance = UITabBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.backgroundColor = .black
            UITabBar.appearance().standardAppearance = appearance
            UITabBar.appearance().scrollEdgeAppearance = appearance
        }
    }
}
