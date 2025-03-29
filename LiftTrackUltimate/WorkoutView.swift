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
    
    // Store the ID of the template being confirmed, if any
    @State private var confirmingTemplateId: UUID? = nil
    
    // Body parts for filter
    let bodyParts = ["All", "Arms", "Chest", "Back", "Shoulders", "Core", "Legs"]
    
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
    
    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                           gradient: Gradient(colors: [Color.black, Color(hex: "101010")]),
                           startPoint: .top,
                           endPoint: .bottom
                       )
            .edgesIgnoringSafeArea(.all)
            .contentShape(Rectangle()) // Make the entire background tappable
            .onTapGesture {
                // Dismiss any confirmations with smooth animation when tapping on background
                if confirmingTemplateId != nil {
                    withAnimation(.easeOut(duration: 0.2)) {
                        confirmingTemplateId = nil
                    }
                }
            }

            // OR if you specifically need a simultaneousGesture, use this syntax:

            .edgesIgnoringSafeArea(.all)
            .contentShape(Rectangle()) // Make the entire background tappable
            .simultaneousGesture(
                TapGesture()
                    .onEnded { _ in
                        // Dismiss any confirmations with smooth animation when tapping on background
                        if confirmingTemplateId != nil {
                            withAnimation(.easeOut(duration: 0.2)) {
                                confirmingTemplateId = nil
                            }
                        }
                    }
            )

            // Main content
            VStack(spacing: 0) {
                // Title and dropdown row
                HStack {
                    Text("Workout")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    // Dropdown menu button
                    Button(action: {
                        // Dismiss any confirmation when opening dropdown
                        if confirmingTemplateId != nil {
                            withAnimation(.spring(response: 0.4, dampingFraction: 0.75)) {
                                confirmingTemplateId = nil
                            }
                        }
                        
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
                }
                .padding(.horizontal)
                .padding(.top, 12)
                .padding(.bottom, 16)
                .zIndex(2)
                
                // Header with welcome text
                VStack(spacing: 4) {
                    Text("Pick a Workout to Start")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.white)
                    
                    Text("Select a template below to get started")
                        .font(.system(size: 14))
                        .foregroundColor(Color(.systemGray))
                }
                .padding(.top, 16)
                .padding(.bottom, 24)
                .frame(maxWidth: .infinity)
                .background(
                    Rectangle()
                        .fill(Color.clear)
                        .frame(height: 1)
                        .background(Color(hex: "3A3F42"))
                        .padding(.top, 68)
                )
                
                // Templates Grid
                ScrollView {
                    if filteredTemplates.isEmpty {
                        // Empty state if no templates match filter
                        emptyStateView
                    } else {
                        // Grid layout similar to Templates tab
                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                            ForEach(filteredTemplates) { template in
                                WorkoutTemplateCard(
                                    template: template,
                                    index: filteredTemplates.firstIndex(of: template) ?? 0,
                                    appear: animateCards,
                                    isConfirming: confirmingTemplateId == template.id,
                                    onCardTap: {
                                                                           // Toggle confirmation state for this card - add haptic feedback
                                                                           let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
                                                                           impactFeedback.prepare()
                                                                           impactFeedback.impactOccurred()
                                                                           
                                                                           // If a different card is showing confirmation, hide it first with quick animation
                                                                           if let currentId = confirmingTemplateId, currentId != template.id {
                                                                               withAnimation(.easeOut(duration: 0.15)) {
                                                                                   confirmingTemplateId = nil
                                                                               }
                                                                               
                                                                               // Then after a tiny delay, show the new confirmation
                                                                               DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                                                                                   withAnimation(.spring(response: 0.4, dampingFraction: 0.75)) {
                                                                                       confirmingTemplateId = template.id
                                                                                   }
                                                                               }
                                                                           } else {
                                                                               // Just toggle current card's confirmation
                                                                               withAnimation(.spring(response: 0.4, dampingFraction: 0.75)) {
                                                                                   confirmingTemplateId = confirmingTemplateId == template.id ? nil : template.id
                                                                               }
                                                                           }
                                                                       },                                    onDelete: {
                                        // Dismiss any confirmation when deleting
                                        confirmingTemplateId = nil
                                        templateToDelete = template
                                        showingDeleteAlert = true
                                    }
                                )
                            }
                            
                            // Create New Template card
                            CreateTemplateCard(
                                onTap: {
                                    confirmingTemplateId = nil
                                    showingCreateTemplateSheet = true
                                },
                                index: filteredTemplates.count,
                                appear: animateCards
                            )
                        }
                        .padding(.horizontal)
                        .padding(.bottom, 100)
                    }
                }
                .refreshable {
                    // Clear any confirmations and refresh
                    confirmingTemplateId = nil
                    
                    // Pull to refresh - reload templates
                    animateCards = false
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        withAnimation {
                            animateCards = true
                        }
                    }
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
            
            // Dropdown overlay
            if showDropdown {
                // Semi-transparent backdrop that doesn't interfere with card taps
                Color.black.opacity(0.4)
                    .edgesIgnoringSafeArea(.all)
                    .onTapGesture {
                        withAnimation(.easeIn(duration: 0.2)) {
                            showDropdown = false
                        }
                    }
                
                // Dropdown menu
                VStack(spacing: 0) {
                    // Dropdown panel
                    VStack(alignment: .leading, spacing: 0) {
                        ForEach(bodyParts, id: \.self) { bodyPart in
                            Button(action: {
                                withAnimation(.easeIn(duration: 0.2)) {
                                    selectedBodyPart = bodyPart == "All" ? nil : bodyPart
                                    showDropdown = false
                                    
                                    // Dismiss any confirmations with smooth animation
                                    if confirmingTemplateId != nil {
                                        withAnimation(.spring(response: 0.4, dampingFraction: 0.75)) {
                                            confirmingTemplateId = nil
                                        }
                                    }
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
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color(red: 0.2, green: 0.2, blue: 0.2), lineWidth: 1)
                    )
                    .padding(.horizontal, 16)
                    .padding(.top, 65) // Position just below the header
                
                    Spacer() // Push the dropdown to the top
                }
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
        .onAppear {
            // Animate cards when view appears
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                withAnimation {
                    animateCards = true
                }
            }
        }
        // Dismiss confirmation when changing tabs or leaving the view
        .onDisappear {
            withAnimation(.easeOut(duration: 0.2)) {
                confirmingTemplateId = nil
            }
        }
    }
    
    // MARK: - Empty Templates View
    private var emptyStateView: some View {
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
            
            Button(action: {
                showingCreateTemplateSheet = true
            }) {
                HStack {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 16))
                    
                    Text("Create Template")
                        .font(.headline)
                }
                .foregroundColor(.white)
                .padding(.horizontal, 24)
                .padding(.vertical, 14)
                .background(
                    RoundedRectangle(cornerRadius: 14)
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [Color.blue, Color.blue.opacity(0.8)]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                )
                .shadow(color: Color.blue.opacity(0.4), radius: 8, x: 0, y: 4)
            }
            .padding(.top, 24)
        }
        .frame(maxWidth: .infinity)
        .padding(20)
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

