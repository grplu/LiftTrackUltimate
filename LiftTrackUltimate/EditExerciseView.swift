import SwiftUI
import UIKit

struct EditExerciseView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var dataManager: DataManager
    @FocusState private var focusedField: Field?
    
    enum Field {
        case name, instructions
    }
    
    // Exercise data
    @State private var name: String
    @State private var category: String
    @State private var instructions: String
    @State private var selectedMuscleGroups: Set<String>
    
    // Animation states
    @State private var animateFields = false
    @State private var animateMuscleGroups = false
    @State private var saveButtonActive = false
    
    // Accordion muscle group states
    @State private var expandedMuscleGroup: String? = nil
    
    private var originalExercise: Exercise
    var onSave: (Exercise) -> Void
    
    // Available categories
    let categories = ["Strength", "Cardio", "Flexibility", "Balance", "Core"]
    
    // Muscle group data structure
    struct MuscleGroupData: Identifiable {
        var id: String { name }
        let name: String
        let icon: String
        let subregions: [String]
    }
    
    // List of all muscle groups with their subregions
    let muscleGroups = [
        MuscleGroupData(name: "Chest", icon: "heart.fill",
                     subregions: ["Chest", "Upper Chest", "Lower Chest"]),
        MuscleGroupData(name: "Back", icon: "rectangle.fill",
                     subregions: ["Back", "Upper Back", "Lower Back", "Lats", "Traps"]),
        MuscleGroupData(name: "Shoulders", icon: "seal.fill",
                     subregions: ["Shoulders", "Front Delts", "Side Delts", "Rear Delts"]),
        MuscleGroupData(name: "Arms", icon: "app.fill",
                     subregions: ["Arms", "Biceps", "Triceps", "Forearms"]),
        MuscleGroupData(name: "Legs", icon: "line.2.vertical.circle.fill",
                     subregions: ["Legs", "Quadriceps", "Hamstrings", "Calves", "Glutes"]),
        MuscleGroupData(name: "Core", icon: "seal",
                     subregions: ["Core", "Abdominals", "Obliques"])
    ]
    
    // Computed property for save button availability
    private var canSave: Bool {
        return !name.isEmpty && !selectedMuscleGroups.isEmpty
    }
    
    init(exercise: Exercise, onSave: @escaping (Exercise) -> Void) {
        self.originalExercise = exercise
        self.onSave = onSave
        
        // Initialize state
        self._name = State(initialValue: exercise.name)
        self._category = State(initialValue: exercise.category)
        self._instructions = State(initialValue: exercise.instructions ?? "")
        self._selectedMuscleGroups = State(initialValue: Set(exercise.muscleGroups))
    }
    
    var body: some View {
        ZStack {
            // Background with subtle gradient
            LinearGradient(
                gradient: Gradient(colors: [Color.black, Color(red: 0.08, green: 0.08, blue: 0.1)]),
                startPoint: .top,
                endPoint: .bottom
            )
            .edgesIgnoringSafeArea(.all)
            
            // Transparent background for detecting taps
            Color.black.opacity(0.01)
                .edgesIgnoringSafeArea(.all)
                .onTapGesture {
                    dismissKeyboard()
                }
            
            // Main content layout
            VStack(spacing: 0) {
                // Main scrollable content
                ScrollView {
                    VStack(spacing: 24) {
                        // Exercise details section
                        VStack(alignment: .leading, spacing: 16) {
                            sectionHeader("EXERCISE DETAILS")
                                .opacity(animateFields ? 1 : 0)
                                .offset(y: animateFields ? 0 : 10)
                            
                            // Name field
                            inputField(
                                title: "Exercise Name",
                                iconName: "dumbbell.fill",
                                placeholder: "Enter exercise name"
                            ) {
                                TextField("", text: $name)
                                    .foregroundColor(.white)
                                    .focused($focusedField, equals: .name)
                                    .onChange(of: name) { newValue in
                                        updateSaveButtonState()
                                    }
                            }
                            .opacity(animateFields ? 1 : 0)
                            .offset(y: animateFields ? 0 : 10)
                            
                            // Category picker - as a horizontal scroller
                            VStack(alignment: .leading, spacing: 10) {
                                HStack {
                                    Image(systemName: "list.bullet")
                                        .foregroundColor(.gray)
                                        .frame(width: 24)
                                    
                                    Text("Category")
                                        .font(.system(size: 16))
                                        .foregroundColor(.gray)
                                }
                                
                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack(spacing: 10) {
                                        ForEach(categories, id: \.self) { cat in
                                            CategoryPill(
                                                title: cat,
                                                isSelected: category == cat,
                                                action: {
                                                    category = cat
                                                    dismissKeyboard()
                                                }
                                            )
                                        }
                                    }
                                    .padding(.vertical, 4)
                                }
                            }
                            .opacity(animateFields ? 1 : 0)
                            .offset(y: animateFields ? 0 : 10)
                            
                            // Instructions field with adaptive height
                            VStack(alignment: .leading, spacing: 10) {
                                HStack {
                                    Image(systemName: "text.alignleft")
                                        .foregroundColor(.gray)
                                        .frame(width: 24)
                                    
                                    Text("Instructions")
                                        .font(.system(size: 16))
                                        .foregroundColor(.gray)
                                }
                                
                                ZStack(alignment: .topLeading) {
                                    // Placeholder text
                                    if instructions.isEmpty {
                                        Text("Describe how to perform this exercise...")
                                            .foregroundColor(.gray.opacity(0.7))
                                            .padding(.top, 12)
                                            .padding(.leading, 5)
                                    }
                                    
                                    // Actual text editor
                                    TextEditor(text: $instructions)
                                        .foregroundColor(.white)
                                        .focused($focusedField, equals: .instructions)
                                        .frame(minHeight: instructions.isEmpty ? 60 : min(max(60, CGFloat(instructions.count / 3)), 150))
                                        .scrollContentBackground(.hidden)
                                        .background(Color.clear)
                                }
                                .padding(12)
                                .background(
                                    RoundedRectangle(cornerRadius: 16)
                                        .fill(Color(.systemGray6).opacity(0.15))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 16)
                                                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                                        )
                                )
                            }
                            .opacity(animateFields ? 1 : 0)
                            .offset(y: animateFields ? 0 : 10)
                        }
                        .padding(.horizontal)
                        
                        // Muscle groups section - accordion style
                        collapsibleMuscleGroupSelector()
                        
                        // Extra padding to ensure content isn't hidden by save button
                        Spacer(minLength: 100)
                    }
                    .padding(.top, 20)
                }
                .simultaneousGesture(
                    TapGesture().onEnded { _ in
                        dismissKeyboard()
                    }
                )
                
                // Save Button at bottom
                saveButton
                    .padding(.horizontal, 20)
                    .padding(.bottom, 20)
                    .padding(.top, 10)
                    .background(Color.black.opacity(0.8))
            }
        }
        .onAppear {
            startAnimations()
        }
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: {
                    dismiss()
                }) {
                    Text("Cancel")
                        .foregroundColor(.blue)
                        .fontWeight(.medium)
                }
            }
            
            ToolbarItem(placement: .principal) {
                Text("Edit Exercise")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.white)
            }
            
            // Add keyboard toolbar button to dismiss keyboard
            ToolbarItemGroup(placement: .keyboard) {
                Spacer()
                Button("Done") {
                    dismissKeyboard()
                }
            }
        }
    }
    
    // MARK: - Components
    
    // Helper function to dismiss keyboard
    private func dismissKeyboard() {
        focusedField = nil
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
    
    // Section Header
    private func sectionHeader(_ title: String) -> some View {
        Text(title)
            .font(.system(size: 14, weight: .semibold))
            .foregroundColor(.gray)
            .tracking(1)
    }
    
    // Input Field
    private func inputField<Content: View>(
        title: String,
        iconName: String,
        placeholder: String,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Image(systemName: iconName)
                    .foregroundColor(.gray)
                    .frame(width: 24)
                
                Text(title)
                    .font(.system(size: 16))
                    .foregroundColor(.gray)
            }
            
            HStack {
                content()
            }
            .padding()
            .frame(height: 56)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(.systemGray6).opacity(0.15))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                    )
            )
        }
    }
    
    // Category Pill
    private struct CategoryPill: View {
        var title: String
        var isSelected: Bool
        var action: () -> Void
        
        var body: some View {
            Button(action: action) {
                Text(title)
                    .font(.system(size: 15, weight: isSelected ? .semibold : .regular))
                    .foregroundColor(isSelected ? .white : .gray)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(isSelected ? Color.blue.opacity(0.3) : Color(.systemGray6).opacity(0.15))
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(isSelected ? Color.blue.opacity(0.5) : Color.gray.opacity(0.2), lineWidth: 1)
                            )
                    )
            }
            .buttonStyle(PlainButtonStyle())
            .animation(.spring(response: 0.3), value: isSelected)
        }
    }
    
    // Collapsible muscle group selector
    private func collapsibleMuscleGroupSelector() -> some View {
        VStack(spacing: 8) {
            // Title
            Text("SELECT MUSCLE GROUP")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.gray)
                .tracking(1)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal)
                .padding(.bottom, 8)
            
            // Muscle group accordion
            VStack(spacing: 0) {
                ForEach(muscleGroups) { group in
                    // Header (always visible)
                    Button(action: {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            // Toggle expansion
                            if expandedMuscleGroup == group.name {
                                expandedMuscleGroup = nil
                            } else {
                                expandedMuscleGroup = group.name
                            }
                        }
                        dismissKeyboard()
                    }) {
                        HStack {
                            Image(systemName: group.icon)
                                .font(.system(size: 18))
                                .foregroundColor(.gray)
                                .frame(width: 30)
                            
                            Text(group.name)
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(.white)
                            
                            Spacer()
                            
                            Image(systemName: expandedMuscleGroup == group.name ? "chevron.up" : "chevron.down")
                                .font(.system(size: 14))
                                .foregroundColor(.gray)
                        }
                        .padding(.vertical, 16)
                        .padding(.horizontal)
                        .background(Color.black)
                    }
                    .buttonStyle(PlainButtonStyle())
                    
                    // Show subregions if expanded
                    if expandedMuscleGroup == group.name {
                        VStack(spacing: 0) {
                            ForEach(group.subregions, id: \.self) { subregion in
                                Button(action: {
                                    // Toggle selection instead of replacing
                                    if selectedMuscleGroups.contains(subregion) {
                                        selectedMuscleGroups.remove(subregion)
                                    } else {
                                        selectedMuscleGroups.insert(subregion)
                                    }
                                    
                                    // Dismiss keyboard when selecting
                                    dismissKeyboard()
                                    updateSaveButtonState()
                                }) {
                                    HStack {
                                        Spacer().frame(width: 30) // Alignment with icon above
                                        
                                        Text(subregion)
                                            .font(.system(size: 16))
                                            .foregroundColor(selectedMuscleGroups.contains(subregion) ? .white : .gray)
                                        
                                        Spacer()
                                        
                                        if selectedMuscleGroups.contains(subregion) {
                                            Image(systemName: "checkmark")
                                                .font(.system(size: 14))
                                                .foregroundColor(.blue)
                                        }
                                    }
                                    .padding(.vertical, 14)
                                    .padding(.horizontal)
                                    .background(selectedMuscleGroups.contains(subregion) ? Color.blue.opacity(0.2) : Color.black)
                                }
                                .buttonStyle(PlainButtonStyle())
                                
                                Divider()
                                    .background(Color.gray.opacity(0.2))
                                    .padding(.leading, 50)
                            }
                        }
                        .background(Color(.systemGray6).opacity(0.1))
                        .transition(.opacity.combined(with: .move(edge: .top)))
                    }
                    
                    Divider()
                        .background(Color.gray.opacity(0.3))
                }
            }
            .background(Color.black)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.gray.opacity(0.2), lineWidth: 1)
            )
        }
        .padding(.horizontal)
        .opacity(animateMuscleGroups ? 1 : 0)
        .offset(y: animateMuscleGroups ? 0 : 10)
    }
    
    // Save button
    private var saveButton: some View {
        Button(action: {
            if canSave {
                saveExercise()
            }
        }) {
            // Simple container with content
            ZStack {
                // Background
                RoundedRectangle(cornerRadius: 16)
                    .fill(
                        canSave ?
                        LinearGradient(
                            gradient: Gradient(colors: [Color.blue, Color.blue.opacity(0.8)]),
                            startPoint: .leading,
                            endPoint: .trailing
                        ) :
                        LinearGradient(
                            gradient: Gradient(colors: [Color.gray.opacity(0.5), Color.gray.opacity(0.3)]),
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .shadow(color: canSave ? Color.blue.opacity(0.4) : Color.clear, radius: 8, x: 0, y: 4)
                
                // Save Exercise text with check mark
                HStack(spacing: 8) {
                    Text("Save Changes")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.white)
                    
                    Image(systemName: "checkmark")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                }
            }
            .frame(height: 56)
        }
        .disabled(!canSave)
        .animation(.spring(response: 0.3), value: canSave)
    }
    
    // MARK: - Functions
    
    private func startAnimations() {
        // Pre-expand muscle group sections that contain selected muscles
        for group in muscleGroups {
            let hasSelected = group.subregions.contains { selectedMuscleGroups.contains($0) }
            if hasSelected && expandedMuscleGroup == nil {
                expandedMuscleGroup = group.name
                break
            }
        }
        
        withAnimation(.easeOut(duration: 0.5).delay(0.1)) {
            animateFields = true
        }
        
        withAnimation(.easeOut(duration: 0.5).delay(0.3)) {
            animateMuscleGroups = true
        }
        
        withAnimation(.spring(response: 0.5, dampingFraction: 0.7).delay(0.5)) {
            saveButtonActive = canSave
        }
    }
    
    private func updateSaveButtonState() {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
            saveButtonActive = canSave
        }
    }
    
    private func saveExercise() {
        guard canSave else { return }
        
        // Make sure we have muscle groups selected
        guard !selectedMuscleGroups.isEmpty else { return }
        
        let updatedExercise = Exercise(
            id: originalExercise.id,
            name: name,
            category: category,
            muscleGroups: Array(selectedMuscleGroups),
            instructions: instructions.isEmpty ? nil : instructions
        )
        
        // Call the save handler (passed from parent)
        onSave(updatedExercise)
        
        // Add haptic feedback
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
        
        dismiss()
    }
}
