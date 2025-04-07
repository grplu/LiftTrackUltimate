import SwiftUI

struct ExerciseSelectionView: View {
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var dataManager: DataManager
    
    @State private var selectedFilter: String = ""
    @State private var searchText: String = ""
    @State private var selectedExercisesMap: [UUID: Bool] = [:]
    
    // Pre-compute view models for better performance
    @State private var exerciseViewModels: [ExerciseListViewModel] = []
    @State private var shouldAutoDismiss = true
    
    // Original selected exercises (for comparison)
    let initialSelectedExercises: [Exercise]
    let onSelectionComplete: ([Exercise]) -> Void
    
    init(initialSelectedExercises: [Exercise], onSelectionComplete: @escaping ([Exercise]) -> Void) {
        self.initialSelectedExercises = initialSelectedExercises
        self.onSelectionComplete = onSelectionComplete
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Header with dismiss button and auto-dismiss toggle
            VStack(spacing: 8) {
                HStack {
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title2)
                            .foregroundColor(.gray)
                    }
                    
                    Spacer()
                    
                    Text(headerText)
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    // Done button to complete selection
                    Button(action: dismissWithSelection) {
                        Text("Done")
                            .font(.headline)
                            .foregroundColor(.blue)
                    }
                }
                .padding()
                
                // Auto-dismiss toggle
                HStack {
                    Toggle("Auto-dismiss on selection", isOn: $shouldAutoDismiss)
                        .toggleStyle(SwitchToggleStyle(tint: .blue))
                        .foregroundColor(.white)
                        .font(.subheadline)
                }
                .padding(.horizontal)
                .padding(.bottom, 8)
                
                if shouldAutoDismiss {
                    Text("Exercises will be added immediately when selected")
                        .font(.caption)
                        .foregroundColor(.gray)
                        .padding(.horizontal)
                        .padding(.bottom, 8)
                }
                
                // Search bar
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.gray)
                    
                    TextField("Search exercises", text: $searchText)
                        .foregroundColor(.white)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                    
                    if !searchText.isEmpty {
                        Button(action: {
                            searchText = ""
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.gray)
                        }
                    }
                }
                .padding(10)
                .background(Color.gray.opacity(0.2))
                .cornerRadius(10)
                .padding(.horizontal)
                
                // Category filters
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        CategoryFilterChip(
                            name: "All",
                            isSelected: selectedFilter.isEmpty,
                            action: { selectedFilter = "" }
                        )
                        
                        ForEach(allCategories, id: \.self) { category in
                            CategoryFilterChip(
                                name: category,
                                isSelected: selectedFilter == category,
                                action: { selectedFilter = category }
                            )
                        }
                    }
                    .padding([.horizontal, .top])
                }
                
                // Exercise list - optimized for performance
                List {
                    let filteredModels = filteredExercises()
                    
                    ForEach(filteredModels) { viewModel in
                        OptimizedExerciseCell(
                            viewModel: viewModel,
                            onSelect: {
                                // Toggle selection first
                                if let index = exerciseViewModels.firstIndex(where: { $0.id == viewModel.id }) {
                                    exerciseViewModels[index].isSelected.toggle()
                                    
                                    // If auto-dismiss is enabled and we just selected the exercise
                                    if shouldAutoDismiss && exerciseViewModels[index].isSelected {
                                        dismissWithSelection()
                                    }
                                }
                            }
                        )
                        .listRowBackground(Color.clear)
                        .listRowSeparator(.hidden)
                        .listRowInsets(EdgeInsets(top: 4, leading: 16, bottom: 4, trailing: 16))
                    }
                }
                .listStyle(PlainListStyle())
                .background(Color.black)
            }
            .background(Color.black.edgesIgnoringSafeArea(.all))
            .onAppear {
                // Pre-compute view models just once
                initializeViewModels()
                
                // Disable haptic feedback for better performance
                UIImpactFeedbackGenerator.disableFeedback = true
            }
            .onDisappear {
                // Re-enable haptic feedback
                UIImpactFeedbackGenerator.disableFeedback = false
            }
        }
    }
    
    // Optimized method for initializing view models to reduce overhead
    private func initializeViewModels() {
        print("Initializing exercise view models")
        let startTime = CFAbsoluteTimeGetCurrent()
        
        // Create a set of IDs for quick lookup
        let selectedExerciseIds = Set(initialSelectedExercises.map { $0.id })
        
        // Process in batches for better performance
        let batchSize = 100
        let exerciseBatches = stride(from: 0, to: dataManager.exercises.count, by: batchSize).map {
            Array(dataManager.exercises[$0..<min($0 + batchSize, dataManager.exercises.count)])
        }
        
        var models: [ExerciseListViewModel] = []
        
        for batch in exerciseBatches {
            let batchModels = batch.map { exercise in
                ExerciseListViewModel(
                    exercise: exercise,
                    isSelected: selectedExerciseIds.contains(exercise.id)
                )
            }
            models.append(contentsOf: batchModels)
        }
        
        self.exerciseViewModels = models
        
        let endTime = CFAbsoluteTimeGetCurrent()
        print("View model initialization took \(endTime - startTime) seconds")
    }
    
    // Optimized filteredExercises method
    private func filteredExercises() -> [ExerciseListViewModel] {
        if selectedFilter.isEmpty && searchText.isEmpty {
            return exerciseViewModels
        }
        
        return exerciseViewModels.filter { viewModel in
            let matchesCategory = selectedFilter.isEmpty ? true : viewModel.categoryName == selectedFilter
            let matchesSearch = searchText.isEmpty ? true : viewModel.name.localizedCaseInsensitiveContains(searchText)
            return matchesCategory && matchesSearch
        }
    }
    
    // Add debug method to check exercises
    private var selectedExercises: [Exercise] {
        return exerciseViewModels
            .filter { $0.isSelected }
            .map { $0.exercise }
    }
    
    // Update header to include selection count
    private var headerText: String {
        let count = selectedExercises.count
        return count > 0 ? "Select Exercises (\(count) selected)" : "Select Exercises"
    }
    
    // Dismiss action
    private func dismissWithSelection() {
        let selectedExercises = exerciseViewModels
            .filter { $0.isSelected }
            .map { $0.exercise }
        
        print("Dismissing with \(selectedExercises.count) selected exercises")
        onSelectionComplete(selectedExercises)
        dismiss()
    }
}

