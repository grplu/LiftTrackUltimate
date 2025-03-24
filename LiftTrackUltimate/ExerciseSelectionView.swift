import SwiftUI

struct ExerciseSelectionView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var dataManager: DataManager
    @State private var searchText = ""
    @State private var selectedFilter = "All"
    @State private var selectedExerciseIds: Set<UUID> = []
    @State private var showConfirmation = false
    @State private var animateFilters = false
    @State private var animateList = false
    @State private var initialLoad = true
    @State private var shouldDismiss = false
    @State private var lastSelectedExercise: Exercise? = nil
    
    var onExerciseSelected: (Exercise) -> Void
    
    // Enhanced muscle group filters with icons
    private let filters = [
        ("All", "figure.mixed.cardio"),
        ("Chest", "figure.arms.open"),
        ("Back", "figure.strengthtraining.traditional"),
        ("Shoulders", "figure.arms.open"),
        ("Arms", "dumbbell.fill"),
        ("Legs", "figure.run"),
        ("Core", "figure.core.training"),
        ("Cardio", "heart.circle")
    ]
    
    var filteredExercises: [Exercise] {
        var exercises = dataManager.exercises
        
        // Apply search filter
        if !searchText.isEmpty {
            exercises = exercises.filter { $0.name.lowercased().contains(searchText.lowercased()) }
        }
        
        // Apply category filter
        if selectedFilter != "All" {
            exercises = exercises.filter { exercise in
                exercise.muscleGroups.contains(selectedFilter) || exercise.category == selectedFilter
            }
        }
        
        return exercises
    }
    
    var body: some View {
        ZStack {
            // Background color
            Color.black.edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 0) {
                // Custom header
                HStack {
                    Text("Select Exercise")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(.white)
                        .padding(.leading)
                    
                    Spacer()
                    
                    // Done button
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 24))
                            .foregroundColor(.gray)
                            .padding(.trailing)
                    }
                }
                .padding(.top, 12)
                .padding(.bottom, 16)
                
                // Search bar
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(searchText.isEmpty ? .gray : .blue)
                        .font(.system(size: 18))
                        .padding(.leading, 12)
                    
                    TextField("Search exercises...", text: $searchText)
                        .foregroundColor(.white)
                        .padding(.vertical, 12)
                    
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
                .padding(.bottom, 16)
                
                // Filter buttons with icons
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(filters, id: \.0) { filter in
                            Button(action: {
                                selectedFilter = filter.0
                            }) {
                                HStack(spacing: 8) {
                                    Image(systemName: filter.1)
                                        .font(.system(size: 14))
                                    
                                    Text(filter.0)
                                        .font(.subheadline)
                                        .fontWeight(selectedFilter == filter.0 ? .semibold : .medium)
                                }
                                .padding(.horizontal, 14)
                                .padding(.vertical, 10)
                                .background(
                                    Capsule()
                                        .fill(selectedFilter == filter.0 ?
                                              Color.blue :
                                              Color(.systemGray6).opacity(0.2)
                                        )
                                )
                                .foregroundColor(.white)
                            }
                        }
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 16)
                }
                
                // Exercise list
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(filteredExercises) { exercise in
                            ExerciseSelectionCard(
                                exercise: exercise,
                                isSelected: selectedExerciseIds.contains(exercise.id),
                                onSelect: {
                                    handleExerciseSelection(exercise)
                                }
                            )
                        }
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 20)
                }
            }
            
            // Success confirmation popup
            if showConfirmation, let exercise = lastSelectedExercise {
                VStack {
                    Spacer()
                    
                    HStack(spacing: 12) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 20))
                            .foregroundColor(.green)
                        
                        Text("Exercise Added")
                            .font(.headline)
                            .foregroundColor(.white)
                    }
                    .padding(.vertical, 14)
                    .padding(.horizontal, 20)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color(.systemGray6).opacity(0.8))
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(Color.green.opacity(0.3), lineWidth: 1)
                            )
                    )
                    .padding(.bottom, 40)
                }
            }
        }
        .onAppear {
            // Trigger animations when view appears
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                animateFilters = true
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                animateList = true
            }
            
            // Mark as not initial load after first appearance
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                initialLoad = false
            }
        }
        .onChange(of: shouldDismiss) { newValue in
            if newValue {
                dismiss()
            }
        }
    }
    
    private func handleExerciseSelection(_ exercise: Exercise) {
        // Toggle selection state
        if selectedExerciseIds.contains(exercise.id) {
            selectedExerciseIds.remove(exercise.id)
        } else {
            selectedExerciseIds.insert(exercise.id)
        }
        
        // Store selected exercise
        lastSelectedExercise = exercise
        
        // Haptic feedback
        let impactMed = UIImpactFeedbackGenerator(style: .medium)
        impactMed.impactOccurred()
        
        // Call the selection handler
        onExerciseSelected(exercise)
        
        // Show confirmation
        withAnimation(.spring()) {
            showConfirmation = true
        }
        
        // Hide confirmation after a delay but don't dismiss the view
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            withAnimation {
                showConfirmation = false
            }
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
