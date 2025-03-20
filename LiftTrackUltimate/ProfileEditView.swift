import SwiftUI

struct ProfileEditView: View {
    @Binding var profile: UserProfile
    @Environment(\.dismiss) private var dismiss
    
    @State private var name: String = ""
    @State private var age: String = ""
    @State private var weight: String = ""
    @State private var height: String = ""
    @State private var fitnessGoal: String = ""
    
    let goals = ["Weight Loss", "Build Muscle", "Improve Strength", "Improve Endurance", "General Fitness"]
    
    init(profile: Binding<UserProfile>) {
        self._profile = profile
        _name = State(initialValue: profile.wrappedValue.name)
        _age = State(initialValue: profile.wrappedValue.age != nil ? "\(profile.wrappedValue.age!)" : "")
        _weight = State(initialValue: profile.wrappedValue.weight != nil ? "\(profile.wrappedValue.weight!)" : "")
        _height = State(initialValue: profile.wrappedValue.height != nil ? "\(profile.wrappedValue.height!)" : "")
        _fitnessGoal = State(initialValue: profile.wrappedValue.fitnessGoal)
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Personal Information")) {
                    TextField("Name", text: $name)
                    TextField("Age", text: $age)
                        .keyboardType(.numberPad)
                    TextField("Weight (kg)", text: $weight)
                        .keyboardType(.decimalPad)
                    TextField("Height (cm)", text: $height)
                        .keyboardType(.decimalPad)
                    
                    Picker("Fitness Goal", selection: $fitnessGoal) {
                        ForEach(goals, id: \.self) {
                            Text($0)
                        }
                    }
                }
            }
            .navigationTitle("Edit Profile")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveProfile()
                        dismiss()
                    }
                }
            }
        }
    }
    
    func saveProfile() {
        profile.name = name
        profile.age = Int(age)
        profile.weight = Double(weight)
        profile.height = Double(height)
        profile.fitnessGoal = fitnessGoal
    }
}
