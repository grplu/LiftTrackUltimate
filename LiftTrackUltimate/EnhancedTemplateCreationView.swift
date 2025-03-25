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
            
            // Initialize other fields with defaults if editing an existing template
            _selectedCategory = State(initialValue: "Strength") // Default category
            _isPublic = State(initialValue: false) // Default to private
        } else {
            _templateName = State(initialValue: "")
            _templateDescription = State(initialValue: "")
            _selectedExercises = State(initialValue: [])
        }
    }
    
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
        // Create new template or update existing one
        let template = WorkoutTemplate(
            id: existingTemplate?.id ?? UUID(),
            name: templateName,
            description: templateDescription.isEmpty ? nil : templateDescription,
            exercises: selectedExercises
        )
        
        // Save using callback
        onSave(template)
        
        // Dismiss the view
        dismiss()
    }
}
