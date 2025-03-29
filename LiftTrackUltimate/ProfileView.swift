import SwiftUI
import HealthKit

struct ProfileView: View {
    // CHANGED: Use the shared singleton instance
    @ObservedObject var viewModel = ProfileViewModel.shared
    @State private var showingEditSheet = false
    @State private var showingSettingsSheet = false
    @State private var animateCards = false
    
    // REMOVED: Custom initializer that creates a new instance
    // init(viewModel: ProfileViewModel = ProfileViewModel()) {
    //     self.viewModel = viewModel
    // }
    
    var body: some View {
        ZStack {
            // Background with subtle gradient
            LinearGradient(
                gradient: Gradient(colors: [Color.black, Color(red: 0.1, green: 0.1, blue: 0.15)]),
                startPoint: .top,
                endPoint: .bottom
            )
            .edgesIgnoringSafeArea(.all)
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    // Top section with header and buttons
                    topSection
                    
                    // Profile Header with avatar and name
                    profileHeader
                        .padding(.top, -15)
                    
                    // Stats Cards
                    statsCards
                        .opacity(animateCards ? 1 : 0)
                        .offset(y: animateCards ? 0 : 15)
                    
                    // Heart Rate Widget
                    HeartRateWidget()
                        .padding(.horizontal)
                        .opacity(animateCards ? 1 : 0)
                        .offset(y: animateCards ? 0 : 15)
                    
                    // Workout Progress
                    workoutProgressView
                        .padding(.horizontal)
                        .opacity(animateCards ? 1 : 0)
                        .offset(y: animateCards ? 0 : 15)
                    
                    // Upcoming features teaser
                    featuresTeaser
                        .padding(.horizontal)
                        .opacity(animateCards ? 1 : 0)
                        .offset(y: animateCards ? 0 : 15)
                }
                .padding(.bottom, 50)
            }
        }
        .onAppear {
            print("DEBUG: ProfileView appeared")
            viewModel.loadStats()
            
            // Animate cards appearing
            withAnimation(.easeOut(duration: 0.5).delay(0.3)) {
                animateCards = true
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .workoutDataChanged)) { _ in
            // Refresh data when workout data changes
            print("DEBUG: Received workoutDataChanged notification")
            viewModel.loadStats()
        }
        .sheet(isPresented: $showingEditSheet) {
            ProfileEditView(profile: $viewModel.userProfile) {
                viewModel.saveUserProfile()
            }
        }
        .sheet(isPresented: $showingSettingsSheet) {
            SettingsView(isPresented: $showingSettingsSheet)
        }
    }
    
    // MARK: - Top Section
    private var topSection: some View {
        HStack {
            Text("Profile")
                .font(.system(size: 34, weight: .bold))
                .foregroundColor(.white)
                .padding(.leading)
            
            Spacer()
            
            // Action buttons in top right
            HStack(spacing: 16) {
                Button(action: {
                    showingEditSheet = true
                }) {
                    Image(systemName: "pencil")
                        .font(.system(size: 18))
                        .foregroundColor(.white)
                        .frame(width: 38, height: 38)
                        .background(
                            Circle()
                                .fill(Color.gray.opacity(0.2))
                                .overlay(
                                    Circle()
                                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                                )
                        )
                }
                
                Button(action: {
                    showingSettingsSheet = true
                }) {
                    Image(systemName: "gearshape.fill")
                        .font(.system(size: 18))
                        .foregroundColor(.white)
                        .frame(width: 38, height: 38)
                        .background(
                            Circle()
                                .fill(Color.gray.opacity(0.2))
                                .overlay(
                                    Circle()
                                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                                )
                        )
                }
            }
            .padding(.trailing)
        }
        .padding(.top, 20)
        .padding(.bottom, 10)
    }
    
    // MARK: - Profile Header
    private var profileHeader: some View {
        VStack(spacing: 16) {
            // Avatar with glowing effect
            ZStack {
                // Outer glow
                Circle()
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color.blue.opacity(0.5),
                                Color.purple.opacity(0.3)
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 118, height: 118)
                    .blur(radius: 8)
                
                // Avatar background
                Circle()
                    .fill(Color.black)
                    .frame(width: 110, height: 110)
                    .shadow(color: Color.black.opacity(0.4), radius: 10, x: 0, y: 6)
                
                if let profilePicture = viewModel.userProfile.profilePicture,
                   let uiImage = UIImage(data: profilePicture) {
                    // Display the actual profile picture
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 100, height: 100)
                        .clipShape(Circle())
                } else {
                    // Fallback to default image
                    Image(systemName: "person.crop.circle.fill")
                        .resizable()
                        .scaledToFit()
                        .foregroundColor(.white)
                        .frame(width: 80, height: 80)
                }
            }
            
            // Name and goal
            VStack(spacing: 10) {
                Text(viewModel.userProfile.name)
                    .font(.system(size: 26, weight: .bold))
                    .foregroundColor(.white)
                
                Text(viewModel.userProfile.fitnessGoal)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.white)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 8)
                    .background(
                        Capsule()
                            .fill(
                                LinearGradient(
                                    gradient: Gradient(colors: [Color.blue.opacity(0.7), Color.purple.opacity(0.5)]),
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                    )
            }
        }
        .padding(.bottom, 10)
    }
    
    // MARK: - Stats Cards
    private var statsCards: some View {
        HStack(spacing: 12) {
            // Workouts
            statCard(
                title: "Workouts",
                value: "\(viewModel.totalWorkouts)",
                icon: "flame.fill",
                color: Color.orange
            )
            
            // Sets
            statCard(
                title: "Sets",
                value: "\(viewModel.totalSets)",
                icon: "repeat",
                color: Color.blue
            )
            
            // This Week
            statCard(
                title: "This Week",
                value: "\(viewModel.workoutsThisWeek)",
                icon: "calendar",
                color: Color.green
            )
        }
        .padding(.horizontal)
    }
    
    private func statCard(title: String, value: String, icon: String, color: Color) -> some View {
        VStack(spacing: 12) {
            // Icon
            ZStack {
                Circle()
                    .fill(color.opacity(0.2))
                    .frame(width: 48, height: 48)
                
                Image(systemName: icon)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(color)
            }
            
            // Title
            Text(title)
                .font(.system(size: 14))
                .foregroundColor(.gray)
            
            // Value
            Text(value)
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(.white)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(.systemGray6).opacity(0.15))
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                )
        )
    }
    
    // MARK: - Workout Progress View
    private var workoutProgressView: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header
            HStack {
                Text("Workout Progress")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.white)
                
                Spacer()
                
                Text("This Week")
                    .font(.system(size: 14))
                    .foregroundColor(.gray)
            }
            
            // Day of week progress tracker
            HStack(spacing: 0) {
                ForEach(0..<viewModel.weeklyProgress.count, id: \.self) { index in
                    let progress = viewModel.weeklyProgress[index]
                    let hasWorkout = progress.completedWorkouts > 0
                    let isToday = Calendar.current.isDateInToday(progress.date)
                    
                    VStack(spacing: 8) {
                        // Day name
                        Text(getWeekdayAbbreviation(for: index))
                            .font(.system(size: 14))
                            .foregroundColor(isToday ? .white : .gray)
                        
                        // Workout indicator
                        ZStack {
                            // Background circle
                            Circle()
                                .fill(hasWorkout ? Color.green : Color.gray.opacity(0.2))
                                .frame(width: 36, height: 36)
                            
                            // Checkmark for completed workouts
                            if hasWorkout {
                                Image(systemName: "checkmark")
                                    .font(.system(size: 14, weight: .bold))
                                    .foregroundColor(.white)
                            }
                        }
                        // Highlight today
                        .overlay(
                            Circle()
                                .stroke(isToday ? Color.white : Color.clear, lineWidth: 2)
                                .padding(-2)
                        )
                        .shadow(color: hasWorkout ? Color.green.opacity(0.5) : Color.clear, radius: 5, x: 0, y: 0)
                    }
                    .frame(maxWidth: .infinity)
                }
            }
            .padding(.vertical, 16)
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(.systemGray6).opacity(0.15))
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                )
        )
        .onAppear {
            viewModel.loadWeeklyProgress()
        }
    }
    
    // MARK: - Feature Teaser
    private var featuresTeaser: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Coming Soon")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.white)
                
                Spacer()
                
                // Badge
                Text("Beta")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(
                        Capsule()
                            .fill(
                                LinearGradient(
                                    gradient: Gradient(colors: [Color.purple, Color.blue]),
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                    )
            }
            
            // Feature items
            featureItem(
                icon: "applewatch",
                title: "Apple Watch App",
                description: "Track workouts directly from your wrist"
            )
            
            featureItem(
                icon: "chart.bar.fill",
                title: "Advanced Analytics",
                description: "Detailed insights into your workout performance"
            )
            
            featureItem(
                icon: "person.2.fill",
                title: "Social Features",
                description: "Connect with friends and share your progress"
            )
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(.systemGray6).opacity(0.15))
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                )
        )
    }
    
    private func featureItem(icon: String, title: String, description: String) -> some View {
        HStack(spacing: 16) {
            // Icon
            ZStack {
                Circle()
                    .fill(Color.blue.opacity(0.2))
                    .frame(width: 40, height: 40)
                
                Image(systemName: icon)
                    .font(.system(size: 18))
                    .foregroundColor(.blue)
            }
            
            // Text content
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                
                Text(description)
                    .font(.system(size: 14))
                    .foregroundColor(.gray)
            }
            
            Spacer()
        }
        .padding(.vertical, 8)
    }
    
    // Helper function for abbreviated weekday names
    private func getWeekdayAbbreviation(for index: Int) -> String {
        let weekdays = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]
        return weekdays[index]
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView()
            .preferredColorScheme(.dark)
    }
}
