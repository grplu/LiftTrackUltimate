import SwiftUI

struct WorkoutView: View {
    @EnvironmentObject var dataManager: DataManager
    @State private var selectedTemplate: WorkoutTemplate?
    @State private var showingDeleteAlert = false
    @State private var templateToDelete: WorkoutTemplate?
    @State private var showingEditSheet = false
    @State private var templateToEdit: WorkoutTemplate?
    @State private var showingCreateTemplateSheet = false
    @State private var selectedBodyPart: String? = nil
    @State private var showDropdown = false
    @State private var animateCards = false
    @State private var showingTemplateDetail = false
    
    // Added bodyParts array
    private let bodyParts = ["All", "Chest", "Back", "Shoulders", "Arms", "Core", "Legs"]
    
    // Store the ID of the template being confirmed, if any
    @State private var confirmingTemplateId: UUID? = nil
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Background gradient
                WorkoutBackgroundView(confirmingTemplateId: $confirmingTemplateId)
                
                // Main content
                VStack(spacing: 0) {
                    // Header with title and dropdown
                    WorkoutHeaderView(
                        selectedBodyPart: $selectedBodyPart,
                        showDropdown: $showDropdown,
                        confirmingTemplateId: $confirmingTemplateId
                    )
                    
                    // Header with welcome text
                    WorkoutWelcomeView()
                    
                    // Templates Grid
                    WorkoutTemplatesGridView(
                        filteredTemplates: filteredTemplates,
                        animateCards: animateCards,
                        confirmingTemplateId: $confirmingTemplateId,
                        onSelectTemplate: { template in
                            selectedTemplate = template
                            showingTemplateDetail = true
                        },
                        onEditTemplate: { template in
                            templateToEdit = template
                            showingEditSheet = true
                        },
                        onDeleteTemplate: { template in
                            templateToDelete = template
                            showingDeleteAlert = true
                        },
                        onCreateTemplate: {
                            showingCreateTemplateSheet = true
                        }
                    )
                }
                
                // Dropdown overlay if showing
                if showDropdown {
                    BodyPartDropdown(
                        selectedBodyPart: $selectedBodyPart,
                        showDropdown: $showDropdown,
                        bodyParts: bodyParts
                    )
                }
            }
            .fullScreenCover(isPresented: $showingTemplateDetail) {
                if let template = selectedTemplate {
                    TemplateDetailView(template: template)
                        .environmentObject(dataManager)
                }
            }
            .alert("Delete Template", isPresented: $showingDeleteAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Delete", role: .destructive) {
                    if let template = templateToDelete {
                        dataManager.deleteTemplate(template)
                    }
                }
            } message: {
                Text("Are you sure you want to delete this template? This action cannot be undone.")
            }
            .sheet(isPresented: $showingEditSheet) {
                if let template = templateToEdit {
                    EnhancedTemplateCreationView(
                        existingTemplate: template,
                        onSave: { updatedTemplate in
                            dataManager.updateTemplate(updatedTemplate)
                        }
                    )
                    .environmentObject(dataManager)
                }
            }
            .sheet(isPresented: $showingCreateTemplateSheet) {
                EnhancedTemplateCreationView(
                    existingTemplate: nil,
                    onSave: { newTemplate in
                        dataManager.saveTemplate(newTemplate)
                    }
                )
                .environmentObject(dataManager)
            }
            .onAppear {
                // Animate cards when view appears
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    withAnimation {
                        animateCards = true
                    }
                }
            }
            .onDisappear {
                withAnimation(.easeOut(duration: 0.2)) {
                    confirmingTemplateId = nil
                }
            }
        }
    }
    
    // Filter templates based on selected body part
    var filteredTemplates: [WorkoutTemplate] {
        guard let selectedBodyPart = selectedBodyPart, selectedBodyPart != "All" else {
            return dataManager.templates
        }
        
        return dataManager.templates.filter { template in
            template.exercises.contains { exerciseTemplate in
                exerciseTemplate.exercise.muscleGroups.contains { muscleGroup in
                    muscleGroupToBodyPart(muscleGroup) == selectedBodyPart
                }
            }
        }
    }
    
    // Helper method to convert muscle group to body part for filtering
    private func muscleGroupToBodyPart(_ muscleGroup: String) -> String {
        let muscleGroup = muscleGroup.lowercased()
        if muscleGroup.contains("chest") {
            return "Chest"
        } else if muscleGroup.contains("back") {
            return "Back"
        } else if muscleGroup.contains("shoulder") || muscleGroup.contains("delt") {
            return "Shoulders"
        } else if muscleGroup.contains("bicep") || muscleGroup.contains("tricep") || muscleGroup.contains("arm") {
            return "Arms"
        } else if muscleGroup.contains("core") || muscleGroup.contains("ab") {
            return "Core"
        } else if muscleGroup.contains("leg") || muscleGroup.contains("quad") || muscleGroup.contains("hamstring") {
            return "Legs"
        }
        return "Other"
    }
}