// Exercise selection card
struct ExerciseSelectionCard: View {
    var exercise: Exercise
    var isSelected: Bool
    var onSelect: () -> Void
    
    var body: some View {
        Button(action: onSelect) {
            HStack(spacing: 16) {
                // Exercise icon in circle
                ZStack {
                    Circle()
                        .fill(
                            isSelected ? Color.blue.opacity(0.7) : Color.gray.opacity(0.2)
                        )
                        .frame(width: 50, height: 50)
                    
                    Image(systemName: getExerciseIcon(for: exercise))
                        .font(.system(size: 22))
                        .foregroundColor(isSelected ? .white : .gray)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(exercise.name)
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                    
                    Text(exercise.muscleGroups.joined(separator: ", "))
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
                // Selection indicator
                ZStack {
                    Circle()
                        .stroke(isSelected ? Color.blue : Color.gray.opacity(0.3), lineWidth: 2)
                        .frame(width: 26, height: 26)
                    
                    if isSelected {
                        Circle()
                            .fill(Color.blue)
                            .frame(width: 18, height: 18)
                    }
                }
            }
            .padding(.vertical, 16)
            .padding(.horizontal, 20)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(.systemGray6).opacity(isSelected ? 0.3 : 0.2))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(
                                isSelected ? Color.blue.opacity(0.5) : Color.white.opacity(0.1),
                                lineWidth: isSelected ? 2 : 1
                            )
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    // Helper to get appropriate icon for exercise type
    private func getExerciseIcon(for exercise: Exercise) -> String {
        if exercise.category.lowercased() == "cardio" {
            return "heart.circle"
        }
        
        // Choose icon based on muscle groups
        let muscleGroups = exercise.muscleGroups.map { $0.lowercased() }
        
        if muscleGroups.contains("chest") {
            return "figure.arms.open"
        } else if muscleGroups.contains("back") {
            return "figure.strengthtraining.traditional"
        } else if muscleGroups.contains("shoulders") {
            return "figure.arms.open"
        } else if muscleGroups.contains("biceps") || muscleGroups.contains("triceps") || muscleGroups.contains("arms") {
            return "dumbbell.fill"
        } else if muscleGroups.contains("legs") || muscleGroups.contains("quadriceps") || muscleGroups.contains("hamstrings") {
            return "figure.walk"
        } else if muscleGroups.contains("abdominals") || muscleGroups.contains("core") {
            return "figure.core.training"
        }
        
        // Default icon
        return "figure.mixed.cardio"
    }
}

// MARK: - Performance Optimized Components

// PreCached exercise view model to reduce recalculations
class ExerciseListViewModel: Identifiable {
    let id: UUID
    let exercise: Exercise
    var isSelected: Bool
    
    // Pre-compute expensive properties
    let name: String
    let categoryName: String
    let primaryMuscleGroup: String
    
    init(exercise: Exercise, isSelected: Bool = false) {
        self.id = exercise.id
        self.exercise = exercise
        self.isSelected = isSelected
        
        // Pre-compute values
        self.name = exercise.name
        self.categoryName = exercise.category
        self.primaryMuscleGroup = exercise.muscleGroups.first ?? "General"
    }
}

// Separate extension for Equatable conformance
extension ExerciseListViewModel: Equatable {
    static func == (lhs: ExerciseListViewModel, rhs: ExerciseListViewModel) -> Bool {
        return lhs.id == rhs.id && lhs.isSelected == rhs.isSelected
    }
}

// Separate extension for Hashable conformance  
extension ExerciseListViewModel: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(isSelected)
    }
}

