import SwiftUI

struct ProfileEditView: View {
    @Binding var profile: UserProfile
    var onSave: () -> Void
    @Environment(\.presentationMode) var presentationMode
    
    // Strings for optional values
    @State private var heightString: String = ""
    @State private var weightString: String = ""
    
    // Available fitness goals
    let fitnessGoals = [
        "Strength Training",
        "Muscle Building",
        "Weight Loss",
        "Endurance",
        "Athletic Performance",
        "General Fitness"
    ]
    
    init(profile: Binding<UserProfile>, onSave: @escaping () -> Void) {
        self._profile = profile
        self.onSave = onSave
        
        // Initialize height string if available
        if let height = profile.wrappedValue.height {
            self._heightString = State(initialValue: String(format: "%.1f", height))
        }
        
        // Initialize weight string if available
        if let weight = profile.wrappedValue.weight {
            self._weightString = State(initialValue: String(format: "%.1f", weight))
        }
    }
    
    var body: some View {
        NavigationView {
            Form {
                // Personal Information
                Section(header: Text("Personal Information").font(LiftTheme.Typography.captionBold)) {
                    TextField("Name", text: $profile.name)
                        .font(LiftTheme.Typography.body)
                    
                    Picker("Fitness Goal", selection: $profile.fitnessGoal) {
                        ForEach(fitnessGoals, id: \.self) { goal in
                            Text(goal).tag(goal)
                        }
                    }
                    .font(LiftTheme.Typography.body)
                }
                
                // Physical Information
                Section(header: Text("Physical Information").font(LiftTheme.Typography.captionBold)) {
                    TextField("Height (cm)", text: $heightString)
                        .font(LiftTheme.Typography.body)
                        .keyboardType(.decimalPad)
                    
                    TextField("Weight (kg)", text: $weightString)
                        .font(LiftTheme.Typography.body)
                        .keyboardType(.decimalPad)
                }
                
                // Birth Date (if needed)
                if let birthDate = profile.birthDate {
                    Section(header: Text("Birth Date").font(LiftTheme.Typography.captionBold)) {
                        DatePicker(
                            "Birth Date",
                            selection: Binding(
                                get: { birthDate },
                                set: { profile.birthDate = $0 }
                            ),
                            displayedComponents: .date
                        )
                        .font(LiftTheme.Typography.body)
                    }
                }
            }
            .navigationTitle("Edit Profile")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                leading: Button("Cancel") {
                    presentationMode.wrappedValue.dismiss()
                }
                .foregroundColor(LiftTheme.Colors.primary),
                
                trailing: Button("Save") {
                    saveProfile()
                }
                .font(.body.bold())
                .foregroundColor(LiftTheme.Colors.primary)
            )
        }
    }
    
    private func saveProfile() {
        // Convert height string to Double if possible
        if let height = Double(heightString) {
            profile.height = height
        }
        
        // Convert weight string to Double if possible
        if let weight = Double(weightString) {
            profile.weight = weight
        }
        
        // Call the save callback
        onSave()
        
        // Dismiss the sheet
        presentationMode.wrappedValue.dismiss()
    }
}
