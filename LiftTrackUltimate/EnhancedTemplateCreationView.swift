import SwiftUI
import ObjectiveC

struct EnhancedTemplateCreationView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var dataManager: DataManager
    var existingTemplate: WorkoutTemplate? // Added to support editing
    var onSave: (WorkoutTemplate) -> Void
    
    @State private var templateName = ""
    @State private var templateDescription = ""
    @State private var selectedCategory = "Strength"
    @State private var isPublic = false
    @State private var selectedExercises: [TemplateExercise] = []
    @State private var currentStep = 0
    @State private var showingExerciseSelection = false
    @State private var selectedIcon = "dumbbell.fill" // Default icon
    @State private var selectedColor = "blue" // Default color
    @State private var showingIconSheet = false // New variable for icon sheet
    
    // Grid layout for colors and icons
    private let columns = [
        GridItem(.adaptive(minimum: 70, maximum: 90), spacing: 15)
    ]
    
    // Template category data
    let templateCategories = [
        (name: "Strength", icon: "dumbbell.fill"),
        (name: "Hypertrophy", icon: "figure.strengthtraining.traditional"),
        (name: "HIIT", icon: "figure.highintensity.intervaltraining"),
        (name: "Cardio", icon: "figure.run"),
        (name: "Calisthenics", icon: "figure.gymnastics"),
        (name: "Full Body", icon: "figure.mixed.cardio"),
        (name: "Upper Body", icon: "figure.arms.open"),
        (name: "Lower Body", icon: "figure.walk")
    ]
    
    // Initialize with existing template data if editing (simplified version)
    init(existingTemplate: WorkoutTemplate?, onSave: @escaping (WorkoutTemplate) -> Void) {
        self.existingTemplate = existingTemplate
        self.onSave = onSave
        
        // Initialize state variables with existing template data if available
        if let template = existingTemplate {
            _templateName = State(initialValue: template.name)
            _templateDescription = State(initialValue: template.description ?? "")
            _selectedExercises = State(initialValue: template.exercises)
            _selectedIcon = State(initialValue: template.customIcon ?? "dumbbell.fill")
            // Get stored color from UserDefaults
            _selectedColor = State(initialValue: UserDefaults.standard.string(forKey: "template_color_\(template.id.uuidString)") ?? "blue")
            
            // Initialize other fields with defaults if editing an existing template
            _selectedCategory = State(initialValue: "Strength") // Default category
            _isPublic = State(initialValue: false) // Default to private
        } else {
            _templateName = State(initialValue: "")
            _templateDescription = State(initialValue: "")
            _selectedExercises = State(initialValue: [])
            _selectedIcon = State(initialValue: "dumbbell.fill")
            _selectedColor = State(initialValue: "blue")
        }
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                if currentStep == 0 {
                    TemplateDetailsSection
                } else if currentStep == 1 {
                    exerciseSection
                } else {
                    reviewSection
                }

                // Navigation buttons
                NavigationFooter
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    // Step indicator
                    TemplateProgressSteps(currentStep: currentStep)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(.blue)
                }
                
                ToolbarItem(placement: .navigationBarLeading) {
                    Text(existingTemplate != nil ? "Edit Template" : "New Template")
                        .font(.headline)
                        .foregroundColor(.white)
                }
            }
            .background(Color.black.edgesIgnoringSafeArea(.all))
            .fullScreenCover(isPresented: $showingIconSheet) {
                IconSelectionView(
                    selectedIcon: $selectedIcon,
                    selectedColor: $selectedColor
                )
                .preferredColorScheme(.dark)
            }
            .sheet(isPresented: $showingExerciseSelection) {
                ExerciseSelectionView(
                    initialSelectedExercises: selectedExercises.map { $0.exercise },
                    onSelectionComplete: onExerciseSelectionComplete
                )
                .environmentObject(dataManager)
                .presentationDetents([.large])
                .presentationDragIndicator(.visible)
            }
        }
    }
    
    // MARK: - UI Component Breakdowns
    
    // Step 1: Basic Info
    private var TemplateDetailsSection: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Template Details")
                .font(.headline)
                .foregroundColor(.white)
                .padding(.horizontal)
                .padding(.top)
            
            VStack(spacing: 16) {
                // Template name field
                VStack(alignment: .leading, spacing: 8) {
                    Text("Template Name")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    
                    TextField("My Workout Template", text: $templateName)
                        .padding()
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(10)
                        .foregroundColor(.white)
                }
                
                // Template description field
                VStack(alignment: .leading, spacing: 8) {
                    Text("Description (Optional)")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    
                    TextEditor(text: $templateDescription)
                        .padding(8)
                        .frame(height: 100)
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(10)
                        .foregroundColor(.white)
                }
                
                // Template icon selection
                VStack(alignment: .leading, spacing: 8) {
                    Text("Icon & Color")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    
                    Button {
                        showingIconSheet = true
                    } label: {
                        HStack {
                            // Icon preview
                            ZStack {
                                Circle()
                                    .fill(Color.getColor(named: selectedColor).opacity(0.2))
                                    .frame(width: 40, height: 40)
                                
                                Image(systemName: selectedIcon)
                                    .font(.system(size: 20))
                                    .foregroundColor(Color.getColor(named: selectedColor))
                            }
                            
                            Text("Tap to Change")
                                .foregroundColor(.gray)
                            
                            Spacer()
                            
                            Image(systemName: "chevron.right")
                                .foregroundColor(.gray)
                        }
                        .padding()
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(10)
                    }
                }
                
                // Template category selection
                VStack(alignment: .leading, spacing: 8) {
                    Text("Category")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    
                    Picker("Category", selection: $selectedCategory) {
                        ForEach(templateCategories, id: \.name) { category in
                            Text(category.name).tag(category.name)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                    .padding()
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(10)
                    .foregroundColor(.white)
                }
                
                // Visibility toggle
                VStack(alignment: .leading, spacing: 8) {
                    Text("Visibility")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    
                    Toggle(isOn: $isPublic) {
                        Text(isPublic ? "Public Template" : "Private Template")
                            .foregroundColor(.white)
                    }
                    .toggleStyle(SwitchToggleStyle(tint: Color.getColor(named: selectedColor)))
                    .padding()
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(10)
                }
            }
            .padding()
        }
    }
    
    // Step 2: Add Exercises
    private var exerciseSection: some View {
        VStack(spacing: 12) {
            HStack {
                Text("Exercises")
                    .font(.headline)
                    .foregroundColor(.white)
                Spacer()
            }
            .padding(.horizontal)
            .padding(.top)
            
            if selectedExercises.isEmpty {
                // Empty state with add button
                VStack(spacing: 16) {
                    Image(systemName: "dumbbell")
                        .font(.system(size: 40))
                        .foregroundColor(.gray)
                    
                    Text("No exercises added yet")
                        .font(.headline)
                        .foregroundColor(.gray)
                    
                    Text("Tap the + button to add exercises to your template")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                    
                    Button(action: {
                        showingExerciseSelection = true
                    }) {
                        HStack(spacing: 8) {
                            Image(systemName: "plus.circle.fill")
                                .font(.system(size: 16))
                            Text("Add Exercise")
                                .font(.system(size: 16, weight: .medium))
                        }
                        .padding(.vertical, 10)
                        .padding(.horizontal, 16)
                        .background(Color.blue.opacity(0.8))
                        .foregroundColor(.white)
                        .cornerRadius(10)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 30)
                .background(Color(UIColor.secondarySystemBackground))
                .cornerRadius(12)
                .padding(.horizontal)
            } else {
                // Use a regular VStack instead of LazyVStack to avoid rendering issues
                VStack(spacing: 15) {
                    // Create view models once and use the array
                    let exerciseViewModels = createViewModels()
                    
                    ForEach(exerciseViewModels.indices, id: \.self) { index in
                        OptimizedTemplateExerciseRow(
                            viewModel: exerciseViewModels[index],
                            onSetsChanged: { newValue in
                                if index < selectedExercises.count {
                                    selectedExercises[index].targetSets = newValue
                                }
                            },
                            onRepsChanged: { newValue in
                                if index < selectedExercises.count {
                                    selectedExercises[index].targetReps = newValue
                                }
                            },
                            onWeightChanged: { newValue in
                                if index < selectedExercises.count {
                                    // Update the targetWeight property directly
                                    selectedExercises[index].targetWeight = newValue > 0 ? Double(newValue) : nil
                                }
                            },
                            onDeleteTapped: {
                                if index < selectedExercises.count {
                                    withAnimation {
                                        selectedExercises.remove(at: index)
                                    }
                                }
                            }
                        )
                        .padding(.horizontal)
                        .id("\(exerciseViewModels[index].exercise.id)_\(exerciseViewModels[index].targetSets)_\(exerciseViewModels[index].targetReps)_\(exerciseViewModels[index].targetWeight)")
                        
                        if index < exerciseViewModels.count - 1 {
                            Divider()
                                .padding(.horizontal)
                        }
                    }
                }
                .background(Color(UIColor.secondarySystemBackground))
                .cornerRadius(12)
                .padding(.horizontal)
                
                // Add Exercise button below the list
                Button(action: {
                    showingExerciseSelection = true
                }) {
                    HStack(spacing: 8) {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 16))
                        Text("Add Exercise")
                            .font(.system(size: 16, weight: .medium))
                    }
                    .padding(.vertical, 10)
                    .padding(.horizontal, 16)
                    .background(Color.blue.opacity(0.8))
                    .foregroundColor(.white)
                    .cornerRadius(10)
                }
                .padding(.horizontal)
                .padding(.top, 8)
            }
        }
    }
    
    // Optimized view model creation to reduce unnecessary recreation
    private func createViewModels() -> [OptimizedTemplateExerciseViewModel] {
        print("Creating view models for \(selectedExercises.count) exercises")
        let startTime = CFAbsoluteTimeGetCurrent()
        
        let viewModels = selectedExercises.map { exercise in
            // Convert Double? to Int for the UI, defaulting to 0
            let weightInt = exercise.targetWeight.flatMap { Int($0) } ?? 0
            
            return OptimizedTemplateExerciseViewModel(
                exercise: exercise,
                targetSets: exercise.targetSets,
                targetReps: exercise.targetReps ?? 10,
                targetWeight: weightInt
            )
        }
        
        let endTime = CFAbsoluteTimeGetCurrent()
        print("View model creation took \(endTime - startTime) seconds")
        return viewModels
    }
    
    // Step 3: Review & Save
    private var reviewSection: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Review Template")
                .font(.headline)
                .foregroundColor(.white)
                .padding(.horizontal)
                .padding(.top)
            
            VStack(spacing: 16) {
                // Template preview card
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        ZStack {
                            Circle()
                                .fill(Color.getColor(named: selectedColor).opacity(0.2))
                                .frame(width: 50, height: 50)
                            
                            Image(systemName: selectedIcon)
                                .font(.system(size: 24))
                                .foregroundColor(Color.getColor(named: selectedColor))
                        }
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text(templateName)
                                .font(.headline)
                                .foregroundColor(.white)
                            
                            Text(selectedCategory)
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                        
                        Spacer()
                        
                        VStack(alignment: .trailing, spacing: 4) {
                            Text("\(selectedExercises.count) Exercises")
                                .font(.subheadline)
                                .foregroundColor(.white)
                            
                            Text(isPublic ? "Public" : "Private")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                    }
                    
                    Divider().background(Color.gray.opacity(0.3))
                    
                    // Exercise summary list
                    ForEach(selectedExercises, id: \.id) { exercise in
                        HStack {
                            EnhancedTemplateCreationView.getIconForMuscleGroup(exercise.exercise.muscleGroups.first ?? "")
                                .font(.system(size: 14))
                                .foregroundColor(.white)
                                .frame(width: 24, height: 24)
                                .background(Color.gray.opacity(0.3))
                                .clipShape(Circle())
                            
                            Text(exercise.exercise.name)
                                .font(.subheadline)
                                .foregroundColor(.white)
                            
                            Spacer()
                            
                            Text("\(exercise.targetSets) × \(exercise.targetReps ?? 0)")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                    }
                }
                .padding()
                .background(Color.gray.opacity(0.2))
                .cornerRadius(16)
            }
            .padding()
        }
    }
    
    // MARK: - Navigation Buttons
    
    var NavigationFooter: some View {
        HStack {
            if currentStep > 0 {
                Button("Back") {
                    withAnimation {
                        currentStep -= 1
                    }
                }
                .foregroundColor(.blue)
            }
            
            Spacer()
            
            Button(currentStep < 2 ? "Next" : "Save") {
                if currentStep < 2 {
                    withAnimation {
                        currentStep += 1
                    }
                } else {
                    saveTemplate()
                }
            }
            .foregroundColor(.white)
            .padding(.vertical, 10)
            .padding(.horizontal, 20)
            .background(Color.blue)
            .cornerRadius(10)
            .disabled(currentStep == 1 && selectedExercises.isEmpty)
        }
        .padding()
        .background(Color.black.opacity(0.7))
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
        return currentStep == 2 ? Color.green : Color.getColor(named: selectedColor)
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
    
    // MARK: - Exercise Selection
    private func showExerciseSelection() {
        showingExerciseSelection = true
    }
    
    // More efficient function to add exercises to template
    func addExerciseToTemplate(exercise: Exercise) {
        print("Adding exercise: \(exercise.name)")
        
        // Check if the exercise is already in the template to avoid duplicates
        if selectedExercises.contains(where: { $0.exercise.id == exercise.id }) {
            print("Exercise already in template, skipping")
            return
        }
        
        // Get last performance for default values if available
        let lastWeight = dataManager.getLastPerformance(for: exercise)?.lastUsedWeight
        
        // Create a template exercise with default values
        let templateExercise = TemplateExercise(
            exercise: exercise,
            targetSets: 3,
            targetReps: 10,
            targetWeight: lastWeight
        )
        
        // Add it to the array
        withAnimation {
            selectedExercises.append(templateExercise)
            print("Added exercise successfully. Total exercises: \(selectedExercises.count)")
        }
    }
    
    // More efficient handling of exercise selection completion
    private func onExerciseSelectionComplete(_ exercises: [Exercise]) {
        print("Exercise selection complete with \(exercises.count) exercises")
        
        // Add any new exercises that aren't already in the template
        for exercise in exercises {
            addExerciseToTemplate(exercise: exercise)
        }
    }
    
    private func saveTemplate() {
        // Create new template or update existing one
        let template: WorkoutTemplate
        if let existingTemplate = existingTemplate {
            // Update existing template
            template = WorkoutTemplate(
                id: existingTemplate.id,
                name: templateName,
                description: templateDescription.isEmpty ? nil : templateDescription,
                exercises: selectedExercises,
                customIcon: selectedIcon
            )
        } else {
            // Create new template
            template = WorkoutTemplate(
                id: UUID(),
                name: templateName,
                description: templateDescription.isEmpty ? nil : templateDescription,
                exercises: selectedExercises,
                customIcon: selectedIcon
            )
        }
        
        // Save the icon color in UserDefaults
        UserDefaults.standard.set(selectedColor, forKey: "template_color_\(template.id.uuidString)")
        
        // Save using callback
        onSave(template)
        
        // Dismiss the view
        dismiss()
    }
    
    // MARK: - Color and Icon Options
    
    // Available colors for icons
    let iconColors = [
        (name: "blue", color: Color.blue),
        (name: "red", color: Color.red),
        (name: "green", color: Color.green),
        (name: "orange", color: Color.orange),
        (name: "purple", color: Color.purple),
        (name: "pink", color: Color.pink),
        (name: "yellow", color: Color.yellow),
        (name: "teal", color: Color.teal)
    ]
    
    // Icon options array
    let iconOptions = [
        (name: "Dumbbell", icon: "dumbbell.fill"),
        (name: "Running", icon: "figure.run"),
        (name: "Heart", icon: "heart.fill"),
        (name: "Flame", icon: "flame.fill"),
        (name: "Person", icon: "figure.strengthtraining.traditional"),
        (name: "Arms", icon: "figure.arms.open"),
        (name: "Cycling", icon: "figure.indoor.cycle"),
        (name: "Yoga", icon: "figure.mind.and.body"),
        (name: "Chest", icon: "figure.heart.circle"),
        (name: "Back", icon: "figure.strengthtraining.functional"),
        (name: "Shoulders", icon: "person.bust"),
        (name: "Core", icon: "figure.core.training"),
        (name: "Legs", icon: "figure.walk"),
        (name: "Cardio", icon: "figure.mixed.cardio"),
        (name: "Timer", icon: "timer"),
        (name: "Calendar", icon: "calendar"),
        (name: "Weight", icon: "scalemass.fill"),
        (name: "Fitness", icon: "figure.highintensity.intervaltraining"),
        (name: "Boxing", icon: "figure.boxing"),
        (name: "Dance", icon: "figure.dance"),
        (name: "Hiking", icon: "figure.hiking"),
        (name: "Water", icon: "drop.fill"),
        (name: "Nutrition", icon: "fork.knife"),
        (name: "Sleep", icon: "bed.double.fill")
    ]
    
    // Helper function to get the appropriate icon for a muscle group
    static func getIconForMuscleGroup(_ muscleGroup: String) -> Image {
        switch muscleGroup.lowercased() {
        case "chest":
            return Image(systemName: "figure.strengthtraining.traditional")
        case "back":
            return Image(systemName: "figure.strengthtraining.functional")
        case "shoulders":
            return Image(systemName: "figure.arms.open")
        case "arms", "biceps", "triceps":
            return Image(systemName: "figure.archery")
        case "abs", "core":
            return Image(systemName: "figure.play")
        case "legs", "quads", "hamstrings", "calves":
            return Image(systemName: "figure.run")
        default:
            return Image(systemName: "dumbbell")
        }
    }
}

