import SwiftUI
import Foundation
// Import necessary models
import LiftTrackUltimate

struct EditProfileView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var editedProfile: UserProfile
    let profile: UserProfile
    let onSave: (UserProfile) -> Void
    
    init(profile: UserProfile, onSave: @escaping (UserProfile) -> Void) {
        self.profile = profile
        self._editedProfile = State(initialValue: profile)
        self.onSave = onSave
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Personal Information")) {
                    TextField("Name", text: $editedProfile.name)
                    
                    Stepper("Age: \(editedProfile.age)", value: $editedProfile.age, in: 0...120)
                    
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
                    Picker("Level", selection: $editedProfile.fitnessLevel) {
                        Text("Beginner").tag(UserProfile.FitnessLevel.beginner)
                        Text("Intermediate").tag(UserProfile.FitnessLevel.intermediate)
                        Text("Advanced").tag(UserProfile.FitnessLevel.advanced)
                    }
                }
                
                Section(header: Text("Goals")) {
                    Stepper("Weekly Workouts: \(editedProfile.weeklyGoal)", value: $editedProfile.weeklyGoal, in: 1...7)
                    
                    HStack {
                        Text("Workout Duration")
                        Spacer()
                        TextField("Duration", value: Binding(
                            get: { editedProfile.preferredWorkoutDuration / 60 },
                            set: { editedProfile.preferredWorkoutDuration = $0 * 60 }
                        ), format: .number)
                        .keyboardType(.numberPad)
                        .multilineTextAlignment(.trailing)
                        Text("min")
                    }
                }
            }
            .navigationTitle("Edit Profile")
            .navigationBarTitleDisplayMode(.inline)
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