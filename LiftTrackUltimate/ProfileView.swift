import SwiftUI

struct ProfileView: View {
    @State private var profile = UserProfile(name: "User", fitnessGoal: "Build Muscle")
    @State private var showingEditScreen = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Profile header
                VStack(spacing: 8) {
                    Image(systemName: "person.circle.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 100, height: 100)
                        .foregroundColor(.blue)
                    
                    Text(profile.name)
                        .font(.title)
                        .fontWeight(.bold)
                }
                .padding()
                
                // Profile details
                VStack(alignment: .leading, spacing: 15) {
                    ProfileRow(title: "Age", value: profile.age != nil ? "\(profile.age!)" : "Not set")
                    ProfileRow(title: "Weight", value: profile.weight != nil ? "\(profile.weight!) kg" : "Not set")
                    ProfileRow(title: "Height", value: profile.height != nil ? "\(profile.height!) cm" : "Not set")
                    ProfileRow(title: "Goal", value: profile.fitnessGoal)
                }
                .padding()
                .background(Color(.systemBackground))
                .cornerRadius(10)
                .shadow(radius: 2)
                
                // Workout stats summary will go here
                
                Spacer()
            }
            .padding()
            .navigationTitle("Profile")
            .toolbar {
                Button("Edit") {
                    showingEditScreen = true
                }
            }
            .sheet(isPresented: $showingEditScreen) {
                ProfileEditView(profile: $profile)
            }
        }
    }
}

struct ProfileRow: View {
    var title: String
    var value: String
    
    var body: some View {
        HStack {
            Text(title)
                .fontWeight(.medium)
                .foregroundColor(.secondary)
            Spacer()
            Text(value)
                .fontWeight(.semibold)
        }
    }
}
