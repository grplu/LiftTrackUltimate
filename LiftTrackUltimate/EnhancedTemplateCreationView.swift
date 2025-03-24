import SwiftUI

struct EnhancedTemplateCreationView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var dataManager: DataManager
    var onSave: (WorkoutTemplate) -> Void
    
    @State private var templateName = ""
    @State private var templateDescription = ""
    @State private var selectedCategory = "Strength"
    @State private var isPublic = false
    @State private var selectedExercises: [TemplateExercise] = []
    @State private var currentStep = 0
    @State private var showingExerciseSelection = false
    
    let categories = ["Strength", "Hypertrophy", "HIIT", "Cardio", "Calisthenics", "Full Body", "Upper Body", "Lower Body"]
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background color
                Color.black.edgesIgnoringSafeArea(.all)
                
                VStack(spacing: 0) {
                    // Progress steps
                    ProgressSteps(currentStep: currentStep)
                        .padding(.top, 20)
                        .padding(.bottom, 24)
                    
                    // Content area
                    ScrollView {
                        VStack(spacing: 30) {
                            // Step 1: Basic Info
                            if currentStep == 0 {
                                basicInfoSection
                            }
                            
                            // Step 2: Add Exercises
                            else if currentStep == 1 {
                                exercisesSection
                            }
                            
                            // Step 3: Review & Save
                            else if currentStep == 2 {
                                reviewSection
                            }
                        }
                        .padding(.horizontal)
                    }
                    
                    // Navigation buttons
                    navigationButtons
                        .padding()
                }
            }
            .navigationBarTitle("", displayMode: .inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "xmark")
                            .foregroundColor(.white)
                    }
                }
                
                ToolbarItem(placement: .principal) {
                    Text(stepTitle)
                        .font(.headline)
                        .foregroundColor(.white)
                }
            }
            .sheet(isPresented: $showingExerciseSelection) {
                ExerciseSelectionView { exercise in
                    // Create template exercise with default sets/reps
                    addExerciseToTemplate(exercise)
                }
                .environmentObject(dataManager)
            }
        }
    }
    
    // MARK: - Sections
    
    // Step 1: Basic Info
    private var basicInfoSection: some View {
        VStack(spacing: 24) {
            // Template icon
            ZStack {
                Circle()
                    .fill(LinearGradient(
                        gradient: Gradient(colors: [Color.blue.opacity(0.7), Color.blue.opacity(0.5)]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ))
                    .frame(width: 90, height: 90)
                
                Image(systemName: "rectangle.stack.fill")
                    .font(.system(size: 40))
                    .foregroundColor(.white)
            }
            .padding(.bottom, 16)
            
            // Name field
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
            
            // Description field
            VStack(alignment: .leading, spacing: 8) {
                Text("Description (Optional)")
                    .font(.headline)
                    .foregroundColor(.white)
                
                ZStack(alignment: .topLeading) {
                    if templateDescription.isEmpty {
                        Text("Describe your workout template...")
                            .foregroundColor(.gray)
                            .padding(10)
                    }
                    TextEditor(text: $templateDescription)
                        .foregroundColor(.white)
                }
                .frame(height: 100)
                .padding(10)
                .background(Color(.systemGray6).opacity(0.2))
                .cornerRadius(10)
            }
            
            // Category picker
            VStack(alignment: .leading, spacing: 8) {
                Text("Category")
                    .font(.headline)
                    .foregroundColor(.white)
                
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10) {
                        ForEach(categories, id: \.self) { category in
                            Button(action: {
                                selectedCategory = category
                            }) {
                                Text(category)
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 10)
                                    .background(selectedCategory == category ? Color.blue : Color(.systemGray6).opacity(0.2))
                                    .foregroundColor(.white)
                                    .cornerRadius(20)
                            }
                        }
                    }
                }
            }
            
            // Visibility toggle
            Toggle(isOn: $isPublic) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Share to Template Store")
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    Text("Allow other users to discover and use your template")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }
            .toggleStyle(SwitchToggleStyle(tint: .blue))
            .padding(.vertical, 8)
        }
    }
    
    // Step 2: Add Exercises
    private var exercisesSection: some View {
        VStack(spacing: 20) {
            // Header with exercise count
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Add Exercises")
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Text("\(selectedExercises.count) exercises added")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
                Button(action: {
                    showingExerciseSelection = true
                }) {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 22))
                        .foregroundColor(.blue)
                }
            }
            
            if selectedExercises.isEmpty {
                // Empty state
                VStack(spacing: 16) {
                    Image(systemName: "dumbbell.fill")
                        .font(.system(size: 40))
                        .foregroundColor(.gray)
                        .padding(.top, 30)
                    
                    Text("No exercises yet")
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    Text("Tap the + button to add exercises to your template")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                    
                    Button(action: {
                        showingExerciseSelection = true
                    }) {
                        Text("Add Exercise")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 12)
                            .background(Color.blue)
                            .cornerRadius(10)
                    }
                    .padding(.top, 10)
                }
                .padding(.vertical, 40)
                .frame(maxWidth: .infinity)
            } else {
                // Exercise list
                VStack(spacing: 16) {
                    ForEach(Array(selectedExercises.enumerated()), id: \.1.id) { index, exercise in
                        ExerciseRow(
                            exercise: exercise,
                            index: index,
                            onRemove: {
                                selectedExercises.remove(at: index)
                            },
                            onEditSets: { sets in
                                selectedExercises[index].targetSets = sets
                            },
                            onEditReps: { reps in
                                selectedExercises[index].targetReps = reps
                            }
                        )
                    }
                }
                
                // Add more button
                Button(action: {
                    showingExerciseSelection = true
                }) {
                    HStack {
                        Image(systemName: "plus")
                        Text("Add Exercise")
                    }
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue.opacity(0.2))
                    .cornerRadius(10)
                }
                .padding(.top, 20)
            }
        }
    }
    
    // Step 3: Review & Save
    private var reviewSection: some View {
        VStack(spacing: 24) {
            // Template preview card
            VStack(spacing: 16) {
                // Header
                HStack {
                    VStack(alignment: .leading, spacing: 6) {
                        Text(templateName.isEmpty ? "Untitled Template" : templateName)
                            .font(.title3)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                        
                        HStack(spacing: 8) {
                            Text(selectedCategory)
                                .font(.caption)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 4)
                                .background(Color.blue.opacity(0.2))
                                .foregroundColor(.blue)
                                .cornerRadius(10)
                            
                            Text("\(selectedExercises.count) exercises")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                    }
                    
                    Spacer()
                    
                    // Visibility badge
                    HStack {
                        Image(systemName: isPublic ? "globe" : "lock.fill")
                            .font(.system(size: 12))
                        Text(isPublic ? "Public" : "Private")
                            .font(.caption)
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(isPublic ? Color.green.opacity(0.2) : Color.gray.opacity(0.2))
                    .foregroundColor(isPublic ? .green : .gray)
                    .cornerRadius(8)
                }
                
                // Description
                if !templateDescription.isEmpty {
                    Text(templateDescription)
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.vertical, 10)
                }
                
                Divider()
                    .background(Color.gray.opacity(0.3))
                    .padding(.vertical, 8)
                
                // Exercise summary
                VStack(spacing: 16) {
                    ForEach(Array(selectedExercises.enumerated()), id: \.1.id) { index, exercise in
                        HStack {
                            Text("\(index + 1).")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                                .frame(width: 30, alignment: .leading)
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text(exercise.exercise.name)
                                    .font(.headline)
                                    .foregroundColor(.white)
                                
                                // Safely unwrap optional target reps value
                                let repsText = exercise.targetReps != nil ? "\(exercise.targetReps!)" : "0"
                                Text("\(exercise.targetSets) sets × \(repsText) reps")
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                            }
                            
                            Spacer()
                        }
                        .padding(.vertical, 4)
                    }
                }
            }
            .padding(20)
            .background(Color(.systemGray6).opacity(0.2))
            .cornerRadius(16)
        }
    }
    
    // MARK: - Navigation Buttons
    
    private var navigationButtons: some View {
        HStack(spacing: 16) {
            // Back button (except on first step)
            if currentStep > 0 {
                Button(action: {
                    currentStep -= 1
                }) {
                    HStack {
                        Image(systemName: "chevron.left")
                        Text("Back")
                    }
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(10)
                }
            }
            
            // Continue/Save button
            Button(action: {
                if currentStep < 2 {
                    currentStep += 1
                } else {
                    saveTemplate()
                }
            }) {
                HStack {
                    Text(currentStep == 2 ? "Save Template" : "Continue")
                    
                    if currentStep < 2 {
                        Image(systemName: "chevron.right")
                    } else {
                        Image(systemName: "checkmark")
                    }
                }
                .font(.headline)
                .foregroundColor(.white)
                .padding()
                .frame(maxWidth: .infinity)
                .background(buttonBackgroundColor)
                .cornerRadius(10)
            }
            .disabled(!canAdvance)
            .opacity(canAdvance ? 1.0 : 0.5)
        }
    }
    
    // MARK: - Progress Steps
    
    private var stepTitle: String {
        switch currentStep {
        case 0: return "Template Details"
        case 1: return "Add Exercises"
        case 2: return "Review & Save"
        default: return ""
        }
    }
    
    private var buttonBackgroundColor: Color {
        if !canAdvance {
            return Color.gray
        }
        return currentStep == 2 ? Color.green : Color.blue
    }
    
    private var canAdvance: Bool {
        switch currentStep {
        case 0: return !templateName.isEmpty
        case 1: return !selectedExercises.isEmpty
        case 2: return true
        default: return false
        }
    }
    
    // MARK: - Helper Functions
    
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
    
    private func saveTemplate() {
        // Create new template
        let newTemplate = WorkoutTemplate(
            id: UUID(),
            name: templateName,
            exercises: selectedExercises
        )
        
        // Save using callback
        onSave(newTemplate)
        
        // Dismiss the view
        dismiss()
    }
}

