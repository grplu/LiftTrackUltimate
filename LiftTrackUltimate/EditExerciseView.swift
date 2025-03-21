import SwiftUI

struct EditExerciseView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var dataManager: DataManager
    
    @State private var name: String
    @State private var category: String
    @State private var instructions: String
    @State private var selectedMuscleGroups: Set<String>
    
    private var originalExercise: Exercise
    var onSave: (Exercise) -> Void
    
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
    
    init(exercise: Exercise, onSave: @escaping (Exercise) -> Void) {
        self.originalExercise = exercise
        self.onSave = onSave
        
        // Initialize state with safe unwrapping of optional values
        self._name = State(initialValue: exercise.name)
        self._category = State(initialValue: exercise.category)
        self._instructions = State(initialValue: exercise.instructions ?? "")
        self._selectedMuscleGroups = State(initialValue: Set(exercise.muscleGroups))
    }
    
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
            .navigationTitle("Edit Exercise")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveExercise()
                    }
                    .disabled(name.isEmpty || selectedMuscleGroups.isEmpty)
                }
            }
        }
    }
    
    private func saveExercise() {
        let updatedExercise = Exercise(
            id: originalExercise.id,
            name: name,
            category: category,
            muscleGroups: Array(selectedMuscleGroups),
            instructions: instructions.isEmpty ? nil : instructions
        )
        
        onSave(updatedExercise)
        dismiss()
    }
}