// MARK: - Supporting Views

struct TemplateProgressSteps: View {
    var currentStep: Int
    
    var body: some View {
        HStack(spacing: 4) {
            ForEach(0..<3) { step in
                Rectangle()
                    .fill(step <= currentStep ? Color.blue : Color.gray.opacity(0.3))
                    .frame(height: 4)
                    .cornerRadius(2)
            }
        }
        .padding(.horizontal)
    }
}

// MARK: - Optimized Template Exercise View Model
// Pre-computed view model to minimize recalculations and rebuilds
class OptimizedTemplateExerciseViewModel: Identifiable {
    let id = UUID()
    let exercise: TemplateExercise
    
    // Pre-computed properties to avoid recalculations
    let exerciseName: String
    let muscleGroup: String
    let muscleGroups: [String]
    
    // Values that can be modified
    var targetSets: Int
    var targetReps: Int
    var targetWeight: Int
    
    init(exercise: TemplateExercise, targetSets: Int, targetReps: Int, targetWeight: Int) {
        self.exercise = exercise
        self.exerciseName = exercise.exercise.name
        self.muscleGroups = exercise.exercise.muscleGroups
        self.muscleGroup = exercise.exercise.muscleGroups.first ?? "General"
        
        self.targetSets = targetSets
        self.targetReps = targetReps
        self.targetWeight = targetWeight
    }
}

