import SwiftUI
// Import necessary models

struct ProfileEditView: View {
    @Environment(\.dismiss) var dismiss
    @State private var editedProfile: UserProfile
    
    let profile: UserProfile
    let onSave: (UserProfile) -> Void
    
    init(profile: UserProfile, onSave: @escaping (UserProfile) -> Void) {
        self.profile = profile
        self.onSave = onSave
        _editedProfile = State(initialValue: profile)
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Personal Information")) {
                    TextField("Name", text: $editedProfile.name)
                    
                    Stepper(value: $editedProfile.age, in: 16...100) {
                        Text("Age: \(editedProfile.age)")
                    }
                    
                    HStack {
                        Text("Weight")
                        Spacer()
                        TextField("Weight", value: $editedProfile.weight, format: .number)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                        Text("kg")
                    }
                    
                    HStack {
                        Text("Height")
                        Spacer()
                        TextField("Height", value: $editedProfile.height, format: .number)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                        Text("cm")
                    }
                }
                
                Section(header: Text("Fitness Level")) {
                    Picker("Fitness Level", selection: $editedProfile.fitnessLevel) {
                        Text("Beginner").tag(UserProfile.FitnessLevel.beginner)
                        Text("Intermediate").tag(UserProfile.FitnessLevel.intermediate)
                        Text("Advanced").tag(UserProfile.FitnessLevel.advanced)
                    }
                }
                
                Section(header: Text("Goals")) {
                    Stepper(value: $editedProfile.weeklyGoal, in: 1...7) {
                        Text("Weekly workouts: \(editedProfile.weeklyGoal)")
                    }
                    
                    HStack {
                        Text("Workout duration")
                        Spacer()
                        Picker("", selection: $editedProfile.preferredWorkoutDuration) {
                            Text("30 min").tag(TimeInterval(30 * 60))
                            Text("45 min").tag(TimeInterval(45 * 60))
                            Text("60 min").tag(TimeInterval(60 * 60))
                            Text("90 min").tag(TimeInterval(90 * 60))
                        }
                        .pickerStyle(MenuPickerStyle())
                    }
                }
            }
            .navigationTitle("Edit Profile")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        onSave(editedProfile)
                        dismiss()
                    }
                }
            }
        }
    }
} 