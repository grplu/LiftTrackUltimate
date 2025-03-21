import SwiftUI

struct NewTemplateView: View {
    @State private var templateName = ""
    @State private var selectedExercises: [TemplateExercise] = []
    @State private var showingExerciseSelection = false
    @State private var buttonScale: CGFloat = 1.0
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
                        HStack {
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
                        }
                        .padding(.vertical, 5)
                    }
                    .onDelete(perform: { indexSet in
                        selectedExercises.remove(atOffsets: indexSet)
                    })
                }
                
                // Add exercise button with cute animation
                Button(action: {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.5)) {
                        buttonScale = 1.2
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.5)) {
                            buttonScale = 1.0
                            showingExerciseSelection = true
                        }
                    }
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
                    .scaleEffect(buttonScale)
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
                        addExerciseToTemplate(exercise)
                        showingExerciseSelection = false
                    },
                    onSelectMultiple: { exercises in
                        for exercise in exercises {
                            addExerciseToTemplate(exercise)
                        }
                    }
                )
                .environmentObject(dataManager)
            }
        }
    }
    
    // Helper function to add an exercise to the template
    private func addExerciseToTemplate(_ exercise: Exercise) {
        // Check for last performance
        let lastPerformance = dataManager.getLastPerformance(for: exercise)
        
        let templateExercise = TemplateExercise(
            exercise: exercise,
            targetSets: lastPerformance?.totalSets ?? 3,
            targetReps: lastPerformance?.lastUsedReps ?? 10
        )
        selectedExercises.append(templateExercise)
    }
}