// Optimized row that only renders what's needed
struct OptimizedTemplateExerciseRow: View {
    // Use a view model to prevent excessive view rebuilds
    let viewModel: OptimizedTemplateExerciseViewModel
    
    // Callbacks for when values change
    let onSetsChanged: (Int) -> Void
    let onRepsChanged: (Int) -> Void
    let onWeightChanged: (Int) -> Void
    let onDeleteTapped: () -> Void
    
    var body: some View {
        VStack(spacing: 12) {
            // Exercise header
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(viewModel.exerciseName)
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    Text(viewModel.muscleGroup)
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
                Button(action: onDeleteTapped) {
                    Image(systemName: "trash")
                        .foregroundColor(.red)
                        .padding(8)
                }
            }
            
            // Exercise parameters
            HStack(spacing: 12) {
                // Sets
                parameterPicker(
                    label: "Sets",
                    selection: Binding(
                        get: { viewModel.targetSets },
                        set: { onSetsChanged($0) }
                    ),
                    range: 1...10
                )
                
                // Reps
                parameterPicker(
                    label: "Reps",
                    selection: Binding(
                        get: { viewModel.targetReps },
                        set: { onRepsChanged($0) }
                    ),
                    range: 1...50
                )
                
                // Weight
                weightPicker(
                    label: "Weight",
                    selection: Binding(
                        get: { viewModel.targetWeight },
                        set: { onWeightChanged($0) }
                    )
                )
            }
        }
        .padding()
        .background(Color(UIColor.tertiarySystemBackground))
        .cornerRadius(10)
    }
    
    // Reusable picker for parameters
    private func parameterPicker(label: String, selection: Binding<Int>, range: ClosedRange<Int>) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label)
                .font(.caption)
                .foregroundColor(.gray)
            
            ZStack {
                Color(UIColor.systemGray6)
                    .cornerRadius(8)
                
                // Use a simple Menu instead of WheelPicker to improve performance
                Menu {
                    ForEach(range, id: \.self) { value in
                        Button(action: {
                            selection.wrappedValue = value
                        }) {
                            Text("\(value)")
                                .foregroundColor(selection.wrappedValue == value ? .blue : .white)
                        }
                    }
                } label: {
                    Text("\(selection.wrappedValue)")
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 40)
                }
                .buttonStyle(BorderlessButtonStyle())
            }
            .frame(height: 40)
        }
        .frame(maxWidth: .infinity)
    }
    
    // Specialized picker for weight
    private func weightPicker(label: String, selection: Binding<Int>) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label)
                .font(.caption)
                .foregroundColor(.gray)
            
            ZStack {
                Color(UIColor.systemGray6)
                    .cornerRadius(8)
                
                // Use a simple Menu instead of WheelPicker to improve performance
                Menu {
                    Button(action: {
                        selection.wrappedValue = 0
                    }) {
                        Text("BW")
                            .foregroundColor(selection.wrappedValue == 0 ? .blue : .white)
                    }
                    
                    ForEach([5, 10, 15, 20, 25, 30, 40, 50, 60, 70, 80, 90, 100, 120, 140, 160, 180, 200], id: \.self) { value in
                        Button(action: {
                            selection.wrappedValue = value
                        }) {
                            Text("\(value)")
                                .foregroundColor(selection.wrappedValue == value ? .blue : .white)
                        }
                    }
                } label: {
                    HStack {
                        Text(selection.wrappedValue == 0 ? "BW" : "\(selection.wrappedValue)")
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        Spacer()
                        
                        Text("kg")
                            .font(.caption)
                            .foregroundColor(.gray)
                            .padding(.trailing, 8)
                    }
                    .padding(.leading, 8)
                    .frame(height: 40)
                }
                .buttonStyle(BorderlessButtonStyle())
            }
            .frame(height: 40)
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Haptic Feedback Extension
// Extension to disable haptic feedback which is causing errors in the app
extension UIImpactFeedbackGenerator {
    static var disableFeedback = false
    
    // Simple non-swizzling approach for haptic control
    // This method is intentionally designed to not throw errors for ease of use in UI code
    static func safeImpactOccurred(intensity: CGFloat = 1.0) {
        if !disableFeedback {
            let generator = UIImpactFeedbackGenerator(style: .medium)
            generator.prepare()
            generator.impactOccurred(intensity: intensity)
        }
    }
}

// MARK: - Exercise Extension
extension Exercise {
    var primaryMuscleGroup: String {
        return muscleGroups.first ?? ""
    }
}
