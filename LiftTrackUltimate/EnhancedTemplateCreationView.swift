import SwiftUI

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
    @State private var showingIconSelector = false
    
    // Grid layout for colors and icons
    private let columns = [
        GridItem(.adaptive(minimum: 70, maximum: 90), spacing: 15)
    ]
    
    let categories = ["Strength", "Hypertrophy", "HIIT", "Cardio", "Calisthenics", "Full Body", "Upper Body", "Lower Body"]
    
    // Initialize with existing template data if editing
    init(existingTemplate: WorkoutTemplate? = nil, onSave: @escaping (WorkoutTemplate) -> Void) {
        self.existingTemplate = existingTemplate
        self.onSave = onSave
        
        // Initialize state variables with existing template data if available
        if let template = existingTemplate {
            _templateName = State(initialValue: template.name)
            _templateDescription = State(initialValue: template.description ?? "")
            _selectedExercises = State(initialValue: template.exercises)
            _selectedIcon = State(initialValue: template.customIcon ?? "dumbbell.fill")
            // Use TemplateStorageManager to get the color
            _selectedColor = State(initialValue: TemplateStorageManager.shared.getIconColor(for: template) ?? "blue")
            
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
            ZStack {
                // Background color
                Color.black.edgesIgnoringSafeArea(.all)
                
                VStack(spacing: 0) {
                    // Progress steps
                    TemplateProgressSteps(currentStep: currentStep)
                        .padding(.top, 20)
                        .padding(.bottom, 24)
                    
                    // Content area
                    contentArea
                    
                    // Navigation buttons
                    navigationButtons
                        .padding()
                }
                
                // Sheet-like icon and color selector that slides up from bottom
                if showingIconSelector {
                    iconSelectorOverlay
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
                    Text(existingTemplate != nil ? "Edit Template" : stepTitle)
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
    
    // MARK: - UI Component Breakdowns
    
    // Content area based on current step
    private var contentArea: some View {
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
    }
    
    // Icon selector overlay
    private var iconSelectorOverlay: some View {
        ZStack {
            Color.black.opacity(0.5)
                .edgesIgnoringSafeArea(.all)
                .onTapGesture {
                    withAnimation(.spring()) {
                        showingIconSelector = false
                    }
                }
            
            VStack(spacing: 16) {
                // Handle indicator
                Rectangle()
                    .fill(Color.gray.opacity(0.5))
                    .frame(width: 60, height: 5)
                    .cornerRadius(2.5)
                    .padding(.top, 10)
                
                Text("Choose Icon & Color")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding(.bottom, 8)
                
                // Color selector
                VStack(alignment: .leading, spacing: 12) {
                    Text("Color")
                        .font(.subheadline)
                        .foregroundColor(.white)
                        .padding(.leading, 4)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 16) {
                            ForEach(iconColors, id: \.name) { colorOption in
                                Button(action: {
                                    selectedColor = colorOption.name
                                }) {
                                    Circle()
                                        .fill(colorOption.color)
                                        .frame(width: 40, height: 40)
                                        .overlay(
                                            Circle()
                                                .stroke(Color.white, lineWidth: selectedColor == colorOption.name ? 2 : 0)
                                                .padding(1)
                                        )
                                }
                            }
                        }
                        .padding(.horizontal, 4)
                    }
                }
                .padding(.vertical, 8)
                
                // Icon selector grid
                VStack(alignment: .leading, spacing: 12) {
                    Text("Icon")
                        .font(.subheadline)
                        .foregroundColor(.white)
                        .padding(.leading, 4)
                    
                    ScrollView {
                        LazyVGrid(columns: columns, spacing: 20) {
                            ForEach(iconOptions, id: \.icon) { option in
                                Button(action: {
                                    selectedIcon = option.icon
                                }) {
                                    VStack(spacing: 8) {
                                        ZStack {
                                            Circle()
                                                .fill(selectedIcon == option.icon ? getColor(named: selectedColor) : Color(.systemGray6).opacity(0.2))
                                                .frame(width: 60, height: 60)
                                            
                                            Image(systemName: option.icon)
                                                .font(.system(size: 24))
                                                .foregroundColor(selectedIcon == option.icon ? .white : .gray)
                                        }
                                        
                                        Text(option.name)
                                            .font(.caption)
                                            .foregroundColor(selectedIcon == option.icon ? .white : .gray)
                                            .lineLimit(1)
                                            .minimumScaleFactor(0.8)
                                    }
                                    .frame(width: 80)
                                }
                            }
                        }
                        .padding(4)
                    }
                    .frame(height: 300)
                }
                
                Button(action: {
                    withAnimation(.spring()) {
                        showingIconSelector = false
                    }
                }) {
                    Text("Done")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(getColor(named: selectedColor))
                        .cornerRadius(12)
                }
                .padding(.horizontal)
                .padding(.bottom, 20)
            }
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color(.systemGray6).opacity(0.95))
            )
            .padding(.horizontal)
            .frame(maxHeight: 500)
            .transition(.move(edge: .bottom))
            .offset(y: showingIconSelector ? 0 : UIScreen.main.bounds.height)
            .animation(.spring(), value: showingIconSelector)
            .edgesIgnoringSafeArea(.bottom)
            .position(x: UIScreen.main.bounds.width/2, y: UIScreen.main.bounds.height - 250)
        }
    }
    
    // MARK: - Step Sections
    
    // Step 1: Basic Info
    private var basicInfoSection: some View {
        VStack(spacing: 24) {
            // Template icon selection
            VStack(spacing: 16) {
                // Current selected icon
                Button(action: {
                    withAnimation(.spring()) {
                        showingIconSelector = true
                    }
                }) {
                    VStack(spacing: 12) {
                        ZStack {
                            Circle()
                                .fill(getColor(named: selectedColor))
                                .frame(width: 90, height: 90)
                            
                            Image(systemName: selectedIcon)
                                .font(.system(size: 40))
                                .foregroundColor(.white)
                        }
                        
                        Text("Tap to change icon")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                }
                .padding(.bottom, 16)
            }
            
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
                                    .background(
                                        selectedCategory == category ?
                                        getColor(named: selectedColor) :
                                        Color(.systemGray6).opacity(0.2)
                                    )
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
            .toggleStyle(SwitchToggleStyle(tint: getColor(named: selectedColor)))
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
                        .foregroundColor(getColor(named: selectedColor))
                }
            }
            
            if selectedExercises.isEmpty {
                // Empty state
                VStack(spacing: 16) {
                    Image(systemName: selectedIcon)
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
                            .background(getColor(named: selectedColor))
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
                        TemplateExerciseRow(
                            exercise: exercise,
                            index: index,
                            accentColor: getColor(named: selectedColor),
                            onRemove: {
                                selectedExercises.remove(at: index)
                            },
                            onEditSets: { sets in
                                selectedExercises[index].targetSets = sets
                            },
                            onEditReps: { reps in
                                selectedExercises[index].targetReps = reps
                            },
                            onEditWeight: { weight in
                                TemplateStorageManager.shared.setTargetWeight(weight, for: selectedExercises[index])
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
                    .background(getColor(named: selectedColor).opacity(0.2))
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
                // Template icon preview
                ZStack {
                    Circle()
                        .fill(getColor(named: selectedColor).opacity(0.2))
                        .frame(width: 80, height: 80)
                    
                    Image(systemName: selectedIcon)
                        .font(.system(size: 30))
                        .foregroundColor(getColor(named: selectedColor))
                }
                .padding(.top, 20)
                
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
                                .background(getColor(named: selectedColor).opacity(0.2))
                                .foregroundColor(getColor(named: selectedColor))
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
                exerciseSummaryList
            }
            .padding(20)
            .background(Color(.systemGray6).opacity(0.2))
            .cornerRadius(16)
        }
    }
    
    // Exercise summary list for review section
    private var exerciseSummaryList: some View {
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
                        
                        // Show sets, reps, and weight (if set)
                        let repsText = exercise.targetReps != nil ? "\(exercise.targetReps!)" : "0"
                        let weight = TemplateStorageManager.shared.getTargetWeight(for: exercise)
                        let weightText = weight != nil ? " • \(weight!) kg" : ""
                        Text("\(exercise.targetSets) sets × \(repsText) reps\(weightText)")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    
                    Spacer()
                }
                .padding(.vertical, 4)
            }
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
        return currentStep == 2 ? Color.green : getColor(named: selectedColor)
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
    
    // Converts color name to Color object
    func getColor(named colorName: String) -> Color {
        switch colorName.lowercased() {
        case "red": return Color.red
        case "orange": return Color.orange
        case "yellow": return Color.yellow
        case "green": return Color.green
        case "blue": return Color.blue
        case "purple": return Color.purple
        case "pink": return Color.pink
        case "teal": return Color.teal
        default: return Color.blue
        }
    }
    
    // Helper function to add an exercise to the template
    private func addExerciseToTemplate(_ exercise: Exercise) {
        // Check for last performance
        let lastPerformance = dataManager.getLastPerformance(for: exercise)
        
        // Safely unwrap optionals or provide defaults
        let targetSets = lastPerformance?.totalSets ?? 3
        let targetReps = lastPerformance?.lastUsedReps ?? 10
        
        // Create template exercise first
        let templateExercise = TemplateExercise(
            exercise: exercise,
            targetSets: targetSets,
            targetReps: targetReps
        )
        
        // Then set the weight separately using our storage manager
        if let lastWeight = lastPerformance?.lastUsedWeight {
            TemplateStorageManager.shared.setTargetWeight(lastWeight, for: templateExercise)
        }
        
        selectedExercises.append(templateExercise)
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
        
        // Save the icon color using our storage manager
        TemplateStorageManager.shared.setIconColor(selectedColor, for: template)
        
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
        (name: "Chest", icon: "heart.fill"),
        (name: "Back", icon: "figure.strengthtraining.traditional"),
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

struct TemplateExerciseRow: View {
    var exercise: TemplateExercise
    var index: Int
    var accentColor: Color
    var onRemove: () -> Void
    var onEditSets: (Int) -> Void
    var onEditReps: (Int?) -> Void
    var onEditWeight: (Double?) -> Void
    
    @State private var sets: Int
    @State private var reps: Int?
    @State private var weight: Double?
    
    init(exercise: TemplateExercise, index: Int, accentColor: Color, onRemove: @escaping () -> Void, onEditSets: @escaping (Int) -> Void, onEditReps: @escaping (Int?) -> Void, onEditWeight: @escaping (Double?) -> Void) {
        self.exercise = exercise
        self.index = index
        self.accentColor = accentColor
        self.onRemove = onRemove
        self.onEditSets = onEditSets
        self.onEditReps = onEditReps
        self.onEditWeight = onEditWeight
        
        // Initialize local state with exercise values
        _sets = State(initialValue: exercise.targetSets)
        _reps = State(initialValue: exercise.targetReps)
        // Use TemplateStorageManager to get the weight
        _weight = State(initialValue: TemplateStorageManager.shared.getTargetWeight(for: exercise))
    }
    
    var body: some View {
        VStack(spacing: 16) {
            // Exercise header
            HStack {
                // Exercise number
                ZStack {
                    Circle()
                        .fill(accentColor.opacity(0.2))
                        .frame(width: 28, height: 28)
                    
                    Text("\(index + 1)")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(accentColor)
                }
                
                Text(exercise.exercise.name)
                    .font(.headline)
                    .foregroundColor(.white)
                
                Spacer()
                
                // Remove button
                Button(action: onRemove) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.red)
                        .font(.system(size: 18))
                }
            }
            
            // Sets, reps, and weight adjusters
            HStack(spacing: 16) {
                // Sets stepper
                VStack(alignment: .leading, spacing: 4) {
                    Text("Sets")
                        .font(.caption)
                        .foregroundColor(.gray)
                    
                    HStack {
                        Button(action: {
                            if sets > 1 {
                                sets -= 1
                                onEditSets(sets)
                            }
                        }) {
                            Image(systemName: "minus.circle.fill")
                                .foregroundColor(.gray)
                        }
                        
                        Text("\(sets)")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(width: 30, alignment: .center)
                        
                        Button(action: {
                            sets += 1
                            onEditSets(sets)
                        }) {
                            Image(systemName: "plus.circle.fill")
                                .foregroundColor(accentColor)
                        }
                    }
                }
                
                // Reps stepper
                VStack(alignment: .leading, spacing: 4) {
                    Text("Reps")
                        .font(.caption)
                        .foregroundColor(.gray)
                    
                    HStack {
                        Button(action: {
                            if let currentReps = reps, currentReps > 1 {
                                reps = currentReps - 1
                                onEditReps(reps)
                            }
                        }) {
                            Image(systemName: "minus.circle.fill")
                                .foregroundColor(.gray)
                        }
                        
                        Text("\(reps ?? 0)")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(width: 30, alignment: .center)
                        
                        Button(action: {
                            let newReps = (reps ?? 0) + 1
                            reps = newReps
                            onEditReps(reps)
                        }) {
                            Image(systemName: "plus.circle.fill")
                                .foregroundColor(accentColor)
                        }
                    }
                }
                
                // Weight stepper
                VStack(alignment: .leading, spacing: 4) {
                    Text("Weight (kg)")
                        .font(.caption)
                        .foregroundColor(.gray)
                    
                    HStack {
                        Button(action: {
                            if let currentWeight = weight, currentWeight > 0 {
                                weight = max(0, currentWeight - 2.5)
                                onEditWeight(weight)
                            }
                        }) {
                            Image(systemName: "minus.circle.fill")
                                .foregroundColor(.gray)
                        }
                        
                        Text(weight != nil ? String(format: "%.1f", weight!) : "-")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(width: 45, alignment: .center)
                        
                        Button(action: {
                            let newWeight = (weight ?? 0) + 2.5
                            weight = newWeight
                            onEditWeight(weight)
                        }) {
                            Image(systemName: "plus.circle.fill")
                                .foregroundColor(accentColor)
                        }
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemGray6).opacity(0.2))
        .cornerRadius(14)
    }
}
