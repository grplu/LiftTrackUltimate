import SwiftUI

struct ExerciseDetailView: View {
    @EnvironmentObject var dataManager: DataManager
    @Environment(\.dismiss) private var dismiss
    @State private var showingEditView = false
    @State private var showingDeleteAlert = false
    
    var exercise: Exercise
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Header section
                VStack(alignment: .leading, spacing: 5) {
                    Text(exercise.name)
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    Text(exercise.category)
                        .font(.headline)
                        .foregroundColor(.secondary)
                }
                .padding()
                
                // Muscles targeted
                VStack(alignment: .leading, spacing: 10) {
                    Text("Muscles Targeted")
                        .font(.headline)
                    
                    // Wrap in a ScrollView to handle many muscle groups
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack {
                            ForEach(exercise.muscleGroups, id: \.self) { muscle in
                                Text(muscle)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
                                    .background(Color.blue.opacity(0.1))
                                    .foregroundColor(.blue)
                                    .cornerRadius(20)
                            }
                        }
                    }
                }
                .padding()
                
                // Instructions
                if let instructions = exercise.instructions {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Instructions")
                            .font(.headline)
                        
                        Text(instructions)
                            .foregroundColor(.secondary)
                    }
                    .padding()
                } else {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Instructions")
                            .font(.headline)
                        
                        Text("No detailed instructions available for this exercise.")
                            .foregroundColor(.secondary)
                    }
                    .padding()
                }
            }
        }
        .navigationTitle("Exercise Details")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Menu {
                    Button(action: {
                        showingEditView = true
                    }) {
                        Label("Edit Exercise", systemImage: "pencil")
                    }
                    
                    Button(role: .destructive, action: {
                        showingDeleteAlert = true
                    }) {
                        Label("Delete Exercise", systemImage: "trash")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                }
            }
        }
        .sheet(isPresented: $showingEditView) {
            EditExerciseView(exercise: exercise) { updatedExercise in
                // Find and update the exercise in the data manager
                var updatedExercises = dataManager.exercises
                if let index = updatedExercises.firstIndex(where: { $0.id == exercise.id }) {
                    updatedExercises[index] = updatedExercise
                    dataManager.updateExercises(updatedExercises)
                }
            }
            .environmentObject(dataManager)
        }
        .alert("Delete Exercise", isPresented: $showingDeleteAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                // Filter out this exercise
                let updatedExercises = dataManager.exercises.filter { $0.id != exercise.id }
                dataManager.updateExercises(updatedExercises)
                dismiss()
            }
        } message: {
            Text("Are you sure you want to delete this exercise? This action cannot be undone.")
        }
    }
}
