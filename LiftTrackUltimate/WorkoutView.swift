import SwiftUI

struct WorkoutView: View {
    @EnvironmentObject var dataManager: DataManager
    @State private var selectedTemplate: WorkoutTemplate?
    @State private var isWorkoutActive = false
    @State private var showingDeleteAlert = false
    @State private var templateToDelete: WorkoutTemplate?
    @State private var showingEditSheet = false
    @State private var templateToEdit: WorkoutTemplate?
    @State private var showingCreateTemplateSheet = false
    @State private var selectedBodyPart: String? = nil
    @State private var showDropdown = false
    @State private var animateCards = false
    
    // Added bodyParts array
    private let bodyParts = ["All", "Chest", "Back", "Shoulders", "Arms", "Core", "Legs"]
    
    // Store the ID of the template being confirmed, if any
    @State private var confirmingTemplateId: UUID? = nil
    
    var body: some View {
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
                        isWorkoutActive = true
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
                
                // Navigation to ActiveWorkoutView when a template is selected
                NavigationLink(
                    destination: ActiveWorkoutView(
                        template: selectedTemplate,
                        onEnd: {
                            isWorkoutActive = false
                            selectedTemplate = nil
                        }
                    ),
                    isActive: $isWorkoutActive
                ) {
                    EmptyView()
                }
            }
            
            // Dropdown overlay
            if showDropdown {
                WorkoutDropdownView(
                    bodyParts: bodyParts,
                    selectedBodyPart: $selectedBodyPart,
                    showDropdown: $showDropdown,
                    confirmingTemplateId: $confirmingTemplateId,
                    bodyPartIcon: bodyPartIcon
                )
            }
        }
        .alert("Delete Template", isPresented: $showingDeleteAlert) {
            Button("Cancel", role: .cancel) {}
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
                EditTemplateView(template: template)
                    .environmentObject(dataManager)
            }
        }
        .sheet(isPresented: $showingCreateTemplateSheet) {
            EnhancedTemplateCreationView(onSave: { newTemplate in
                dataManager.saveTemplate(newTemplate)
            })
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
        let lowercased = muscleGroup.lowercased()
        
        if lowercased.contains("chest") { return "Chest" }
        if lowercased.contains("back") { return "Back" }
        if lowercased.contains("shoulder") || lowercased.contains("delt") { return "Shoulders" }
        if lowercased.contains("bicep") || lowercased.contains("tricep") || lowercased.contains("arm") { return "Arms" }
        if lowercased.contains("core") || lowercased.contains("abdominal") { return "Core" }
        if lowercased.contains("quad") || lowercased.contains("hamstring") || lowercased.contains("glute") ||
           lowercased.contains("calf") || lowercased.contains("leg") { return "Legs" }
        
        return "Other"
    }
    
    // Helper function to get icon for body part
    func bodyPartIcon(_ bodyPart: String) -> String {
        switch bodyPart {
        case "All": return "square.grid.2x2"
        case "Arms": return "figure.arms.open"
        case "Chest": return "heart.fill"
        case "Back": return "figure.strengthtraining.traditional"
        case "Shoulders": return "person.bust"
        case "Core": return "figure.core.training"
        case "Legs": return "figure.walk"
        default: return "figure.mixed.cardio"
        }
    }
}
