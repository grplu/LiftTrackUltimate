import SwiftUI
import HealthKit

struct HealthKitSettingsSection: View {
    @ObservedObject var healthKitManager = HealthKitManager.shared
    @State private var isShowingAuthorizationRequest = false
    @State private var showAlert = false
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    @State private var isLoading = false
    @State private var showingHeartRateMonitor = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header
            HStack {
                Circle()
                    .fill(Color.white)
                    .frame(width: 40, height: 40)
                    .overlay(
                        Image(systemName: "heart.fill")
                            .font(.system(size: 22))
                            .foregroundColor(.black)
                    )
                
                Text("Apple Health")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                Spacer()
            }
            .padding(.bottom, 16)
            
            if !healthKitManager.isHealthKitAvailable {
                // Device doesn't support HealthKit
                HStack {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.red)
                        .font(.system(size: 20))
                    
                    Text("Health data is not available on this device")
                        .font(.body)
                        .foregroundColor(.white)
                }
                .padding(.vertical)
            } else {
                // HealthKit connection status and button
                VStack(alignment: .leading, spacing: 16) {
                    HStack {
                        Image(systemName: healthKitManager.isAuthorized ? "checkmark.circle.fill" : "circle")
                            .foregroundColor(healthKitManager.isAuthorized ? .green : .gray)
                            .font(.system(size: 20))
                        
                        Text(healthKitManager.isAuthorized ? "Connected to Apple Health" : "Not connected to Apple Health")
                            .font(.body)
                            .foregroundColor(.white)
                    }
                    
                    if isLoading {
                        HStack {
                            Spacer()
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            Spacer()
                        }
                        .padding(.vertical, 8)
                    } else {
                        Button(action: {
                            if healthKitManager.isAuthorized {
                                // Show status and stats
                                isLoading = true
                                healthKitManager.fetchRecentWorkouts { success, error in
                                    isLoading = false
                                    if success {
                                        alertTitle = "Health Data"
                                        alertMessage = createHealthDataSummary()
                                    } else {
                                        alertTitle = "Error"
                                        alertMessage = "Failed to fetch health data: \(error?.localizedDescription ?? "Unknown error")"
                                    }
                                    showAlert = true
                                }
                            } else {
                                // Request authorization
                                isShowingAuthorizationRequest = true
                            }
                        }) {
                            HStack {
                                Text(healthKitManager.isAuthorized ? "View Health Data" : "Connect to Apple Health")
                                    .font(.body)
                                    .foregroundColor(.black)
                                
                                Spacer()
                                
                                Image(systemName: "arrow.right")
                                    .font(.system(size: 14))
                                    .foregroundColor(.black)
                            }
                            .padding()
                            .background(Color.white)
                            .cornerRadius(8)
                        }
                        
                        if healthKitManager.isAuthorized {
                            // Heart Rate Monitor Button
                            Button(action: {
                                showingHeartRateMonitor = true
                            }) {
                                HStack {
                                    Image(systemName: "heart.fill")
                                        .foregroundColor(.red)
                                    
                                    Text("Heart Rate Monitor")
                                        .font(.body)
                                        .foregroundColor(.black)
                                    
                                    Spacer()
                                    
                                    Image(systemName: "arrow.right")
                                        .font(.system(size: 14))
                                        .foregroundColor(.black)
                                }
                                .padding()
                                .background(Color.white)
                                .cornerRadius(8)
                            }
                            .padding(.top, 8)
                        }
                    }
                    
                    if healthKitManager.isAuthorized {
                        Text("Your workouts will be automatically synced with Apple Health")
                            .font(.footnote)
                            .foregroundColor(.gray)
                    } else {
                        Text("Connect to Apple Health to track your fitness progress across apps")
                            .font(.footnote)
                            .foregroundColor(.gray)
                    }
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
        .alert(isPresented: $showAlert) {
            Alert(
                title: Text(alertTitle),
                message: Text(alertMessage),
                dismissButton: .default(Text("OK"))
            )
        }
        .sheet(isPresented: $isShowingAuthorizationRequest) {
            HealthKitAuthorizationView(isPresented: $isShowingAuthorizationRequest)
        }
        .sheet(isPresented: $showingHeartRateMonitor) {
            NavigationView {
                HeartRateView()
                    .navigationTitle("Heart Rate Monitor")
                    .navigationBarItems(trailing: Button("Close") {
                        showingHeartRateMonitor = false
                    })
                    .preferredColorScheme(.dark)
            }
        }
        .onAppear {
            healthKitManager.getAuthorizationStatus()
        }
    }
    
    private func createHealthDataSummary() -> String {
        let stats = healthKitManager.workoutStats
        
        var summary = "Total Workouts: \(stats.totalWorkouts)\n"
        summary += "Total Workout Time: \(healthKitManager.formattedDuration(from: stats.totalDuration))\n"
        summary += "Total Calories Burned: \(Int(stats.totalCalories)) kcal\n"
        
        if let lastWorkout = stats.lastWorkoutDate {
            summary += "Last Workout: \(healthKitManager.formattedDate(from: lastWorkout))"
        }
        
        return summary
    }
}

