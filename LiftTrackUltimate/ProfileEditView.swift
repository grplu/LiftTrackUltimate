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
        _age = State(initialValue: profile.wrappedValue.birthDate != nil ?
            String(Calendar.current.component(.year, from: Date()) - Calendar.current.component(.year, from: profile.wrappedValue.birthDate!)) : "")
        _weight = State(initialValue: profile.wrappedValue.weight != nil ?
            String(format: "%.1f", profile.wrappedValue.weight!) : "")
        _height = State(initialValue: profile.wrappedValue.height != nil ?
            String(format: "%.1f", profile.wrappedValue.height!) : "")
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
        
        // Calculate birthDate from age
        if let ageValue = Int(age) {
            let currentYear = Calendar.current.component(.year, from: Date())
            profile.birthDate = Calendar.current.date(from: DateComponents(year: currentYear - ageValue))
        }
        
        profile.weight = Double(weight)
        profile.height = Double(height)
        profile.fitnessGoal = fitnessGoal
    }
}
