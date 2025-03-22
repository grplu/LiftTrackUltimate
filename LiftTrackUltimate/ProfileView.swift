import SwiftUI

struct ProfileView: View {
    @ObservedObject var viewModel: ProfileViewModel
    @State private var showingEditSheet = false
    @State private var showingSettingsSheet = false
    @State private var isHealthKitConnected = false
    
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
                    
                    // Workout Progress
                    workoutProgress
                    
                    // HealthKit Integration
                    healthKitIntegration
                    
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
                // Add settings action
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
            viewModel.loadStats()
            checkHealthKitStatus()
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
            
            VStack(spacing: 16) {
                // Weekly progress indicators
                HStack(spacing: 4) {
                    ForEach(0..<7, id: \.self) { index in
                        let progress = viewModel.weeklyProgress[safe: index] ?? 0.0
                        
                        VStack(spacing: 4) {
                            Text(weekdayLetter(for: index))
                                .font(.caption2)
                                .foregroundColor(.gray)
                            
                            RoundedRectangle(cornerRadius: 2)
                                .fill(progress > 0 ? Color.white : Color.gray.opacity(0.3))
                                .frame(height: 40 * max(0.1, progress))
                            
                            Text("\(Int(progress * 100))%")
                                .font(.caption2)
                                .foregroundColor(.gray)
                        }
                        .frame(maxWidth: .infinity)
                    }
                }
                .frame(height: 100)
                .padding(.top, 8)
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
    
    // MARK: - HealthKit Integration
    private var healthKitIntegration: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "heart.fill")
                    .font(.system(size: 20))
                    .foregroundColor(.white)
                
                Text("HealthKit")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                Spacer()
                
                Text(isHealthKitConnected ? "Connected" : "Not Connected")
                    .font(.caption)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(isHealthKitConnected ? Color.green.opacity(0.2) : Color.gray.opacity(0.2))
                    .foregroundColor(isHealthKitConnected ? Color.green : Color.gray)
                    .cornerRadius(12)
            }
            
            if !isHealthKitConnected {
                Text("Connect to Apple Health to sync your workouts and track metrics like heart rate and calories burned.")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .padding(.bottom, 16)
                
                Button(action: {
                    connectToHealthKit()
                }) {
                    HStack {
                        Image(systemName: "plus.circle")
                            .font(.body.weight(.semibold))
                        
                        Text("Connect to HealthKit")
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
            } else {
                // Connected state UI
                HStack(spacing: 24) {
                    VStack(spacing: 4) {
                        HStack(alignment: .firstTextBaseline, spacing: 2) {
                            Text("72")
                                .font(.title3)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                            
                            Text("bpm")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                        
                        Text("Avg HR")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    .frame(maxWidth: .infinity)
                    
                    VStack(spacing: 4) {
                        HStack(alignment: .firstTextBaseline, spacing: 2) {
                            Text("243")
                                .font(.title3)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                            
                            Text("kcal")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                        
                        Text("Last Workout")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    .frame(maxWidth: .infinity)
                }
                .padding(16)
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
    
    private func checkHealthKitStatus() {
        // This would normally check if HealthKit is connected
        viewModel.checkHealthKitStatus { isConnected in
            self.isHealthKitConnected = isConnected
        }
    }
    
    private func connectToHealthKit() {
        viewModel.connectToHealthKit { success in
            if success {
                self.isHealthKitConnected = true
            }
        }
    }
}

// MARK: - Collection Extension
extension Collection {
    /// Returns the element at the specified index if it exists, otherwise nil.
    subscript(safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
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
