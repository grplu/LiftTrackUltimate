import SwiftUI

// Custom view for the pulsing plus button animation - UPDATED to be thumb-sized
struct PulsingPlusButton: View {
    @State private var isPulsing = false
    
    var body: some View {
        ZStack {
            // Static background circle - increased to thumb size
            Circle()
                .fill(Color.blue.opacity(0.3))
                .frame(width: 64, height: 64) // Increased from 40 to 64
            
            // Pulsing circle - increased proportionally
            Circle()
                .stroke(Color.blue.opacity(0.5), lineWidth: 2)
                .frame(width: 64, height: 64) // Increased from 40 to 64
                .scaleEffect(isPulsing ? 1.5 : 1.0)
                .opacity(isPulsing ? 0.0 : 0.5)
                .animation(
                    Animation.easeInOut(duration: 1.2)
                        .repeatForever(autoreverses: false),
                    value: isPulsing
                )
            
            // Plus icon - significantly larger
            Image(systemName: "plus")
                .font(.system(size: 32, weight: .bold)) // Increased from 20 to 32
                .foregroundColor(.blue)
        }
        .onAppear {
            // Start the animation when the view appears
            isPulsing = true
        }
    }
}

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
    
    // Body parts for filter
    let bodyParts = ["All", "Arms", "Chest", "Back", "Shoulders", "Core", "Legs"]
    
    // Filter templates based on selected body part
    var filteredTemplates: [WorkoutTemplate] {
        guard let selectedBodyPart = selectedBodyPart, selectedBodyPart != "All" else {
            return dataManager.templates
        }
        
        return dataManager.templates.filter { template in
            template.exercises.contains { exercise in
                exercise.exercise.muscleGroups.contains { muscleGroup in
                    muscleGroupToBodyPart(muscleGroup) == selectedBodyPart
                }
            }
        }
    }
    
    var body: some View {
        ZStack {
            // Main content
            VStack(spacing: 0) {
                // Title and dropdown row
                HStack {
                    Text("Workout")
                        .font(.system(size: 36, weight: .bold))
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    // Dropdown menu button
                    Button(action: {
                        // Use simple animation to reduce graphics load
                        withAnimation(.easeOut(duration: 0.2)) {
                            showDropdown.toggle()
                        }
                    }) {
                        HStack(spacing: 6) {
                            Text(selectedBodyPart ?? "All")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.white)
                            
                            Image(systemName: "chevron.down")
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundColor(.gray)
                                .rotationEffect(Angle(degrees: showDropdown ? 180 : 0))
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(
                            Capsule()
                                .fill(Color(red: 0.15, green: 0.15, blue: 0.15))
                        )
                    }
                    .padding(.trailing)
                }
                .padding(.horizontal)
                .padding(.top, 16)
                .zIndex(2)
                
                // Templates List
                ScrollView {
                    VStack(spacing: 16) {
                        // Using filteredTemplates instead of dataManager.templates
                        ForEach(filteredTemplates) { template in
                            EnhancedWorkoutTemplateCard(
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
                        
                        // Empty state if no templates match filter
                        if filteredTemplates.isEmpty {
                            VStack(spacing: 16) {
                                Image(systemName: "square.dashed")
                                    .font(.system(size: 40))
                                    .foregroundColor(.gray)
                                    .padding(.top, 40)
                                
                                Text(selectedBodyPart == nil || selectedBodyPart == "All" ? "No workout templates found" : "No templates for \(selectedBodyPart!)")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                
                                Text("Create a new template or select a different body part")
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                                    .multilineTextAlignment(.center)
                                
                                Button(action: {
                                    selectedBodyPart = "All"
                                }) {
                                    Text("Show All Templates")
                                        .foregroundColor(.blue)
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 8)
                                        .background(
                                            Capsule()
                                                .stroke(Color.blue, lineWidth: 1)
                                        )
                                }
                                .padding(.top, 8)
                                .opacity(selectedBodyPart == "All" || selectedBodyPart == nil ? 0 : 1)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(20)
                        }
                        
                        // Enhanced Create New Template button with pulsing animation - NOW WITH LARGER BUTTON
                        Button(action: {
                            showingCreateTemplateSheet = true
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
                                
                                // Animated plus icon with pulsing effect - NOW LARGER
                                PulsingPlusButton()
                                    .padding(.trailing, 16)
                            }
                            .frame(maxWidth: .infinity)
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(
                                        LinearGradient(
                                            gradient: Gradient(colors: [Color.blue.opacity(0.3), Color.blue.opacity(0.1)]),
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(Color.blue.opacity(0.3), lineWidth: 1)
                            )
                        }
                        .padding(.horizontal)
                        .shadow(color: Color.blue.opacity(0.2), radius: 5, x: 0, y: 2)
                        
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
            .withAppBackground() // Apply the background modifier here
            
            // OPTIMIZED: Overlay for dropdown
            if showDropdown {
                // Simplified backdrop - no animation here
                Color.black.opacity(0.4)
                    .edgesIgnoringSafeArea(.all)
                    .onTapGesture {
                        withAnimation(.easeIn(duration: 0.2)) {
                            showDropdown = false
                        }
                    }
            }
            
            // OPTIMIZED: Dropdown menu with simplified rendering
            if showDropdown {
                VStack(spacing: 0) {
                    // Much simpler dropdown panel
                    VStack(alignment: .leading, spacing: 0) {
                        ForEach(bodyParts, id: \.self) { bodyPart in
                            Button(action: {
                                withAnimation(.easeIn(duration: 0.2)) {
                                    selectedBodyPart = bodyPart == "All" ? nil : bodyPart
                                    showDropdown = false
                                }
                            }) {
                                HStack {
                                    Image(systemName: bodyPartIcon(bodyPart))
                                        .foregroundColor(bodyPart == selectedBodyPart || (bodyPart == "All" && selectedBodyPart == nil) ? .white : .gray)
                                        .frame(width: 30)
                                    
                                    Text(bodyPart)
                                        .font(.system(size: 16))
                                        .fontWeight(bodyPart == selectedBodyPart || (bodyPart == "All" && selectedBodyPart == nil) ? .semibold : .regular)
                                        .foregroundColor(.white)
                                    
                                    Spacer()
                                    
                                    if bodyPart == selectedBodyPart || (bodyPart == "All" && selectedBodyPart == nil) {
                                        Image(systemName: "checkmark")
                                            .foregroundColor(.blue)
                                            .font(.system(size: 14))
                                    }
                                }
                                .padding(.horizontal, 16)
                                .padding(.vertical, 12)
                                .background(
                                    (bodyPart == selectedBodyPart || (bodyPart == "All" && selectedBodyPart == nil)) ?
                                        Color(red: 0.15, green: 0.15, blue: 0.25) :
                                        Color.clear
                                )
                            }
                            
                            if bodyPart != bodyParts.last {
                                Divider()
                                    .background(Color.gray.opacity(0.2))
                                    .padding(.horizontal, 0)
                            }
                        }
                    }
                    .background(Color(red: 0.1, green: 0.1, blue: 0.1))
                    .cornerRadius(16)
                    // Simplified border
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color(red: 0.2, green: 0.2, blue: 0.2), lineWidth: 1)
                    )
                    .padding(.horizontal, 16)
                    .padding(.top, 65) // Position just below the header
                
                    Spacer() // Push the dropdown to the top
                }
                // Simplified animation and transition
                .transition(.opacity)
                .animation(.easeOut(duration: 0.2), value: showDropdown)
                .zIndex(10)
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
    }
    
    // Helper function to map muscle groups to body parts
    func muscleGroupToBodyPart(_ muscleGroup: String) -> String {
        let lowercased = muscleGroup.lowercased()
        if lowercased.contains("chest") { return "Chest" }
        if lowercased.contains("back") { return "Back" }
        if lowercased.contains("shoulder") || lowercased.contains("delt") { return "Shoulders" }
        if lowercased.contains("bicep") || lowercased.contains("tricep") || lowercased.contains("arm") { return "Arms" }
        if lowercased.contains("core") || lowercased.contains("abdominal") { return "Core" }
        if lowercased.contains("quad") || lowercased.contains("hamstring") || lowercased.contains("glute") || lowercased.contains("calf") || lowercased.contains("leg") { return "Legs" }
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

// Enhanced workout template card with color coding and icons
struct EnhancedWorkoutTemplateCard: View {
    var template: WorkoutTemplate
    var onSelect: () -> Void
    var onEdit: () -> Void
    var onDelete: () -> Void
    
    var body: some View {
        Button(action: onSelect) {
            ZStack {
                // Card background with color accent based on primary muscle group
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(.systemGray6).opacity(0.2))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(accentColor.opacity(0.3), lineWidth: 2)
                    )
                
                // Content
                HStack {
                    // Icon for primary muscle group
                    ZStack {
                        Circle()
                            .fill(accentColor.opacity(0.2))
                            .frame(width: 50, height: 50)
                        
                        Image(systemName: primaryMuscleIcon)
                            .font(.system(size: 22))
                            .foregroundColor(accentColor)
                    }
                    .padding(.leading, 12)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        // Dynamic text sizing with bolder font
                        Text(template.name)
                            .font(.system(size: 20, weight: .black))
                            .foregroundColor(.white)
                            .lineLimit(1)
                            .minimumScaleFactor(0.6)
                            .fixedSize(horizontal: false, vertical: true)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
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
                    
                    // Right chevron indicator
                    Image(systemName: "chevron.right")
                        .foregroundColor(.gray)
                        .font(.system(size: 14))
                        .padding(.trailing, 8)
                    
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
    
    // Determine the primary muscle group and corresponding color
    private var primaryMuscleGroup: String {
        // Count occurrences of each muscle group
        var muscleGroupCounts: [String: Int] = [:]
        
        for exerciseTemplate in template.exercises {
            for muscleGroup in exerciseTemplate.exercise.muscleGroups {
                muscleGroupCounts[muscleGroup, default: 0] += 1
            }
        }
        
        // Return the most common muscle group, or "Mixed" if none
        return muscleGroupCounts.max(by: { $0.value < $1.value })?.key ?? "Mixed"
    }
    
    // Get icon for primary muscle group
    private var primaryMuscleIcon: String {
        let mainMuscle = primaryMuscleGroup.lowercased()
        
        if mainMuscle.contains("chest") {
            return "heart.fill"
        } else if mainMuscle.contains("back") {
            return "figure.strengthtraining.traditional"
        } else if mainMuscle.contains("shoulder") || mainMuscle.contains("delt") {
            return "person.bust"
        } else if mainMuscle.contains("bicep") || mainMuscle.contains("tricep") || mainMuscle.contains("arm") {
            return "figure.arms.open"
        } else if mainMuscle.contains("core") || mainMuscle.contains("ab") {
            return "figure.core.training"
        } else if mainMuscle.contains("leg") || mainMuscle.contains("quad") || mainMuscle.contains("hamstring") {
            return "figure.walk"
        } else {
            return "figure.mixed.cardio"
        }
    }
    
    // Get accent color based on primary muscle group
    private var accentColor: Color {
        let mainMuscle = primaryMuscleGroup.lowercased()
        
        if mainMuscle.contains("chest") {
            return .red
        } else if mainMuscle.contains("back") {
            return .blue
        } else if mainMuscle.contains("shoulder") || mainMuscle.contains("delt") {
            return .purple
        } else if mainMuscle.contains("bicep") || mainMuscle.contains("tricep") || mainMuscle.contains("arm") {
            return .green
        } else if mainMuscle.contains("core") || mainMuscle.contains("ab") {
            return .yellow
        } else if mainMuscle.contains("leg") || mainMuscle.contains("quad") || mainMuscle.contains("hamstring") {
            return .orange
        } else {
            return .blue
        }
    }
}
