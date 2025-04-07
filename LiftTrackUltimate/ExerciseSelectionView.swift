import SwiftUI

struct ExerciseSelectionView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var dataManager: DataManager
    
    @State private var selectedFilter: ExerciseCategory?
    @State private var searchText: String = ""
    @State private var selectedExercisesMap: [UUID: Bool] = [:]
    
    // Pre-compute view models for better performance
    @State private var exerciseViewModels: [ExerciseListViewModel] = []
    
    // Original selected exercises (for comparison)
    let initialSelectedExercises: [Exercise]
    let onSelectionComplete: ([Exercise]) -> Void
    
    init(selectedExercises: [Exercise], onSelectionComplete: @escaping ([Exercise]) -> Void) {
        self.initialSelectedExercises = selectedExercises
        self.onSelectionComplete = onSelectionComplete
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Header with dismiss button and title
            HStack {
                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Image(systemName: "xmark")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                        .padding(8)
                        .background(Circle().fill(Color(.systemGray5).opacity(0.3)))
                }
                
                Spacer()
                
                Text("Add Exercises")
                    .font(.headline)
                    .foregroundColor(.white)
                
                Spacer()
                
                Button(action: {
                    // Get the selected exercises
                    let selectedExercises = exerciseViewModels
                        .filter { $0.isSelected }
                        .map { $0.exercise }
                    
                    // Complete selection
                    onSelectionComplete(selectedExercises)
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Text("Done")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.blue)
                }
                .buttonStyle(BorderlessButtonStyle())
            }
            .padding()
            .background(Color.black.opacity(0.2))
            
            // Search bar
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.gray)
                
                TextField("Search exercises", text: $searchText)
                    .foregroundColor(.white)
                    .autocorrectionDisabled(true)
                
                if !searchText.isEmpty {
                    Button(action: {
                        searchText = ""
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.gray)
                    }
                    .buttonStyle(BorderlessButtonStyle())
                }
            }
            .padding(10)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color(.systemGray6).opacity(0.2))
            )
            .padding([.horizontal, .top])
            
            // Category filter chips
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    FilterChip(
                        title: "All",
                        isSelected: selectedFilter == nil,
                        action: { selectedFilter = nil }
                    )
                    
                    ForEach(ExerciseCategory.allCases, id: \.self) { category in
                        FilterChip(
                            title: category.rawValue,
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
                            // Find the viewModel in our array and toggle selection
                            if let index = exerciseViewModels.firstIndex(where: { $0.id == viewModel.id }) {
                                exerciseViewModels[index].isSelected.toggle()
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
    
    // Initialize view models with selection state
    private func initializeViewModels() {
        let selectedIds = Set(initialSelectedExercises.map { $0.id })
        exerciseViewModels = dataManager.exercises.map { exercise in
            ExerciseListViewModel(
                exercise: exercise,
                isSelected: selectedIds.contains(exercise.id)
            )
        }
    }
    
    // Filter exercises based on category and search text
    private func filteredExercises() -> [ExerciseListViewModel] {
        exerciseViewModels.filter { viewModel in
            // Filter by category - compare with enum's rawValue 
            let matchesCategory: Bool
            if let filter = selectedFilter {
                matchesCategory = viewModel.exercise.category.lowercased() == filter.rawValue.lowercased()
            } else {
                matchesCategory = true
            }
            
            // Filter by search text
            let matchesSearch = searchText.isEmpty || 
                viewModel.name.lowercased().contains(searchText.lowercased())
            
            return matchesCategory && matchesSearch
        }
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
        case "hiit": return .orange
        case "flexibility": return .purple
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
