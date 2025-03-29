import SwiftUI

struct ExercisesView: View {
    @EnvironmentObject var dataManager: DataManager
    
    // State variables
    @State private var searchText = ""
    @State private var selectedMuscleGroup: String? = nil
    @State private var selectedExercise: Exercise? = nil
    @State private var showingDetailView = false
    @State private var showingNewExerciseView = false
    
    // Advanced optimization: Prefetch and maintain data
    @State private var allExercises: [Exercise] = []
    @State private var filteredExercises: [Exercise] = []
    @State private var groupedExercises: [String: [Exercise]] = [:]
    @State private var isFirstAppear = true
    
    // Muscle group filters
    let muscleGroups = ["All", "Chest", "Back", "Shoulders", "Delts", "Arms", "Legs", "Core"]
    
    var body: some View {
        ZStack {
            // Background color
            Color.black.edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 0) {
                // Title
                HStack {
                    Text("Exercises")
                        .font(.system(size: 36, weight: .bold))
                        .foregroundColor(.white)
                        .padding(.horizontal)
                        .padding(.top, 16)
                    Spacer()
                }
                .padding(.bottom, 8)
                
                // Modern search bar
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(searchText.isEmpty ? .gray : .blue)
                        .font(.system(size: 18))
                        .padding(.leading, 12)
                    
                    TextField("Search exercises", text: $searchText)
                        .foregroundColor(.white)
                        .padding(.vertical, 12)
                        .accentColor(.blue)
                        .onChange(of: searchText) { newValue in
                            // Debounced filtering
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                filterExercises()
                            }
                        }
                    
                    if !searchText.isEmpty {
                        Button(action: {
                            searchText = ""
                            filterExercises()
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.gray)
                                .padding(.trailing, 12)
                        }
                    }
                }
                .background(
                    RoundedRectangle(cornerRadius: 14)
                        .fill(Color(.systemGray6).opacity(0.2))
                        .overlay(
                            RoundedRectangle(cornerRadius: 14)
                                .stroke(Color.white.opacity(0.1), lineWidth: 1)
                        )
                )
                .padding(.horizontal)
                .padding(.top, 8)
                .padding(.bottom, 12)
                
                // Muscle group pills
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10) {
                        ForEach(muscleGroups, id: \.self) { muscleGroup in
                            MuscleGroupButton(
                                muscleGroup: muscleGroup,
                                isSelected: selectedMuscleGroup == muscleGroup,
                                onTap: {
                                    if selectedMuscleGroup == muscleGroup {
                                        selectedMuscleGroup = nil
                                    } else {
                                        selectedMuscleGroup = muscleGroup
                                    }
                                    filterExercises()
                                }
                            )
                        }
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 12)
                }
                
                // Exercise list with sections - LazyVStack for performance
                if !filteredExercises.isEmpty {
                    ScrollView {
                        LazyVStack(spacing: 0) {
                            ForEach(groupedExercises.keys.sorted(), id: \.self) { muscleGroup in
                                if let exercises = groupedExercises[muscleGroup], !exercises.isEmpty {
                                    ExerciseMuscleGroupSection(
                                        muscleGroup: muscleGroup,
                                        exercises: exercises,
                                        dataManager: dataManager,
                                        onSelectExercise: { exercise in
                                            // Simple, direct selection - avoid redundant calculations
                                            selectedExercise = exercise
                                            showingDetailView = true
                                        }
                                    )
                                }
                            }
                            
                            // Padding at bottom to account for safe area
                            Spacer().frame(height: 100)
                        }
                    }
                    .scrollIndicators(.hidden)
                } else {
                    // Show empty state if no exercises
                    EmptyExercisesView(
                        onClearFilters: {
                            searchText = ""
                            selectedMuscleGroup = nil
                            filterExercises()
                        }
                    )
                }
            }
        }
        // OPTIMIZATION: Add ID to improve state management
        .id("ExercisesView")
        
        // Floating Action Button
        .overlay(
            Button {
                showingNewExerciseView = true
            } label: {
                Image(systemName: "plus")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.white)
                    .frame(width: 56, height: 56)
                    .background(Circle().fill(Color.blue))
                    .shadow(color: Color.blue.opacity(0.3), radius: 10, x: 0, y: 5)
            }
            .padding(.trailing, 20)
            .padding(.bottom, 80) // Adjust for tab bar
            .contentShape(Circle()) // Ensure the whole circle is tappable
            ,
            alignment: .bottomTrailing
        )
        .sheet(isPresented: $showingDetailView) {
            if let exercise = selectedExercise {
                // Use NavigationView to ensure proper environment inheritance
                NavigationView {
                    ZStack {
                        Color.black.edgesIgnoringSafeArea(.all)
                        
                        ExerciseDetailView(exercise: exercise)
                    }
                }
                .navigationViewStyle(StackNavigationViewStyle())
                .environmentObject(dataManager)
            }
        }
        .sheet(isPresented: $showingNewExerciseView) {
            NewExerciseView()
                .environmentObject(dataManager)
        }
        // OPTIMIZATION: Only load data once
        .onAppear {
            if isFirstAppear {
                // Preload and preprocess data on first appear
                allExercises = dataManager.exercises
                filterExercises()
                isFirstAppear = false
            }
        }
    }
    
    // MARK: - Optimized Filtering
    
    private func filterExercises() {
        // Start with all exercises
        var result = allExercises
        
        // First filter by muscle group (more selective)
        if let selectedGroup = selectedMuscleGroup, selectedGroup != "All" {
            if selectedGroup == "Core" {
                // Special case for Core
                result = result.filter { exercise in
                    exercise.muscleGroups.contains(selectedGroup) || exercise.muscleGroups.contains("Abdominals")
                }
            } else {
                result = result.filter { exercise in
                    exercise.muscleGroups.contains(selectedGroup)
                }
            }
        }
        
        // Then filter by search text
        if !searchText.isEmpty {
            let lowercasedSearch = searchText.lowercased()
            result = result.filter { exercise in
                // Check name first (most common match)
                if exercise.name.lowercased().contains(lowercasedSearch) {
                    return true
                }
                
                // Check muscle groups (less common)
                return exercise.muscleGroups.joined(separator: " ").lowercased().contains(lowercasedSearch)
            }
        }
        
        // Update filtered exercises
        filteredExercises = result
        
        // Group exercises (only if we have results)
        if !result.isEmpty {
            var grouped = [String: [Exercise]]()
            
            // Group by primary muscle group
            for exercise in result {
                if let primaryMuscle = exercise.muscleGroups.first {
                    if grouped[primaryMuscle] == nil {
                        grouped[primaryMuscle] = []
                    }
                    grouped[primaryMuscle]?.append(exercise)
                } else {
                    // Handle exercises with no muscle groups
                    let category = "Other"
                    if grouped[category] == nil {
                        grouped[category] = []
                    }
                    grouped[category]?.append(exercise)
                }
            }
            
            groupedExercises = grouped
        } else {
            groupedExercises = [:]
        }
    }
    
    // Helper to get appropriate icon for muscle group
    func getIconForMuscleGroup(_ muscleGroup: String) -> String {
        switch muscleGroup.lowercased() {
        case "all":
            return "figure.mixed.cardio"
        case "chest":
            return "figure.arms.open"
        case "back":
            return "figure.strengthtraining.traditional"
        case "shoulders", "delts":
            return "figure.arms.open"
        case "arms":
            return "dumbbell.fill"
        case "legs":
            return "figure.walk"
        case "core":
            return "figure.core.training"
        default:
            return "figure.mixed.cardio"
        }
    }
}

