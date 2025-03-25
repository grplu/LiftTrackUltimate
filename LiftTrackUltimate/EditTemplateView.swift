import SwiftUI

struct EditTemplateView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var dataManager: DataManager
    
    // Track the original template (if editing)
    var originalTemplate: WorkoutTemplate?
    
    @State private var templateName: String
    @State private var selectedExercises: [TemplateExercise]
    @State private var showingExerciseSelection = false
    
    // Flexible initializer for both new and existing templates
    init(template: WorkoutTemplate? = nil) {
        self.originalTemplate = template
        
        // Use existing template details or defaults
        _templateName = State(initialValue: template?.name ?? "New Template")
        _selectedExercises = State(initialValue: template?.exercises ?? [])
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
                            ForEach(selectedExercises.indices, id: \.self) { index in
                                HStack {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(selectedExercises[index].exercise.name)
                                            .font(.headline)
                                            .foregroundColor(.white)
                                        
                                        let repsText = selectedExercises[index].targetReps != nil ?
                                            "\(selectedExercises[index].targetReps!)" : "0"
                                        Text("\(selectedExercises[index].targetSets) sets × \(repsText) reps")
                                            .font(.subheadline)
                                            .foregroundColor(.gray)
                                    }
                                    
                                    Spacer()
                                    
                                    Button(action: {
                                        // Remove exercise from selection
                                        selectedExercises.remove(at: index)
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
            .navigationBarTitle(originalTemplate == nil ? "Create Template" : "Edit Template", displayMode: .inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        let updatedTemplate = WorkoutTemplate(
                            id: originalTemplate?.id ?? UUID(),
                            name: templateName.isEmpty ? "New Template" : templateName,
                            exercises: selectedExercises
                        )
                        
                        // Determine if it's a new or existing template
                        if originalTemplate == nil {
                            dataManager.saveTemplate(updatedTemplate)
                        } else {
                            dataManager.updateTemplate(updatedTemplate)
                        }
                        
                        dismiss()
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
}
