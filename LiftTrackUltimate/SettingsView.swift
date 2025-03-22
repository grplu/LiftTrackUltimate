import SwiftUI
import HealthKit

struct SettingsView: View {
    @Binding var isPresented: Bool
    @EnvironmentObject var dataManager: DataManager
    @AppStorage("useMetricSystem") private var useMetricSystem = true
    @AppStorage("notificationsEnabled") private var notificationsEnabled = true
    @AppStorage("healthKitAutoSync") private var healthKitAutoSync = false
    
    @State private var showingExportSheet = false
    @State private var showingResetConfirmation = false
    @State private var showingPrivacyPolicy = false
    @State private var showingTermsOfService = false
    
    let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
    let buildNumber = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
    
    var body: some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(.all)
            
            ScrollView {
                VStack(spacing: 20) {
                    // App Preferences
                    sectionCard {
                        HStack {
                            Circle()
                                .fill(Color.white)
                                .frame(width: 40, height: 40)
                                .overlay(
                                    Image(systemName: "gear")
                                        .font(.system(size: 22))
                                        .foregroundColor(.black)
                                )
                            
                            Text("App Preferences")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                            
                            Spacer()
                        }
                        .padding(.bottom, 8)
                        
                        // Toggle for Notifications
                        Toggle("Notifications", isOn: $notificationsEnabled)
                            .toggleStyle(CustomToggleStyle())
                            .padding(.vertical, 4)
                        
                        // Toggle for HealthKit Auto-Sync
                        Toggle("Auto-sync with Apple Health", isOn: $healthKitAutoSync)
                            .toggleStyle(CustomToggleStyle())
                            .padding(.vertical, 4)
                    }
                    
                    // HealthKit Integration Section
                    HealthKitSettingsSection()
                    
                    // Units
                    sectionCard {
                        HStack {
                            Circle()
                                .fill(Color.white)
                                .frame(width: 40, height: 40)
                                .overlay(
                                    Image(systemName: "ruler")
                                        .font(.system(size: 22))
                                        .foregroundColor(.black)
                                )
                            
                            Text("Units")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                            
                            Spacer()
                        }
                        .padding(.bottom, 16)
                        
                        // Custom segmented control to ensure text visibility
                        HStack(spacing: 0) {
                            Button(action: {
                                useMetricSystem = true
                                dataManager.profile.useMetricSystem = true
                                dataManager.saveProfile(dataManager.profile)
                            }) {
                                Text("Metric")
                                    .font(.body)
                                    .padding(.vertical, 12)
                                    .frame(maxWidth: .infinity)
                                    .foregroundColor(useMetricSystem ? .black : .white)
                                    .background(useMetricSystem ? Color.white : Color.clear)
                            }
                            .cornerRadius(8)
                            
                            Button(action: {
                                useMetricSystem = false
                                dataManager.profile.useMetricSystem = false
                                dataManager.saveProfile(dataManager.profile)
                            }) {
                                Text("Imperial")
                                    .font(.body)
                                    .padding(.vertical, 12)
                                    .frame(maxWidth: .infinity)
                                    .foregroundColor(!useMetricSystem ? .black : .white)
                                    .background(!useMetricSystem ? Color.white : Color.clear)
                            }
                            .cornerRadius(8)
                        }
                        .background(Color.gray.opacity(0.3))
                        .cornerRadius(8)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.gray.opacity(0.5), lineWidth: 1)
                        )
                        
                        // Information text about unit conversion
                        Text("Changing units will automatically convert your recorded data")
                            .font(.footnote)
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                            .padding(.top, 12)
                    }
                    
                    // Data Management
                    sectionCard {
                        HStack {
                            Circle()
                                .fill(Color.white)
                                .frame(width: 40, height: 40)
                                .overlay(
                                    Image(systemName: "externaldrive")
                                        .font(.system(size: 22))
                                        .foregroundColor(.black)
                                )
                            
                            Text("Data Management")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                            
                            Spacer()
                        }
                        .padding(.bottom, 16)
                        
                        VStack(spacing: 0) {
                            // Export data button
                            Button(action: {
                                showingExportSheet = true
                            }) {
                                HStack {
                                    Image(systemName: "square.and.arrow.up")
                                        .font(.system(size: 20))
                                        .frame(width: 26, height: 26)
                                        .foregroundColor(.white)
                                    
                                    Text("Export Workout Data")
                                        .font(.body)
                                        .foregroundColor(.white)
                                    
                                    Spacer()
                                    
                                    Image(systemName: "chevron.right")
                                        .foregroundColor(.gray)
                                        .font(.system(size: 14))
                                }
                                .padding(.vertical, 12)
                            }
                            
                            Divider()
                                .background(Color.gray.opacity(0.3))
                            
                            // Reset data button
                            Button(action: {
                                showingResetConfirmation = true
                            }) {
                                HStack {
                                    Image(systemName: "trash")
                                        .font(.system(size: 20))
                                        .frame(width: 26, height: 26)
                                        .foregroundColor(.red)
                                    
                                    Text("Reset All Data")
                                        .font(.body)
                                        .foregroundColor(.red)
                                    
                                    Spacer()
                                }
                                .padding(.vertical, 12)
                            }
                        }
                    }
                    
