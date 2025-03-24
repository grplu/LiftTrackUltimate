import SwiftUI

struct WorkoutView: View {
    @EnvironmentObject var dataManager: DataManager
    @State private var selectedTemplate: WorkoutTemplate?
    @State private var isWorkoutActive = false
    @State private var showingDeleteAlert = false
    @State private var templateToDelete: WorkoutTemplate?
    @State private var showingEditSheet = false
    @State private var templateToEdit: WorkoutTemplate?
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background color
                Color.black.edgesIgnoringSafeArea(.all)
                
                VStack(spacing: 0) {
                    // Title
                    HStack {
                        Text("Workout")
                            .font(.system(size: 36, weight: .bold))
                            .foregroundColor(.white)
                            .padding(.horizontal)
                            .padding(.top, 16)
                        Spacer()
                    }
                    
                    // Templates List
                    ScrollView {
                        VStack(spacing: 16) {
                            ForEach(dataManager.templates) { template in
                                WorkoutTemplateCard(
                                    template: template,
                                    onSelect: {
                                        selectedTemplate = template
                                        isWorkoutActive = true
                                    },
                                    onEdit: {
                                        templateToEdit = template
                                        showingEditSheet = true
                                    },
                                    onDelete: {
                                        templateToDelete = template
                                        showingDeleteAlert = true
                                    }
                                )
                            }
                            
                            // Add a "Create New Template" card
                            Button(action: {
                                // Show create template sheet
                                templateToEdit = nil
                                showingEditSheet = true
                            }) {
                                HStack {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("Create New Template")
                                            .font(.headline)
                                            .foregroundColor(.white)
                                        
                                        Text("Customize your own workout")
                                            .font(.subheadline)
                                            .foregroundColor(.gray)
                                    }
                                    .padding()
                                    
                                    Spacer()
                                    
                                    Image(systemName: "plus.circle.fill")
                                        .font(.system(size: 24))
                                        .foregroundColor(.blue)
                                        .padding(.trailing, 16)
                                }
                                .frame(maxWidth: .infinity)
                                .background(
                                    RoundedRectangle(cornerRadius: 16)
                                        .fill(Color(.systemGray6).opacity(0.2))
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16)
                                        .stroke(Color.blue.opacity(0.3), lineWidth: 1)
                                )
                            }
                            .padding(.horizontal)
                            
                            // Add some padding at the bottom
                            Spacer().frame(height: 100)
                        }
                        .padding(.top, 16)
                    }
                    
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
            }
            .navigationBarHidden(true)
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
                } else {
                    // Create new template
                    EditTemplateView(template: WorkoutTemplate(name: "New Template", exercises: []))
                        .environmentObject(dataManager)
                }
            }
        }
    }
}

struct WorkoutTemplateCard: View {
    var template: WorkoutTemplate
    var onSelect: () -> Void
    var onEdit: () -> Void
    var onDelete: () -> Void
    
    var body: some View {
        Button(action: onSelect) {
            ZStack {
                // Card background with subtle gradient
                LinearGradient(
                    gradient: Gradient(colors: [Color.gray.opacity(0.2), Color.gray.opacity(0.15)]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .cornerRadius(16)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                )
                
                // Content
                HStack {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(template.name)
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(.white)
                        
                        HStack(spacing: 16) {
                            // Exercise count with icon
                            HStack {
                                Image(systemName: "dumbbell.fill")
                                    .foregroundColor(.green)
                                    .font(.system(size: 12))
                                Text("\(template.exercises.count) Exercises")
                                    .foregroundColor(.gray)
                            }
                            
                            // Duration with icon
                            HStack {
                                Image(systemName: "clock.fill")
                                    .foregroundColor(.orange)
                                    .font(.system(size: 12))
                                Text("\(estimatedDuration(for: template)) mins")
                                    .foregroundColor(.gray)
                            }
                        }
                        .font(.subheadline)
                    }
                    .padding()
                    
                    Spacer()
                    
                    // More options button
                    Menu {
                        Button(action: onEdit) {
                            HStack {
                                Image(systemName: "pencil")
                                Text("Edit")
                            }
                        }
                        
                        Button(action: onDelete) {
                            HStack {
                                Image(systemName: "trash")
                                Text("Delete")
                            }
                        }
                    } label: {
                        Image(systemName: "ellipsis")
                            .font(.system(size: 24))
                            .foregroundColor(.gray)
                            .frame(width: 44, height: 44)
                            .contentShape(Rectangle())
                    }
                    .padding(.trailing, 8)
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 100)
        }
        .buttonStyle(PlainButtonStyle())
        .padding(.horizontal)
    }
    
    // Helper method to estimate workout duration
    private func estimatedDuration(for template: WorkoutTemplate) -> Int {
        // Assuming ~10 minutes per exercise as a rough estimate
        return template.exercises.count * 10
    }
}
