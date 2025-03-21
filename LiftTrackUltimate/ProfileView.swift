import SwiftUI

struct ProfileView: View {
    @Binding var profile: UserProfile
    @State private var editButtonScale: CGFloat = 1.0
    
    var body: some View {
        VStack(spacing: 8) {
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
                    .padding()
            }
            
            // Profile details
            VStack(alignment: .leading, spacing: 15) {
                ProfileRow(title: "Age", value: profile.birthDate != nil ?
                    String(Calendar.current.component(.year, from: Date()) -
                           Calendar.current.component(.year, from: profile.birthDate!)) : "Not set")
                
                ProfileRow(title: "Weight", value: profile.weight != nil ?
                    String(format: "%.1f kg", profile.weight!) : "Not set")
                
                ProfileRow(title: "Height", value: profile.height != nil ?
                    String(format: "%.1f cm", profile.height!) : "Not set")
                
                ProfileRow(title: "Goal", value: profile.fitnessGoal)
            }
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(10)
            .shadow(radius: 2)
            
            Spacer()
            
            // Navigation title
            Text("Profile")
                .navigationTitle("Profile")
                .toolbar {
                    Button("Edit") {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.5)) {
                            editButtonScale = 1.2
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.5)) {
                                editButtonScale = 1.0
                                // Trigger edit action
                            }
                        }
                    }
                }
        }
        .padding()
    }
}

struct ProfileRow: View {
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Text(title)
                .foregroundColor(.secondary)
            Spacer()
            Text(value)
        }
    }
}
