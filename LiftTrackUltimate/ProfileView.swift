import SwiftUI
import HealthKit

struct ProfileView: View {
    @ObservedObject var viewModel: ProfileViewModel
    @State private var showingEditSheet = false
    @State private var showingSettingsSheet = false
    
    init(viewModel: ProfileViewModel = ProfileViewModel()) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(.all)
            
            ScrollView {
                VStack(spacing: 24) {
                    // Profile Header
                    profileHeader
                    
                    // Stats Overview
                    statsOverview
                    
                    // Action Buttons
                    actionButtons
                    
                    // Heart Rate Widget
                    HeartRateWidget()
                    
                    // Workout Progress
                    workoutProgress
                    
                    // Apple Watch Promo
                    watchAppPromo
                }
                .padding(.horizontal, 16)
                .padding(.top, 20)
                .padding(.bottom, 50)
            }
        }
        .navigationTitle("Profile")
        .navigationBarTitleDisplayMode(.large)
        .navigationBarItems(trailing:
            Button(action: {
                showingSettingsSheet = true
            }) {
                Image(systemName: "ellipsis")
                    .font(.system(size: 22))
                    .foregroundColor(.white)
            }
        )
        .sheet(isPresented: $showingEditSheet) {
            ProfileEditView(profile: $viewModel.userProfile) {
                viewModel.saveUserProfile()
            }
        }
        .sheet(isPresented: $showingSettingsSheet) {
            SettingsView(isPresented: $showingSettingsSheet)
        }
        .onAppear {
            print("DEBUG: ProfileView appeared")
            viewModel.loadStats()
        }
        .onReceive(NotificationCenter.default.publisher(for: .workoutDataChanged)) { _ in
            // Refresh data when workout data changes
            print("DEBUG: Received workoutDataChanged notification")
            viewModel.loadStats()
        }
    }
    
    // MARK: - Profile Header
    private var profileHeader: some View {
        VStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(Color.black)
                    .frame(width: 100, height: 100)
                    .overlay(
                        Circle()
                            .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                    )
                
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
            
            Text(viewModel.userProfile.name)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.white)
            
            Text(viewModel.userProfile.fitnessGoal)
                .font(.subheadline)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(Color.black)
                .foregroundColor(.white)
                .clipShape(Capsule())
                .overlay(
                    Capsule()
                        .stroke(Color.white, lineWidth: 1)
                )
        }
        .padding(.vertical, 16)
    }
    
    // MARK: - Stats Overview
    private var statsOverview: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Statistics")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.white)
            
            HStack(spacing: 0) {
                statItem(label: "Workouts", value: String(viewModel.totalWorkouts), iconName: "flame.fill")
                
                Divider()
                    .background(Color.gray.opacity(0.3))
                    .frame(height: 40)
                
                statItem(label: "Total Sets", value: String(viewModel.totalSets), iconName: "repeat")
                
                Divider()
                    .background(Color.gray.opacity(0.3))
                    .frame(height: 40)
                
                statItem(label: "This Week", value: String(viewModel.workoutsThisWeek), iconName: "calendar")
            }
            .padding(16)
            .background(Color.black)
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.gray.opacity(0.3), lineWidth: 1)
            )
        }
    }
    
    private func statItem(label: String, value: String, iconName: String) -> some View {
        VStack(spacing: 8) {
            Text(label)
                .font(.caption)
                .foregroundColor(.gray)
            
            HStack(spacing: 4) {
                Image(systemName: iconName)
                    .font(.system(size: 14))
                    .foregroundColor(.white)
                
                Text(value)
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
            }
        }
        .frame(maxWidth: .infinity)
    }
    
    // MARK: - Action Buttons
    private var actionButtons: some View {
        HStack(spacing: 16) {
            Button(action: {
                showingEditSheet = true
            }) {
                HStack(spacing: 8) {
                    Image(systemName: "pencil")
                        .font(.body.weight(.semibold))
                    
                    Text("Edit Profile")
                        .font(.body.weight(.semibold))
                }
                .padding(.vertical, 14)
                .frame(maxWidth: .infinity)
                .background(Color.black)
                .foregroundColor(.white)
                .cornerRadius(10)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.white, lineWidth: 1)
                )
            }
            
            Button(action: {
                showingSettingsSheet = true
            }) {
                HStack(spacing: 8) {
                    Image(systemName: "gear")
                        .font(.body.weight(.semibold))
                    
                    Text("Settings")
                        .font(.body.weight(.semibold))
                }
                .padding(.vertical, 14)
                .frame(maxWidth: .infinity)
                .background(Color.white)
                .foregroundColor(.black)
                .cornerRadius(10)
            }
        }
    }
    
    // MARK: - Workout Progress
    private var workoutProgress: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Workout Progress")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .onAppear {
                    // Force refresh weekly progress data
                    viewModel.loadWeeklyProgress()
                    
                    // Debug prints
                    print("DEBUG: Weekly progress data loaded")
                    for (index, progress) in viewModel.weeklyProgress.enumerated() {
                        let weekday = getWeekdayName(for: index)
                        let dateString = dateFormatter.string(from: progress.date)
                        print("DEBUG: \(weekday) (\(dateString)) - Planned: \(progress.plannedWorkouts), Completed: \(progress.completedWorkouts)")
                    }
                }
            
            VStack(spacing: 12) {
                // Header: This Week
                Text("This Week")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.bottom, 4)
                
                // Days of the week in horizontal layout
                HStack(spacing: 12) {
                    ForEach(0..<viewModel.weeklyProgress.count, id: \.self) { index in
                        let progress = viewModel.weeklyProgress[index]
                        let hasWorkout = progress.completedWorkouts > 0
                        let isToday = Calendar.current.isDateInToday(progress.date)
                        
                        VStack(spacing: 8) {
                            // Abbreviated day name
                            Text(getWeekdayAbbreviation(for: index))
                                .font(.footnote)
                                .foregroundColor(.white)
                            
                            // Checkmark or empty circle
                            ZStack {
                                Circle()
                                    .fill(hasWorkout ? Color.green : Color.gray.opacity(0.2))
                                    .frame(width: 36, height: 36)
                                    .onAppear {
                                        // Debug print for this specific circle
                                        print("DEBUG: Circle for \(getWeekdayAbbreviation(for: index)) - hasWorkout: \(hasWorkout), completedWorkouts: \(progress.completedWorkouts)")
                                    }
                                
                                if hasWorkout {
                                    Image(systemName: "checkmark")
                                        .foregroundColor(.white)
                                        .font(.system(size: 14, weight: .bold))
                                }
                            }
                            .overlay(
                                Circle()
                                    .stroke(isToday ? Color.white : Color.clear, lineWidth: 1)
                            )
                        }
                    }
                }
                .padding(.horizontal, 8)
            }
            .padding(16)
            .background(Color.black)
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.gray.opacity(0.3), lineWidth: 1)
            )
            .onAppear {
                // Force refresh when this view appears
                viewModel.loadWeeklyProgress()
            }
        }
    }
    
    // Helper function for abbreviated weekday names
    private func getWeekdayAbbreviation(for index: Int) -> String {
        let weekdays = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]
        return weekdays[index]
    }
    
    private func getWeekdayName(for index: Int) -> String {
        let weekdays = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"]
        return weekdays[index]
    }
    
    // Debug date formatter
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter
    }()
    
    // MARK: - Apple Watch Promo
    private var watchAppPromo: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Apple Watch")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .padding(.bottom, -8)
            
            HStack(spacing: 16) {
                // Watch icon
                ZStack {
                    Circle()
                        .fill(Color.black)
                        .frame(width: 70, height: 70)
                        .overlay(
                            Circle()
                                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                        )
                    
                    Image(systemName: "applewatch")
                        .font(.system(size: 32))
                        .foregroundColor(.white)
                }
                
                // Promo content
                VStack(alignment: .leading, spacing: 8) {
                    Text("LIFT Watch App")
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    Text("Track workouts from your wrist and seamlessly sync with your iPhone. Coming soon!")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .lineLimit(2)
                    
                    Button(action: {
                        // Handle notification signup
                    }) {
                        Text("Get Notified")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .padding(.vertical, 6)
                            .padding(.horizontal, 12)
                            .background(Color.gray.opacity(0.2))
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                    .padding(.top, 4)
                }
            }
        }
        .padding(16)
        .background(Color.black)
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
        )
    }
    
    // MARK: - Helper Methods
    private func weekdayLetter(for index: Int) -> String {
        let weekdays = ["M", "T", "W", "T", "F", "S", "S"]
        return weekdays[index]
    }
}

// MARK: - Collection Extension
extension Collection {
    /// Returns the element at the specified index if it exists, otherwise nil.
    subscript(safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}

// MARK: - View Extension for Conditional Modifiers
extension View {
    @ViewBuilder func `if`<Content: View>(_ condition: Bool, transform: (Self) -> Content) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }
}

// MARK: - Preview
struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            ProfileView()
                .preferredColorScheme(.dark)
        }
    }
}