                    // About
                    sectionCard {
                        HStack {
                            Circle()
                                .fill(Color.white)
                                .frame(width: 40, height: 40)
                                .overlay(
                                    Image(systemName: "info.circle")
                                        .font(.system(size: 22))
                                        .foregroundColor(.black)
                                )
                            
                            Text("About")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                            
                            Spacer()
                        }
                        .padding(.bottom, 16)
                        
                        VStack(spacing: 0) {
                            // Version info
                            HStack {
                                Text("Version")
                                    .font(.body)
                                    .foregroundColor(.white)
                                
                                Spacer()
                                
                                Text("\(appVersion) (\(buildNumber))")
                                    .font(.body)
                                    .foregroundColor(.gray)
                            }
                            .padding(.vertical, 12)
                            
                            Divider()
                                .background(Color.gray.opacity(0.3))
                            
                            // Privacy Policy
                            Button(action: {
                                showingPrivacyPolicy = true
                            }) {
                                HStack {
                                    Text("Privacy Policy")
                                        .font(.body)
                                        .foregroundColor(.white)
                                    
                                    Spacer()
                                    
                                    Image(systemName: "chevron.right")
                                        .foregroundColor(.gray)
                                        .font(.system(size: 14))
                                }
                                .padding(.vertical, 12)
                            }
                            
                            Divider()
                                .background(Color.gray.opacity(0.3))
                            
                            // Terms of Service
                            Button(action: {
                                showingTermsOfService = true
                            }) {
                                HStack {
                                    Text("Terms of Service")
                                        .font(.body)
                                        .foregroundColor(.white)
                                    
                                    Spacer()
                                    
                                    Image(systemName: "chevron.right")
                                        .foregroundColor(.gray)
                                        .font(.system(size: 14))
                                }
                                .padding(.vertical, 12)
                            }
                        }
                    }
                }
                .padding(16)
            }
        }
        .navigationBarTitle("", displayMode: .inline)
        .navigationBarItems(trailing: Button("Done") {
            isPresented = false
        }
        .foregroundColor(.white))
        .alert(isPresented: $showingResetConfirmation) {
            Alert(
                title: Text("Reset All Data"),
                message: Text("This will permanently delete all your workouts, exercises, templates, and profile information. This action cannot be undone."),
                primaryButton: .destructive(Text("Reset")) {
                    dataManager.resetAllData()
                },
                secondaryButton: .cancel()
            )
        }
        .sheet(isPresented: $showingPrivacyPolicy) {
            legalDocumentView(title: "Privacy Policy", content: privacyPolicyText)
        }
        .sheet(isPresented: $showingTermsOfService) {
            legalDocumentView(title: "Terms of Service", content: termsOfServiceText)
        }
    }
    
    // MARK: - Section Card
    private func sectionCard<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            content()
        }
        .padding(16)
        .background(Color.black)
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
        )
    }
    
    // MARK: - Legal Document View
    private func legalDocumentView(title: String, content: String) -> some View {
        NavigationView {
            ScrollView {
                Text(content)
                    .font(.body)
                    .foregroundColor(.white)
                    .padding()
            }
            .background(Color.black)
            .navigationTitle(title)
            .navigationBarItems(trailing: Button("Close") {
                if title == "Privacy Policy" {
                    showingPrivacyPolicy = false
                } else {
                    showingTermsOfService = false
                }
            }
            .foregroundColor(.white))
        }
        .preferredColorScheme(.dark)
    }
    
    // Sample content for legal documents
    private let privacyPolicyText = """
    Privacy Policy for LIFT App

    Last Updated: March 22, 2024

    This Privacy Policy describes how LIFT collects, uses, and discloses your information when you use our mobile application.

    Information We Collect:
    - Personal information you provide (name, email, profile data)
    - Workout data and fitness tracking information
    - Device information and usage statistics
    - Health and fitness data when you authorize Apple Health integration

    How We Use Your Information:
    - To provide and improve our fitness tracking services
    - To personalize your experience and workout recommendations
    - To communicate with you about updates and features
    - To sync with Apple Health when authorized

    We do not sell your personal information to third parties.

    For questions about our privacy practices, please contact privacy@liftapp.com
    """
    
    private let termsOfServiceText = """
    Terms of Service for LIFT App

    Last Updated: March 22, 2024

    By using the LIFT app, you agree to these Terms of Service.

    1. Acceptable Use
    You agree to use the app for personal fitness tracking purposes and not for any illegal or prohibited activities.

    2. User Accounts
    You are responsible for maintaining the confidentiality of your account information.

    3. Intellectual Property
    All content and functionality in the app is the exclusive property of LIFT and is protected by copyright laws.

    4. Disclaimer of Warranties
    The app is provided "as is" without warranties of any kind.

    5. Limitation of Liability
    LIFT shall not be liable for any indirect, incidental, or consequential damages.

    For questions about these terms, please contact legal@liftapp.com
    """
}

// MARK: - Custom Toggle Style
struct CustomToggleStyle: ToggleStyle {
    func makeBody(configuration: Configuration) -> some View {
        HStack {
            configuration.label
                .font(.body)
                .foregroundColor(.white)
            
            Spacer()
            
            ZStack {
                Capsule()
                    .fill(configuration.isOn ? Color.white : Color.gray.opacity(0.3))
                    .frame(width: 50, height: 30)
                
                Circle()
                    .fill(configuration.isOn ? Color.black : Color.white)
                    .frame(width: 26, height: 26)
                    .shadow(radius: 1)
                    .offset(x: configuration.isOn ? 10 : -10)
                    .animation(.spring(response: 0.2, dampingFraction: 0.6), value: configuration.isOn)
            }
            .onTapGesture {
                configuration.isOn.toggle()
            }
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            SettingsView(isPresented: .constant(true))
                .environmentObject(DataManager.shared)
                .preferredColorScheme(.dark)
        }
    }
}