// New grid-based workout template card with embedded confirmation
struct WorkoutTemplateCard: View {
    var template: WorkoutTemplate
    var index: Int
    var appear: Bool
    var isConfirming: Bool
    var onCardTap: () -> Void
    var onStartTap: () -> Void
    var onEdit: () -> Void
    var onDelete: () -> Void
    @State private var isPressed = false
    @State private var isStartPressed = false
    
    var body: some View {
        Button(action: {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                isPressed = true
            }
            
            // Brief delay to show the press effect
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation {
                    isPressed = false
                }
                
                // Toggle confirmation with smooth animation
                withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                    onCardTap()
                }
            }
        }) {
            ZStack(alignment: .center) {
                // Card content
                VStack(alignment: .leading, spacing: 12) {
                    // Top row with icon and menu
                    HStack(alignment: .center) {
                        // Icon for primary muscle group
                        ZStack {
                            Circle()
                                .fill(accentColor.opacity(0.2))
                                .frame(width: 40, height: 40)
                            
                            Image(systemName: primaryMuscleIcon)
                                .font(.system(size: 18))
                                .foregroundColor(accentColor)
                        }
                        .padding(.top, 2)
                        
                        Spacer()
                        
                        // More options menu
                        Menu {
                            Button(action: onEdit) {
                                Label("Edit", systemImage: "pencil")
                            }
                            
                            Button(role: .destructive, action: onDelete) {
                                Label("Delete", systemImage: "trash")
                            }
                        } label: {
                            Image(systemName: "ellipsis")
                                .font(.system(size: 16))
                                .foregroundColor(.gray)
                                .padding(8)
                                .contentShape(Circle())
                        }
                    }
                    .padding(.bottom, 2)
                    
                    Spacer()
                    
                    // Template name - dynamic sizing
                    Text(template.name)
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.white)
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    // Stats row - properly aligned
                    HStack(alignment: .center) {
                        // Exercise icon and count
                        HStack(spacing: 6) {
                            Image(systemName: "dumbbell.fill")
                                .font(.system(size: 12))
                                .foregroundColor(.green)
                            
                            Text("\(template.exercises.count) exercises")
                                .font(.system(size: 14))
                                .foregroundColor(.gray)
                        }
                        
                        Spacer()
                        
                        // Chevron positioned correctly
                        Image(systemName: "chevron.right")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.gray)
                            .offset(y: -1)
                    }
                    .padding(.bottom, 4)
                    
                    // Duration with icon - properly aligned
                    HStack(spacing: 6) {
                        Image(systemName: "clock.fill")
                            .font(.system(size: 12))
                            .foregroundColor(.orange)
                        
                        Text("\(durationInMinutes) mins")
                            .font(.system(size: 14))
                            .foregroundColor(.gray)
                            
                        Spacer()
                    }
                }
                .padding(16)
                
                // Confirmation overlay when confirming
                if isConfirming {
                    // Position the confirmation dialog to be centered over this card
                    GeometryReader { geometry in
                        ZStack {
                            // Semi-transparent backdrop
                            Color.black.opacity(0.85)
                                .cornerRadius(16)
                                .frame(width: 170, height: 220) // Smaller size
                                .shadow(color: Color.black.opacity(0.5), radius: 10, x: 0, y: 0)
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    // Do nothing when tapping on the confirmation overlay itself
                                }
                            
                            // Confirmation content - adjusted for better fit
                            VStack(spacing: 8) { // Reduced spacing
                                // Template name with start text
                                Text("Start \(template.name)")
                                    .font(.system(size: 16, weight: .bold)) // Smaller font
                                    .foregroundColor(.white)
                                    .multilineTextAlignment(.center)
                                    .lineLimit(2)
                                    .minimumScaleFactor(0.7)
                                    .fixedSize(horizontal: false, vertical: true)
                                    .padding(.top, 12)
                                    .padding(.horizontal, 10)
                                    .contentShape(Rectangle())
                                    .onTapGesture {
                                        // Do nothing - prevent tap from propagating
                                    }
                                
                                // Stats in row with adjusted spacing - FIXED TEXT CUTOFF
                                HStack(spacing: 36) { // Reduced spacing
                                    // Exercise count with better alignment
                                    VStack(spacing: 4) {
                                        Text("\(template.exercises.count)")
                                            .font(.system(size: 22, weight: .bold)) // Smaller font to fit text
                                            .foregroundColor(.white)
                                        
                                        Text("Exer...")
                                            .font(.system(size: 11))
                                            .foregroundColor(.gray)
                                            .fixedSize(horizontal: true, vertical: false) // Prevent truncation
                                    }
                                    
                                    // Duration with better alignment
                                    VStack(spacing: 4) {
                                        Text("\(durationInMinutes)")
                                            .font(.system(size: 22, weight: .bold)) // Smaller font to fit text
                                            .foregroundColor(.white)
                                        
                                        Text("Mins")
                                            .font(.system(size: 11))
                                            .foregroundColor(.gray)
                                            .fixedSize(horizontal: true, vertical: false) // Prevent truncation
                                    }
                                }
                                .padding(.vertical, 8) // Reduced padding
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    // Do nothing - prevent tap from propagating
                                }
                                
                                // Start button - smaller size with animation
                                Button(action: {
                                    // Visual feedback animation
                                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                        isStartPressed = true
                                    }
                                    
                                    // Brief delay to show animation
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                                        withAnimation {
                                            isStartPressed = false
                                        }
                                        onStartTap()
                                    }
                                }) {
                                    Text("Start")
                                        .font(.system(size: 20, weight: .bold)) // Smaller font
                                        .foregroundColor(.white)
                                        .frame(width: 76, height: 76) // Smaller button
                                        .background(
                                            Circle()
                                                .fill(Color.green)
                                        )
                                }
                                .scaleEffect(isStartPressed ? 0.9 : 1.0)
                                .padding(.top, 4) // Reduced padding
                                .padding(.bottom, 12) // Reduced padding
                            }
                            .frame(width: 170, height: 220) // Match the backdrop size
                            .contentShape(Rectangle())
                            .onTapGesture {
                                // Do nothing when tapping on the VStack content
                            }
                        }
                        .position(x: geometry.size.width/2, y: geometry.size.height/2)
                        .transition(
                            .asymmetric(
                                insertion: .scale(scale: 0.9).combined(with: .opacity)
                                    .animation(.spring(response: 0.4, dampingFraction: 0.7)),
                                removal: .scale(scale: 0.9).combined(with: .opacity)
                                    .animation(.easeOut(duration: 0.25))
                            )
                        )
                    }
                }
            }
            .frame(height: 160)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(.systemGray6).opacity(0.15))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(isPressed ? Color.blue : accentColor.opacity(0.2), lineWidth: isPressed ? 2 : 1)
                    )
            )
            .shadow(color: Color.black.opacity(0.2), radius: 5, x: 0, y: 2)
        }
        .buttonStyle(PlainButtonStyle())
        .scaleEffect(isPressed ? 0.95 : 1.0)
        .opacity(appear ? 1 : 0)
        .offset(y: appear ? 0 : 20)
        .zIndex(isConfirming ? 10 : 0) // Increase z-index when confirming
        .animation(
            .spring(response: 0.5, dampingFraction: 0.8)
            .delay(0.1 + Double(index) * 0.05),
            value: appear
        )
    }
    
    // Duration calculation directly in the card view
    private var durationInMinutes: Int {
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

// Create New Template card
struct CreateTemplateCard: View {
    var onTap: () -> Void
    var index: Int
    var appear: Bool
    @State private var isPulsing = false
    
    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 14) {
                // Pulsing plus icon
                ZStack {
                    Circle()
                        .fill(Color.blue.opacity(0.2))
                        .frame(width: 40, height: 40)
                        
                    Circle()
                        .stroke(Color.blue.opacity(0.5), lineWidth: 2)
                        .frame(width: 40, height: 40)
                        .scaleEffect(isPulsing ? 1.3 : 1.0)
                        .opacity(isPulsing ? 0.0 : 0.8)
                        .animation(
                            Animation.easeInOut(duration: 1.2)
                                .repeatForever(autoreverses: false),
                            value: isPulsing
                        )
                    
                    Image(systemName: "plus")
                        
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.blue)
                }
                
                Spacer()
                
                // Text content
                Text("Create New Template")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                
                Text("Customize your own workout routine")
                    .font(.system(size: 14))
                    .foregroundColor(.gray)
                    .lineLimit(2)
            }
            .padding(16)
            .frame(height: 160)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.blue.opacity(0.1))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.blue.opacity(0.3), lineWidth: 1)
                    )
            )
            .opacity(appear ? 1 : 0)
            .offset(y: appear ? 0 : 20)
            .animation(
                .spring(response: 0.5, dampingFraction: 0.8)
                .delay(0.1 + Double(index) * 0.05),
                value: appear
            )
        }
        .buttonStyle(PlainButtonStyle())
        .onAppear {
            // Start pulsing animation when view appears
            isPulsing = true
        }
    }
}

// Color hex extension is defined elsewhere in the project
// Removed duplicate declaration to fix "Invalid redeclaration of 'init(hex:)'" error
