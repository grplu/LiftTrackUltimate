import SwiftUI

struct EditTemplateView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var dataManager: DataManager
    
    @State private var templateName: String
    @State private var selectedExercises: [TemplateExercise]
    @State private var showingExerciseSelection = false
    
    private var originalTemplate: WorkoutTemplate
    var onSave: (WorkoutTemplate) -> Void
    
    init(template: WorkoutTemplate, onSave: @escaping (WorkoutTemplate) -> Void) {
        self.originalTemplate = template
        self._templateName = State(initialValue: template.name)
        self._selectedExercises = State(initialValue: template.exercises)
        self.onSave = onSave
    }
    
    var body: some View {
        NavigationView {
            VStack {
                // Template name input
                TextField("Template Name", text: $templateName)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                    .padding()
                
                // Selected exercises
                List {
                    ForEach(selectedExercises.indices, id: \.self) { index in
                        VStack(alignment: .leading, spacing: 5) {
                            Text(selectedExercises[index].exercise.name)
                                .font(.headline)
                            
                            HStack {
                                Stepper(
                                    "Sets: \(selectedExercises[index].targetSets)",
                                    value: Binding(
                                        get: { selectedExercises[index].targetSets },
                                        set: { newValue in
                                            var updated = selectedExercises[index]
                                            updated.targetSets = newValue
                                            selectedExercises[index] = updated
                                        }
                                    ),
                                    in: 1...10
                                )
                                .frame(maxWidth: 150)
                                
                                Spacer()
                                
                                if selectedExercises[index].targetReps != nil {
                                    Stepper(
                                        "Reps: \(selectedExercises[index].targetReps ?? 0)",
                                        value: Binding(
                                            get: { selectedExercises[index].targetReps ?? 0 },
                                            set: { newValue in
                                                var updated = selectedExercises[index]
                                                updated.targetReps = newValue
                                                selectedExercises[index] = updated
                                            }
                                        ),
                                        in: 1...100
                                    )
                                    .frame(maxWidth: 150)
                                }
                            }
                            .font(.subheadline)
                        }
                        .padding(.vertical, 5)
                    }
                    .onDelete(perform: { indexSet in
                        selectedExercises.remove(atOffsets: indexSet)
                    })
                    .onMove(perform: { indices, newOffset in
                        selectedExercises.move(fromOffsets: indices, toOffset: newOffset)
                    })
                }
                
                // Add exercise button
                Button(action: {
                    showingExerciseSelection = true
                }) {
                    HStack {
                        Image(systemName: "plus.circle.fill")
                        Text("Add Exercise")
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue.opacity(0.1))
                    .foregroundColor(.blue)
                    .cornerRadius(10)
                }
                .padding()
            }
            .navigationTitle("Edit Template")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        let updatedTemplate = WorkoutTemplate(
                            id: originalTemplate.id,
                            name: templateName.isEmpty ? "New Template" : templateName,
                            exercises: selectedExercises
                        )
                        onSave(updatedTemplate)
                    }
                    .disabled(selectedExercises.isEmpty)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    EditButton()
                }
            }
            .sheet(isPresented: $showingExerciseSelection) {
                ExerciseSelectionView(
                    onSelect: { exercise in
                        // Single selection callback
                        addExerciseToTemplate(exercise)
                        showingExerciseSelection = false
                    },
                    onSelectMultiple: { exercises in
                        // Multiple selection callback
                        for exercise in exercises {
                            addExerciseToTemplate(exercise)
                        }
                        // The view will dismiss itself after multi-selection
                    }
                )
                .environmentObject(dataManager)
            }
        }
    }
    
    // Helper function to add an exercise to the template
    private func addExerciseToTemplate(_ exercise: Exercise) {
        let templateExercise = TemplateExercise(
            exercise: exercise,
            targetSets: 3,
            targetReps: 10
        )
        selectedExercises.append(templateExercise)
    }
}