// MARK: - Supporting Views

// Muscle Group Button
struct MuscleGroupButton: View {
    var muscleGroup: String
    var isSelected: Bool
    var onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 6) {
                Image(systemName: getIconForMuscleGroup(muscleGroup))
                    .font(.system(size: 14))
                
                Text(muscleGroup)
                    .font(.subheadline)
                    .fontWeight(isSelected ? .semibold : .medium)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .background(
                Capsule()
                    .fill(isSelected ?
                          Color.blue :
                            Color(.systemGray6).opacity(0.2)
                    )
            )
            .foregroundColor(.white)
        }
    }
    
    // Helper function to get icon for muscle group
    func getIconForMuscleGroup(_ muscleGroup: String) -> String {
        switch muscleGroup.lowercased() {
        case "all":
            return "figure.mixed.cardio"
        case "chest":
            return "figure.arms.open"
        case "back":
            return "figure.strengthtraining.traditional"
        case "shoulders", "delts":
            return "figure.arms.open"
        case "arms":
            return "dumbbell.fill"
        case "legs":
            return "figure.walk"
        case "core":
            return "figure.core.training"
        default:
            return "figure.mixed.cardio"
        }
    }
}

// Muscle Group Section - Optimized to avoid closures in loops
struct ExerciseMuscleGroupSection: View {
    var muscleGroup: String
    var exercises: [Exercise]
    var dataManager: DataManager
    var onSelectExercise: (Exercise) -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Section header
            HStack {
                Text(muscleGroup)
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .padding(.leading)
                    .padding(.vertical, 12)
                
                Spacer()
                
                Text("\(exercises.count)")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .padding(.trailing)
            }
            .background(Color.black)
            
            Divider()
                .background(Color.gray.opacity(0.3))
            
            // Exercise cards - using LazyVStack for better performance with many exercises
            ForEach(exercises) { exercise in
                ModernExerciseCard(
                    exercise: exercise,
                    performance: dataManager.getLastPerformance(for: exercise),
                    onTap: {
                        onSelectExercise(exercise)
                    }
                )
                
                Divider()
                    .background(Color.gray.opacity(0.1))
                    .padding(.horizontal)
            }
        }
    }
}

// Empty State View
struct EmptyExercisesView: View {
    var onClearFilters: () -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "dumbbell.fill")
                .font(.system(size: 50))
                .foregroundColor(.gray)
                .padding(.top, 40)
            
            Text("No exercises found")
                .font(.headline)
                .foregroundColor(.white)
            
            Text("Try a different search or filter")
                .font(.subheadline)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            Button(action: onClearFilters) {
                Text("Clear Filters")
                    .foregroundColor(.blue)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)
                    .background(
                        Capsule()
                            .stroke(Color.blue, lineWidth: 1)
                    )
            }
            .padding(.top, 10)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 50)
    }
}

// Simplified and optimized exercise card
struct ModernExerciseCard: View {
    var exercise: Exercise
    var performance: ExercisePerformance?
    var onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 16) {
                // Exercise icon
                ZStack {
                    Circle()
                        .fill(Color(.systemGray6).opacity(0.2))
                        .frame(width: 46, height: 46)
                    
                    Image(systemName: getExerciseIcon(for: exercise))
                        .font(.system(size: 20))
                        .foregroundColor(.gray)
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
                
                // Show last weight if available
                if let weight = performance?.lastUsedWeight {
                    Text("\(String(format: "%.1f", weight)) kg")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.white)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(
                            Capsule()
                                .fill(Color.blue.opacity(0.2))
                        )
                }
            }
            .padding()
            .contentShape(Rectangle())
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    // Helper to get appropriate icon for exercise type
    func getExerciseIcon(for exercise: Exercise) -> String {
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
