import SwiftUI

struct NewExerciseView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var dataManager: DataManager
    
    @State private var name = ""
    @State private var category = "Strength"
    @State private var instructions = ""
    @State private var selectedMuscleGroups: Set<String> = []
    
    // Available categories
    let categories = ["Strength", "Cardio", "Flexibility", "Balance", "Core"]
    
    // Available muscle groups with organized sections
    let muscleGroups = [
        "Chest", "Upper Chest", "Lower Chest",
        "Back", "Upper Back", "Lower Back", "Lats", "Traps",
        "Shoulders", "Front Delts", "Side Delts", "Rear Delts",
        "Arms", "Biceps", "Triceps", "Forearms",
        "Legs", "Quadriceps", "Hamstrings", "Calves", "Glutes",
        "Core", "Abdominals", "Obliques"
    ]
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Exercise Details")) {
                    TextField("Exercise Name", text: $name)
                    
                    Picker("Category", selection: $category) {
                        ForEach(categories, id: \.self) { category in
                            Text(category).tag(category)
                        }
                    }
                    
                    VStack(alignment: .leading) {
                        Text("Instructions")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        TextEditor(text: $instructions)
                            .frame(minHeight: 100)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.secondary.opacity(0.3), lineWidth: 1)
                            )
                    }
                }
                
                Section(header: Text("Muscle Groups")) {
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 120))], spacing: 10) {
                        ForEach(muscleGroups, id: \.self) { muscleGroup in
                            MuscleGroupSelectionButton(
                                muscleGroup: muscleGroup,
                                isSelected: selectedMuscleGroups.contains(muscleGroup),
                                onToggle: {
                                    if selectedMuscleGroups.contains(muscleGroup) {
                                        selectedMuscleGroups.remove(muscleGroup)
                                    } else {
                                        selectedMuscleGroups.insert(muscleGroup)
                                    }
                                }
                            )
                        }
                    }
                    .padding(.vertical, 8)
                }
            }
            .navigationTitle("New Exercise")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveNewExercise()
                    }
                    .disabled(name.isEmpty || selectedMuscleGroups.isEmpty)
                }
            }
        }
    }
    
    private func saveNewExercise() {
        let newExercise = Exercise(
            name: name,
            category: category,
            muscleGroups: Array(selectedMuscleGroups),
            instructions: instructions
        )
        
        // Update the data manager with the new exercise
        var updatedExercises = dataManager.exercises
        updatedExercises.append(newExercise)
        dataManager.updateExercises(updatedExercises)
        
        dismiss()
    }
}