// MARK: - Helper Views

struct ProgressSteps: View {
    var currentStep: Int
    
    var body: some View {
        HStack {
            ForEach(0..<3) { step in
                Capsule()
                    .fill(step <= currentStep ? Color.blue : Color.gray.opacity(0.3))
                    .frame(height: 4)
                    .frame(maxWidth: .infinity)
            }
        }
        .padding(.horizontal)
    }
}

struct ExerciseRow: View {
    var exercise: TemplateExercise
    var index: Int
    var onRemove: () -> Void
    var onEditSets: (Int) -> Void
    var onEditReps: (Int) -> Void
    
    @State private var isExpanded = false
    @State private var isNewlyAdded = true
    @State private var animateGlow = false
    
    var body: some View {
        VStack(spacing: 0) {
            // Exercise header
            Button(action: {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                    isExpanded.toggle()
                }
            }) {
                HStack(spacing: 16) {
                    // Exercise number indicator with circle background
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    gradient: Gradient(colors: [
                                        Color.blue.opacity(0.7),
                                        Color.blue.opacity(0.5)
                                    ]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 36, height: 36)
                        
                        Text("\(index + 1)")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.white)
                    }
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(exercise.exercise.name)
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                        
                        // Handle optional safely
                        let repsText = exercise.targetReps != nil ? "\(exercise.targetReps!)" : "0"
                        HStack(spacing: 12) {
                            HStack(spacing: 4) {
                                Image(systemName: "chart.bar.fill")
                                    .font(.system(size: 12))
                                    .foregroundColor(.blue.opacity(0.8))
                                
                                Text("\(exercise.targetSets) sets")
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                            }
                            
                            HStack(spacing: 4) {
                                Image(systemName: "repeat")
                                    .font(.system(size: 12))
                                    .foregroundColor(.green.opacity(0.8))
                                
                                Text("\(repsText) reps")
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                            }
                        }
                    }
                    
