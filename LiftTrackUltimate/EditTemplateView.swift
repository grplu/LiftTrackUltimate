import SwiftUI

struct EditTemplateView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var dataManager: DataManager
    
    var originalTemplate: WorkoutTemplate
    
    @State private var templateName: String
    @State private var selectedExercises: [TemplateExercise]
    @State private var showingExerciseSelection = false
    
    init(template: WorkoutTemplate) {
        self.originalTemplate = template
        _templateName = State(initialValue: template.name)
        _selectedExercises = State(initialValue: template.exercises)
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background color
                Color.black.edgesIgnoringSafeArea(.all)
                
                // Content
                VStack(spacing: 24) {
                    // Template name field
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Template Name")
                            .font(.headline)
                            .foregroundColor(.white)
                        
                        ZStack(alignment: .leading) {
                            if templateName.isEmpty {
                                Text("e.g. Upper Body Strength")
                                    .foregroundColor(.gray)
                            }
                            TextField("", text: $templateName)
                                .foregroundColor(.white)
                        }
                        .padding()
                        .background(Color(.systemGray6).opacity(0.2))
                        .cornerRadius(10)
                    }
                    
                    // Exercises section
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Text("Exercises")
                                .font(.headline)
                                .foregroundColor(.white)
                            
                            Spacer()
                            
                            Button(action: {
                                showingExerciseSelection = true
                            }) {
                                HStack {
                                    Image(systemName: "plus.circle.fill")
                                    Text("Add Exercise")
                                }
                                .foregroundColor(.blue)
                            }
                        }
                        
                        if selectedExercises.isEmpty {
                            VStack(spacing: 12) {
                                Image(systemName: "dumbbell.fill")
                                    .font(.system(size: 40))
                                    .foregroundColor(.gray)
                                    .padding(.top, 20)
                                
                                Text("No exercises added yet")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                
                                Text("Tap the button above to add exercises to your template")
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 30)
                        } else {
                            // List of selected exercises
                            ForEach(selectedExercises) { exercise in
                                HStack {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(exercise.exercise.name)
                                            .font(.headline)
                                            .foregroundColor(.white)
                                        
                                        let repsText = exercise.targetReps != nil ? "\(exercise.targetReps!)" : "0"
                                        Text("\(exercise.targetSets) sets × \(repsText) reps")
                                            .font(.subheadline)
                                            .foregroundColor(.gray)
                                    }
                                    
                                    Spacer()
                                    
                                    Button(action: {
                                        // Remove exercise from selection
                                        if let index = selectedExercises.firstIndex(where: { $0.id == exercise.id }) {
                                            selectedExercises.remove(at: index)
                                        }
                                    }) {
                                        Image(systemName: "xmark.circle.fill")
                                            .foregroundColor(.red)
                                    }
                                }
                                .padding()
                                .background(Color(.systemGray6).opacity(0.2))
                                .cornerRadius(10)
                            }
                        }
                    }
                    
                    Spacer()
                }
                .padding()
            }
            .navigationBarTitle("Edit Template", displayMode: .inline)
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
            }
            .sheet(isPresented: $showingExerciseSelection) {
                ExerciseSelectionView { exercise in
                    addExerciseToTemplate(exercise)
                }
                .environmentObject(dataManager)
            }
        }
    }
    
    // Helper function to add an exercise to the template
    private func addExerciseToTemplate(_ exercise: Exercise) {
        // Check for last performance
        let lastPerformance = dataManager.getLastPerformance(for: exercise)
        
        // Safely unwrap optionals or provide defaults
        let targetSets = lastPerformance?.totalSets ?? 3
        let targetReps = lastPerformance?.lastUsedReps ?? 10
        
        let templateExercise = TemplateExercise(
            exercise: exercise,
            targetSets: targetSets,
            targetReps: targetReps
        )
        
        selectedExercises.append(templateExercise)
    }
    
    private func onSave(_ template: WorkoutTemplate) {
        dataManager.updateTemplate(template)
        dismiss()
    }
}
