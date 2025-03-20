import SwiftUI

struct NewTemplateView: View {
    @State private var templateName = ""
    @State private var selectedExercises: [TemplateExercise] = []
    @State private var showingExerciseSelection = false
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var dataManager: DataManager
    
    var onSave: (WorkoutTemplate) -> Void
    
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
                    ForEach(selectedExercises) { templateExercise in
                        VStack(alignment: .leading, spacing: 5) {
                            Text(templateExercise.exercise.name)
                                .font(.headline)
                            
                            HStack {
                                Text("\(templateExercise.targetSets) sets")
                                
                                if let reps = templateExercise.targetReps {
                                    Text("•")
                                    Text("\(reps) reps")
                                }
                            }
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        }
                        .padding(.vertical, 5)
                    }
                    .onDelete(perform: { indexSet in
                        selectedExercises.remove(atOffsets: indexSet)
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
            .navigationTitle("New Template")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        let newTemplate = WorkoutTemplate(
                            name: templateName.isEmpty ? "New Template" : templateName,
                            exercises: selectedExercises
                        )
                        onSave(newTemplate)
                    }
                    .disabled(selectedExercises.isEmpty)
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