// Optimized exercise cell with minimal redrawing
struct OptimizedExerciseCell: View {
    // Use a view model to avoid rebuilds
    let viewModel: ExerciseListViewModel
    let onSelect: () -> Void
    
    var body: some View {
        Button(action: onSelect) {
            HStack {
                // Icon for category
                ZStack {
                    Circle()
                        .fill(getCategoryColor(viewModel.categoryName).opacity(0.15))
                        .frame(width: 40, height: 40)
                    
                    Image(systemName: getCategoryIcon(viewModel.categoryName))
                        .font(.system(size: 16))
                        .foregroundColor(getCategoryColor(viewModel.categoryName))
                }
                
                // Exercise details
                VStack(alignment: .leading, spacing: 4) {
                    Text(viewModel.name)
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    HStack {
                        Text(viewModel.categoryName)
                            .font(.caption)
                            .foregroundColor(.gray)
                        
                        if !viewModel.primaryMuscleGroup.isEmpty {
                            Text("•")
                                .font(.caption)
                                .foregroundColor(.gray)
                            
                            Text(viewModel.primaryMuscleGroup)
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                    }
                }
                
                Spacer()
                
                // Selection indicator
                if viewModel.isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.blue)
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.systemGray6).opacity(0.2))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(viewModel.isSelected ? Color.blue.opacity(0.5) : Color.clear, lineWidth: 1)
                    )
            )
        }
        .buttonStyle(BorderlessButtonStyle())
    }
    
    // Helper functions that don't depend on changing state
    private func getCategoryColor(_ category: String) -> Color {
        switch category.lowercased() {
        case "strength": return .blue
        case "cardio": return .green
        case "flexibility": return .purple
        case "core": return .orange
        default: return .blue
        }
    }
    
    private func getCategoryIcon(_ category: String) -> String {
        switch category.lowercased() {
        case "strength": return "dumbbell.fill"
        case "cardio": return "heart.fill"
        case "hiit": return "timer"
        case "flexibility": return "figure.flexibility"
        default: return "fitness"
        }
    }
}

// Simple, lightweight filter chip component
struct FilterChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 14, weight: isSelected ? .semibold : .regular))
                .foregroundColor(isSelected ? .white : .gray)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(
                    Capsule()
                        .fill(isSelected ? Color.blue : Color(.systemGray6).opacity(0.2))
                )
        }
        .buttonStyle(BorderlessButtonStyle())
    }
}

// Define available exercise categories from the ExerciseCategory enum
private let allCategories = ["Strength", "Cardio", "Flexibility", "Core", "Balance", "Olympic", "Plyometric", "Other"]

// Reusable category filter chip component
struct CategoryFilterChip: View {
    let name: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(name)
                .font(.subheadline)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(isSelected ? Color.blue : Color.gray.opacity(0.3))
                .foregroundColor(isSelected ? .white : .gray)
                .cornerRadius(16)
        }
    }
}