struct HealthKitAuthorizationView: View {
    @Binding var isPresented: Bool
    @ObservedObject var healthKitManager = HealthKitManager.shared
    @State private var isLoading = false
    @State private var showError = false
    @State private var errorMessage = ""
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.black.edgesIgnoringSafeArea(.all)
                
                VStack(spacing: 30) {
                    Image(systemName: "heart.circle.fill")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 100, height: 100)
                        .foregroundColor(.white)
                    
                    Text("Connect to Apple Health")
                        .font(.title)
                        .bold()
                        .foregroundColor(.white)
                    
                    Text("LIFT would like to access your health data to track your workouts and provide better insights. Your data remains private and secure.")
                        .multilineTextAlignment(.center)
                        .foregroundColor(.white)
                        .padding(.horizontal)
                    
                    VStack(alignment: .leading, spacing: 15) {
                        HealthPermissionRow(icon: "flame.fill", text: "Active Energy Burned")
                        HealthPermissionRow(icon: "figure.walk", text: "Distance")
                        HealthPermissionRow(icon: "heart.fill", text: "Heart Rate")
                        HealthPermissionRow(icon: "dumbbell.fill", text: "Workouts")
                    }
                    .padding()
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(12)
                    
                    if isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .scaleEffect(1.5)
                            .padding()
                    } else {
                        Button(action: {
                            requestHealthAccess()
                        }) {
                            HStack {
                                Text("Allow Access")
                                    .bold()
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.white)
                            .foregroundColor(.black)
                            .cornerRadius(10)
                        }
                        .padding(.horizontal)
                        
                        Button(action: {
                            isPresented = false
                        }) {
                            Text("Not Now")
                                .foregroundColor(.gray)
                        }
                    }
                }
                .padding()
                .alert(isPresented: $showError) {
                    Alert(
                        title: Text("Error"),
                        message: Text(errorMessage),
                        dismissButton: .default(Text("OK")) {
                            isPresented = false
                        }
                    )
                }
            }
            .navigationBarItems(trailing: Button("Close") {
                isPresented = false
            }
            .foregroundColor(.white))
        }
    }
    
    private func requestHealthAccess() {
        isLoading = true
        healthKitManager.requestAuthorization { success, error in
            isLoading = false
            if success {
                isPresented = false
            } else {
                errorMessage = error?.localizedDescription ?? "Unable to access health data"
                showError = true
            }
        }
    }
}

struct HealthPermissionRow: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack(spacing: 15) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .frame(width: 30, height: 30)
                .foregroundColor(.white)
            
            Text(text)
                .foregroundColor(.white)
            
            Spacer()
        }
    }
}

struct HealthKitSettingsSection_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(.all)
            HealthKitSettingsSection()
                .padding()
        }
        .preferredColorScheme(.dark)
    }
}