                    Spacer()
                    
                    // Expand/Collapse button
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.gray)
                        .frame(width: 28, height: 28)
                        .background(Color.gray.opacity(0.2))
                        .clipShape(Circle())
                    
                    // Remove button
                    Button(action: {
                        withAnimation(.spring()) {
                            onRemove()
                        }
                    }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.white)
                            .frame(width: 28, height: 28)
                            .background(Color.red.opacity(0.7))
                            .clipShape(Circle())
                    }
                }
                .padding(.vertical, 16)
                .padding(.horizontal, 16)
            }
            .buttonStyle(PlainButtonStyle())
            
            // Expanded content (sets & reps)
            if isExpanded {
                VStack(spacing: 24) {
                    Divider()
                        .background(Color.gray.opacity(0.3))
                        .padding(.horizontal)
                    
                    // Sets selector
                    HStack {
                        HStack(spacing: 10) {
                            Image(systemName: "chart.bar.fill")
                                .font(.system(size: 16))
                                .foregroundColor(.blue)
                            
                            Text("Sets")
                                .font(.headline)
                                .foregroundColor(.white)
                        }
                        
                        Spacer()
                        
                        // Modern number stepper
                        ModernNumberStepper(
                            value: exercise.targetSets,
                            range: 1...10,
                            onChanged: onEditSets,
                            accentColor: .blue
                        )
                    }
                    .padding(.horizontal, 20)
                    
                    // Reps selector - safely handle optional
                    HStack {
                        HStack(spacing: 10) {
                            Image(systemName: "repeat")
                                .font(.system(size: 16))
                                .foregroundColor(.green)
                            
                            Text("Reps")
                                .font(.headline)
                                .foregroundColor(.white)
                        }
                        
                        Spacer()
                        
                        // Modern number stepper with safe unwrapping
                        ModernNumberStepper(
                            value: exercise.targetReps ?? 0, // Default to 0 if nil
                            range: 1...50,
                            onChanged: onEditReps,
                            accentColor: .green
                        )
                    }
                    .padding(.horizontal, 20)
                    
                    Divider()
                        .background(Color.gray.opacity(0.3))
                        .padding(.horizontal)
                    
                    // Optional instructions button
                    Button(action: {
                        // Show instructions in a separate sheet or popup
                    }) {
                        HStack {
                            Image(systemName: "info.circle")
                                .font(.system(size: 14))
                            
                            Text("View Exercise Instructions")
                                .font(.subheadline)
                        }
                        .foregroundColor(.blue)
                        .padding(.vertical, 10)
                    }
                }
                .padding(.vertical, 8)
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color(.systemGray6).opacity(0.25),
                            Color(.systemGray6).opacity(0.2)
                        ]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(
                            animateGlow ? Color.blue.opacity(0.6) : Color.white.opacity(0.1),
                            lineWidth: animateGlow ? 2 : 1
                        )
                )
                .shadow(
                    color: animateGlow ? Color.blue.opacity(0.3) : Color.black.opacity(0.1),
                    radius: animateGlow ? 8 : 4
                )
        )
        .scaleEffect(isNewlyAdded ? 0.98 : 1.0)
        .onAppear {
            // Entrance animation
            withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                isNewlyAdded = false
            }
            
            // Highlight glow effect for newly added exercises
            withAnimation(.easeInOut(duration: 0.8).repeatCount(1, autoreverses: true)) {
                animateGlow = true
            }
            
            // Reset animations after some time
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                withAnimation {
                    animateGlow = false
                }
            }
        }
    }
}

