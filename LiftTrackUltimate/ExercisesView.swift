import SwiftUI

struct ExercisesView: View {
    @EnvironmentObject var dataManager: DataManager
    @State private var searchText = ""
    @State private var selectedMuscleGroup: String? = nil
    @State private var showingNewExerciseView = false
    @State private var selectedExercise: Exercise? = nil
    @State private var showingDetailView = false
    
    // Muscle group filters
    let muscleGroups = ["All", "Chest", "Back", "Shoulders", "Delts", "Arms", "Legs", "Core"]
    
    var filteredExercises: [Exercise] {
        // First filter by muscle group
        let muscleGroupFiltered: [Exercise]
        if selectedMuscleGroup == nil || selectedMuscleGroup == "All" {
            muscleGroupFiltered = dataManager.exercises
        } else if selectedMuscleGroup == "Core" {
            // Special case for Core to include Abdominals
            muscleGroupFiltered = dataManager.exercises.filter { exercise in
                let muscleGroups = exercise.muscleGroups
                return muscleGroups.contains(selectedMuscleGroup!) || muscleGroups.contains("Abdominals")
            }
        } else {
            // Regular case - just filter by the selected muscle group
            muscleGroupFiltered = dataManager.exercises.filter { exercise in
                exercise.muscleGroups.contains(selectedMuscleGroup!)
            }
        }
        
        // Then filter by search text if needed
        if searchText.isEmpty {
            return muscleGroupFiltered
        } else {
            let lowercasedSearch = searchText.lowercased()
            return muscleGroupFiltered.filter { exercise in
                // Check if name contains search text
                let nameMatch = exercise.name.lowercased().contains(lowercasedSearch)
                if nameMatch {
                    return true
                }
                
                // Check if any muscle group contains search text
                let muscleGroupsString = exercise.muscleGroups.joined(separator: " ").lowercased()
                return muscleGroupsString.contains(lowercasedSearch)
            }
        }
    }
    
    // Group exercises by primary muscle group - simplified to avoid compiler issues
    func groupExercisesByMuscle() -> [String: [Exercise]] {
        var grouped = [String: [Exercise]]()
        
        for exercise in filteredExercises {
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
        
        return grouped
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background color
                Color.black.edgesIgnoringSafeArea(.all)
                
                VStack(spacing: 0) {
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
                        
                        if !searchText.isEmpty {
                            Button(action: {
                                searchText = ""
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
                    .padding(.top, 16)
                    .padding(.bottom, 12)
                    
                    // Muscle group pills
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 10) {
                            ForEach(muscleGroups, id: \.self) { muscleGroup in
                                Button(action: {
                                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                        if selectedMuscleGroup == muscleGroup {
                                            selectedMuscleGroup = nil
                                        } else {
                                            selectedMuscleGroup = muscleGroup
                                        }
                                        // We removed expandedExerciseId references
                                    }
                                }) {
                                    HStack(spacing: 6) {
                                        Image(systemName: getIconForMuscleGroup(muscleGroup))
                                            .font(.system(size: 14))
                                        
                                        Text(muscleGroup)
                                            .font(.subheadline)
                                            .fontWeight(selectedMuscleGroup == muscleGroup ? .semibold : .medium)
                                    }
                                    .padding(.horizontal, 14)
                                    .padding(.vertical, 10)
                                    .background(
                                        Capsule()
                                            .fill(selectedMuscleGroup == muscleGroup ?
                                                  Color.blue :
                                                  Color(.systemGray6).opacity(0.2)
                                            )
                                    )
                                    .foregroundColor(.white)
                                }
                            }
                        }
                        .padding(.horizontal)
                        .padding(.bottom, 12)
                    }
                    
                    // Exercise list with sections
                    ScrollView {
                        LazyVStack(spacing: 0) {
                            let groupedExercises = groupExercisesByMuscle()
                            
                            ForEach(groupedExercises.keys.sorted(), id: \.self) { muscleGroup in
                                if let exercises = groupedExercises[muscleGroup] {
                                    ExerciseMuscleGroupSection(
                                        muscleGroup: muscleGroup,
                                        exercises: exercises,
                                        dataManager: dataManager,
                                        onSelectExercise: { exercise in
                                            selectedExercise = exercise
                                            showingDetailView = true
                                        }
                                    )
                                }
                            }
                            
                            // Show empty state if no exercises
                            if filteredExercises.isEmpty {
                                EmptyExercisesView(
                                    onClearFilters: {
                                        searchText = ""
                                        selectedMuscleGroup = nil
                                    }
                                )
                            }
                            
                            // Padding at bottom to account for safe area
                            Spacer().frame(height: 50)
                        }
                    }
                }
                
                // Floating Add Button
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Button(action: {
                            showingNewExerciseView = true
                        }) {
                            Image(systemName: "plus")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(.white)
                                .frame(width: 56, height: 56)
                                .background(Circle().fill(Color.blue))
                                .shadow(color: Color.blue.opacity(0.3), radius: 10, x: 0, y: 5)
                        }
                        .padding(.trailing, 20)
                        .padding(.bottom, 80) // Adjust for tab bar
                    }
                }
            }
            .navigationTitle("Exercises")
            .navigationBarTitleDisplayMode(.large)
            // No toolbar items as we're using the floating action button
            .sheet(isPresented: $showingNewExerciseView) {
                NewExerciseView()
                    .environmentObject(dataManager)
            }
            .sheet(isPresented: $showingDetailView) {
                if let exercise = selectedExercise {
                    ExerciseDetailView(exercise: exercise)
                        .environmentObject(dataManager)
                }
            }
        }
        .accentColor(.white) // For navigation bar title color
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

// Muscle Group Section
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
            
            // Exercise cards
            ForEach(exercises) { exercise in
                ModernExerciseCard(
                    exercise: exercise,
                    isExpanded: false, // No longer used
                    performance: dataManager.getLastPerformance(for: exercise),
                    onTap: {
                        // Direct to detail view
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

// Modern Exercise Card - renamed to avoid conflict
struct ModernExerciseCard: View {
    var exercise: Exercise
    var isExpanded: Bool // Kept for compatibility but not used anymore
    var performance: ExercisePerformance?
    var onTap: () -> Void
    
    @State private var isFavorite: Bool = false
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 0) {
                // Basic info row
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
                            .padding(.vertical, 6)
                            .background(
                                Capsule()
                                    .fill(Color.blue.opacity(0.2))
                            )
                    }
                }
                .padding()
            }
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
