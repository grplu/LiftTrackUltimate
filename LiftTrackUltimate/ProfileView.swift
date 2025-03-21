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
        ScrollView {
            VStack(spacing: LiftTheme.Layout.spacing20) {
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
            .padding(.horizontal, LiftTheme.Layout.paddingMedium)
            .padding(.top, LiftTheme.Layout.paddingLarge)
            .padding(.bottom, LiftTheme.Layout.spacing48)
            .background(LiftTheme.Colors.background)
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.large)
            .sheet(isPresented: $showingEditSheet) {
                ProfileEditView(profile: $viewModel.userProfile) {
                    viewModel.saveProfile()
                }
            }
        }
        .onAppear {
            viewModel.loadProfile()
            checkHealthKitStatus()
        }
    }
    
    // MARK: - Profile Header
    private var profileHeader: some View {
        VStack(spacing: LiftTheme.Layout.spacing12) {
            // Profile Image
            ZStack {
                Circle()
                    .fill(LiftTheme.Colors.secondaryBackground)
                    .frame(width: 100, height: 100)
                
                Image(systemName: "person.crop.circle.fill")
                    .resizable()
                    .scaledToFit()
                    .foregroundColor(LiftTheme.Colors.primary)
                    .frame(width: 80, height: 80)
            }
            .overlay(
                Circle()
                    .stroke(LiftTheme.Colors.primary, lineWidth: LiftTheme.Layout.borderWidthRegular)
            )
            
            Text(viewModel.userProfile.name)
                .font(LiftTheme.Typography.title)
                .foregroundColor(LiftTheme.Colors.primaryContent)
            
            Text(viewModel.userProfile.fitnessGoal)
                .font(LiftTheme.Typography.captionBold)
                .foregroundColor(LiftTheme.Colors.secondary)
                .padding(.horizontal, 12)
                .padding(.vertical, 4)
                .background(LiftTheme.Colors.primary)
                .cornerRadius(12)
        }
        .padding(.bottom, LiftTheme.Layout.spacing8)
    }
    
    // MARK: - Stats Overview
    private var statsOverview: some View {
        VStack(alignment: .leading, spacing: LiftTheme.Layout.spacing16) {
            Text("Statistics")
                .font(LiftTheme.Typography.subtitle)
                .foregroundColor(LiftTheme.Colors.primaryContent)
            
            HStack(spacing: LiftTheme.Layout.spacing8) {
                statItem(label: "Workouts", value: String(viewModel.totalWorkouts), iconName: "flame.fill")
                
                Divider()
                
                statItem(label: "Total Sets", value: String(viewModel.totalSets), iconName: "repeat")
                
                Divider()
                
                statItem(label: "This Week", value: String(viewModel.workoutsThisWeek), iconName: "calendar")
            }
            .padding()
            .background(LiftTheme.Colors.surface)
            .cornerRadius(LiftTheme.Layout.cornerRadiusMedium)
            .overlay(
                RoundedRectangle(cornerRadius: LiftTheme.Layout.cornerRadiusMedium)
                    .stroke(LiftTheme.Colors.surfaceBorder, lineWidth: LiftTheme.Layout.borderWidthThin)
            )
        }
    }
    
    private func statItem(label: String, value: String, iconName: String) -> some View {
        VStack(spacing: 4) {
            Text(label)
                .font(LiftTheme.Typography.caption)
                .foregroundColor(LiftTheme.Colors.secondaryContent)
            
            HStack(spacing: 4) {
                Image(systemName: iconName)
                    .font(.system(size: 14))
                    .foregroundColor(LiftTheme.Colors.primaryContent)
                
                Text(value)
                    .font(LiftTheme.Typography.bodyLarge)
                    .fontWeight(.bold)
                    .foregroundColor(LiftTheme.Colors.primaryContent)
            }
        }
        .frame(maxWidth: .infinity)
    }
    
    // MARK: - Action Buttons
    private var actionButtons: some View {
        HStack(spacing: LiftTheme.Layout.spacing16) {
            Button(action: {
                showingEditSheet = true
            }) {
                HStack {
                    Image(systemName: "person.crop.circle.badge.edit")
                        .font(.body.weight(.semibold))
                    
                    Text("Edit Profile")
                        .font(LiftTheme.Typography.button)
                }
                .padding(.vertical, LiftTheme.Layout.paddingSmall)
                .padding(.horizontal, LiftTheme.Layout.paddingMedium)
                .frame(maxWidth: .infinity)
                .background(LiftTheme.Colors.primary)
                .foregroundColor(LiftTheme.Colors.secondary)
                .cornerRadius(LiftTheme.Layout.cornerRadiusSmall)
            }
            
            Button(action: {
                showingSettingsSheet = true
            }) {
                HStack {
                    Image(systemName: "gear")
                        .font(.body.weight(.semibold))
                    
                    Text("Settings")
                        .font(LiftTheme.Typography.button)
                }
                .padding(.vertical, LiftTheme.Layout.paddingSmall)
                .padding(.horizontal, LiftTheme.Layout.paddingMedium)
                .frame(maxWidth: .infinity)
                .background(Color.clear)
                .foregroundColor(LiftTheme.Colors.primary)
                .overlay(
                    RoundedRectangle(cornerRadius: LiftTheme.Layout.cornerRadiusSmall)
                        .stroke(LiftTheme.Colors.primary, lineWidth: LiftTheme.Layout.borderWidthRegular)
                )
                .cornerRadius(LiftTheme.Layout.cornerRadiusSmall)
            }
        }
    }
    
    // MARK: - Workout Progress
    private var workoutProgress: some View {
        VStack(alignment: .leading, spacing: LiftTheme.Layout.spacing16) {
            Text("Workout Progress")
                .font(LiftTheme.Typography.subtitle)
                .foregroundColor(LiftTheme.Colors.primaryContent)
            
            VStack(spacing: LiftTheme.Layout.spacing16) {
                // Weekly progress indicators
                HStack(spacing: LiftTheme.Layout.spacing4) {
                    ForEach(0..<7, id: \.self) { index in
                        let progress = viewModel.weeklyProgress[safe: index] ?? 0.0
                        
                        VStack(spacing: LiftTheme.Layout.spacing4) {
                            Text(weekdayLetter(for: index))
                                .font(LiftTheme.Typography.caption)
                                .foregroundColor(LiftTheme.Colors.tertiaryContent)
                            
                            RoundedRectangle(cornerRadius: 2)
                                .fill(progress > 0 ? LiftTheme.Colors.primary : LiftTheme.Colors.secondaryBackground)
                                .frame(height: 40 * max(0.1, progress))
                            
                            Text("\(Int(progress * 100))%")
                                .font(LiftTheme.Typography.caption)
                                .foregroundColor(LiftTheme.Colors.secondaryContent)
                        }
                        .frame(maxWidth: .infinity)
                    }
                }
                .frame(height: 80)
            }
            .padding()
            .background(LiftTheme.Colors.surface)
            .cornerRadius(LiftTheme.Layout.cornerRadiusMedium)
            .overlay(
                RoundedRectangle(cornerRadius: LiftTheme.Layout.cornerRadiusMedium)
                    .stroke(LiftTheme.Colors.surfaceBorder, lineWidth: LiftTheme.Layout.borderWidthThin)
            )
        }
    }
    
    // MARK: - HealthKit Integration
    private var healthKitIntegration: some View {
        VStack(alignment: .leading, spacing: LiftTheme.Layout.spacing16) {
            HStack {
                Image(systemName: "heart.fill")
                    .font(.system(size: 20))
                    .foregroundColor(LiftTheme.Colors.primary)
                
                Text("HealthKit")
                    .font(LiftTheme.Typography.subtitle)
                
                Spacer()
                
                Text(isHealthKitConnected ? "Connected" : "Not Connected")
                    .font(LiftTheme.Typography.captionBold)
                    .foregroundColor(isHealthKitConnected ? LiftTheme.Colors.secondary : LiftTheme.Colors.tertiaryContent)
                    .padding(.horizontal, LiftTheme.Layout.paddingSmall)
                    .padding(.vertical, 4)
                    .background(isHealthKitConnected ? LiftTheme.Colors.success : LiftTheme.Colors.tertiaryContent.opacity(0.1))
                    .cornerRadius(LiftTheme.Layout.cornerRadiusSmall)
            }
            
            if !isHealthKitConnected {
                Text("Connect to Apple Health to sync your workouts and track metrics like heart rate and calories burned.")
                    .font(LiftTheme.Typography.bodySmall)
                    .foregroundColor(LiftTheme.Colors.secondaryContent)
                    .multilineTextAlignment(.leading)
                    .padding(.bottom, LiftTheme.Layout.spacing8)
                
                Button(action: {
                    connectToHealthKit()
                }) {
                    HStack {
                        Image(systemName: "plus.circle")
                            .font(.body.weight(.semibold))
                        
                        Text("Connect to HealthKit")
                            .font(LiftTheme.Typography.button)
                    }
                    .padding(.vertical, LiftTheme.Layout.paddingSmall)
                    .padding(.horizontal, LiftTheme.Layout.paddingMedium)
                    .frame(maxWidth: .infinity)
                    .background(LiftTheme.Colors.primary)
                    .foregroundColor(LiftTheme.Colors.secondary)
                    .cornerRadius(LiftTheme.Layout.cornerRadiusSmall)
                }
            } else {
                // Connected state UI
                HStack(spacing: LiftTheme.Layout.spacing24) {
                    VStack(spacing: 4) {
                        HStack(alignment: .firstTextBaseline, spacing: 2) {
                            Text("72")
                                .font(LiftTheme.Typography.bodyLarge.bold())
                                .foregroundColor(LiftTheme.Colors.primaryContent)
                            
                            Text("bpm")
                                .font(LiftTheme.Typography.caption)
                                .foregroundColor(LiftTheme.Colors.secondaryContent)
                        }
                        
                        Text("Avg HR")
                            .font(LiftTheme.Typography.caption)
                            .foregroundColor(LiftTheme.Colors.secondaryContent)
                    }
                    .frame(maxWidth: .infinity)
                    
                    VStack(spacing: 4) {
                        HStack(alignment: .firstTextBaseline, spacing: 2) {
                            Text("243")
                                .font(LiftTheme.Typography.bodyLarge.bold())
                                .foregroundColor(LiftTheme.Colors.primaryContent)
                            
                            Text("kcal")
                                .font(LiftTheme.Typography.caption)
                                .foregroundColor(LiftTheme.Colors.secondaryContent)
                        }
                        
                        Text("Last Workout")
                            .font(LiftTheme.Typography.caption)
                            .foregroundColor(LiftTheme.Colors.secondaryContent)
                    }
                    .frame(maxWidth: .infinity)
                }
            }
        }
        .padding()
        .background(LiftTheme.Colors.surface)
        .cornerRadius(LiftTheme.Layout.cornerRadiusMedium)
        .overlay(
            RoundedRectangle(cornerRadius: LiftTheme.Layout.cornerRadiusMedium)
                .stroke(LiftTheme.Colors.surfaceBorder, lineWidth: LiftTheme.Layout.borderWidthThin)
        )
    }
    
    // MARK: - Apple Watch Promo
    private var watchAppPromo: some View {
        HStack(spacing: LiftTheme.Layout.spacing16) {
            // Watch icon
            ZStack {
                Circle()
                    .fill(LiftTheme.Colors.secondaryBackground)
                    .frame(width: 70, height: 70)
                
                Image(systemName: "applewatch")
                    .font(.system(size: 32))
                    .foregroundColor(LiftTheme.Colors.primary)
            }
            
            // Promo content
            VStack(alignment: .leading, spacing: LiftTheme.Layout.spacing8) {
                Text("LIFT Watch App")
                    .font(LiftTheme.Typography.subtitle)
                    .foregroundColor(LiftTheme.Colors.primaryContent)
                
                Text("Track workouts from your wrist and seamlessly sync with your iPhone. Coming soon!")
                    .font(LiftTheme.Typography.bodySmall)
                    .foregroundColor(LiftTheme.Colors.secondaryContent)
                
                Button(action: {
                    // Handle notification signup
                }) {
                    Text("Get Notified")
                        .font(LiftTheme.Typography.button)
                        .padding(.vertical, 6)
                        .padding(.horizontal, 12)
                        .background(LiftTheme.Colors.secondaryBackground)
                        .foregroundColor(LiftTheme.Colors.primary)
                        .cornerRadius(LiftTheme.Layout.cornerRadiusSmall)
                }
                .padding(.top, LiftTheme.Layout.spacing4)
            }
        }
        .padding()
        .background(LiftTheme.Colors.surface)
        .cornerRadius(LiftTheme.Layout.cornerRadiusMedium)
        .overlay(
            RoundedRectangle(cornerRadius: LiftTheme.Layout.cornerRadiusMedium)
                .stroke(LiftTheme.Colors.surfaceBorder, lineWidth: LiftTheme.Layout.borderWidthThin)
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
