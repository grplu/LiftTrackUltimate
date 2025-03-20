import SwiftUI

struct TemplateDetailView: View {
    @EnvironmentObject var dataManager: DataManager
    @Environment(\.dismiss) private var dismiss
    @State private var showingDeleteAlert = false
    @State private var showingEditView = false
    @State private var isWorkoutActive = false
    
    var template: WorkoutTemplate
    
    var body: some View {
        List {
            ForEach(template.exercises.indices, id: \.self) { index in
                VStack(alignment: .leading, spacing: 5) {
                    Text(template.exercises[index].exercise.name)
                        .font(.headline)
                    
                    HStack {
                        Text("\(template.exercises[index].targetSets) sets")
                        
                        if let reps = template.exercises[index].targetReps {
                            Text("•")
                            Text("\(reps) reps")
                        }
                    }
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                }
                .padding(.vertical, 5)
            }
        }
        .navigationTitle(template.name)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Menu {
                    Button(action: {
                        showingEditView = true
                    }) {
                        Label("Edit Template", systemImage: "pencil")
                    }
                    
                    Button(role: .destructive, action: {
                        showingDeleteAlert = true
                    }) {
                        Label("Delete Template", systemImage: "trash")
                    }
                    
                    Button(action: {
                        // Start workout with this template
                        isWorkoutActive = true
                    }) {
                        Label("Start Workout", systemImage: "figure.run")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                }
            }
        }
        .sheet(isPresented: $showingEditView) {
            EditTemplateView(template: template) { updatedTemplate in
                dataManager.updateTemplate(updatedTemplate)
                showingEditView = false
            }
            .environmentObject(dataManager)
        }
        .sheet(isPresented: $isWorkoutActive) {
            // Use the existing ActiveWorkoutView which expects a template
            ActiveWorkoutView(
                template: template,
                onEnd: {
                    isWorkoutActive = false
                }
            )
            .environmentObject(dataManager)
        }
        .alert("Delete Template", isPresented: $showingDeleteAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                dataManager.deleteTemplate(template)
                dismiss()
            }
        } message: {
            Text("Are you sure you want to delete this template? This action cannot be undone.")
        }
    }
}