struct ModernNumberStepper: View {
    var value: Int
    var range: ClosedRange<Int>
    var onChanged: (Int) -> Void
    var accentColor: Color
    
    var body: some View {
        HStack(spacing: 16) {
            // Decrement button
            Button(action: {
                if value > range.lowerBound {
                    onChanged(value - 1)
                    
                    // Haptic feedback
                    let impactLight = UIImpactFeedbackGenerator(style: .light)
                    impactLight.impactOccurred()
                }
            }) {
                Image(systemName: "minus")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.white)
                    .frame(width: 36, height: 36)
                    .background(
                        Circle()
                            .fill(value <= range.lowerBound ? Color.gray.opacity(0.2) : accentColor.opacity(0.7))
                    )
            }
            .buttonStyle(ScaleButtonStyle())
            .disabled(value <= range.lowerBound)
            .opacity(value <= range.lowerBound ? 0.5 : 1)
            
            // Value display
            Text("\(value)")
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(.white)
                .frame(minWidth: 40, alignment: .center)
            
            // Increment button
            Button(action: {
                if value < range.upperBound {
                    onChanged(value + 1)
                    
                    // Haptic feedback
                    let impactLight = UIImpactFeedbackGenerator(style: .light)
                    impactLight.impactOccurred()
                }
            }) {
                Image(systemName: "plus")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.white)
                    .frame(width: 36, height: 36)
                    .background(
                        Circle()
                            .fill(value >= range.upperBound ? Color.gray.opacity(0.2) : accentColor.opacity(0.7))
                    )
            }
            .buttonStyle(ScaleButtonStyle())
            .disabled(value >= range.upperBound)
            .opacity(value >= range.upperBound ? 0.5 : 1)
        }
    }
}

// Button style with scale animation
struct ScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.9 : 1)
            .animation(.spring(response: 0.2, dampingFraction: 0.6), value: configuration.isPressed)
    }
}
