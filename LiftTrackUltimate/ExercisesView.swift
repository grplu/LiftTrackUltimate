import SwiftUI

struct ExercisesView: View {
    @EnvironmentObject var dataManager: DataManager
    
    // State for search and filtering
    @State private var searchText = ""
    @State private var filteredExercises: [Exercise] = []
    @State private var selectedMuscleGroup: String? = nil
    @State private var showingNewExerciseView = false
    @State private var isSearchActive = false
    @State private var selectedExercise: Exercise? = nil
    @State private var showingExerciseDetail = false
    
    // Muscle group filters - simplified to reduce rendering load
    let muscleGroups = ["All", "Chest", "Back", "Shoulders", "Arms", "Legs", "Core"]
    
    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            // Black background
            Color.black.edgesIgnoringSafeArea(.all)
            
            // Main content
            VStack(spacing: 0) {
                // Header
                HStack {
                    Text("Exercises")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    Spacer()
                    Button(action: { isSearchActive.toggle() }) {
                        Image(systemName: "magnifyingglass")
                            .font(.system(size: 20))
                            .foregroundColor(.white)
                    }
                }
                .padding(.horizontal)
                .padding(.top, 8)
                .padding(.bottom, 16)
                
                // Basic list of exercises with simplified styling to avoid Metal issues
                if dataManager.exercises.isEmpty {
                    Text("No exercises found")
                        .foregroundColor(.white)
                        .padding(.top, 40)
                } else {
                    ScrollView {
                        LazyVStack(spacing: 1) {
                            ForEach(dataManager.exercises) { exercise in
                                ExerciseListRow(exercise: exercise) {
                                    selectedExercise = exercise
                                    showingExerciseDetail = true
                                }
                            }
                        }
                        .padding(.bottom, 100) // Padding for FAB
                    }
                }
            }
            
            // Floating Action Button - positioned with alignment parameter
            Button(action: { showingNewExerciseView = true }) {
                Image(systemName: "plus")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(.white)
                    .frame(width: 56, height: 56)
                    .background(Color.blue)
                    .clipShape(Circle())
                    .shadow(color: Color.black.opacity(0.3), radius: 5, x: 0, y: 3)
            }
            .padding(.bottom, 72)
            .padding(.trailing, 24)
        }
        .onAppear {
            if dataManager.exercises.isEmpty {
                dataManager.loadSampleExercises()
            }
            filteredExercises = dataManager.exercises
        }
        .sheet(isPresented: $showingNewExerciseView) {
            NewExerciseView()
                .environmentObject(dataManager)
        }
        .sheet(isPresented: $showingExerciseDetail) {
            if let exercise = selectedExercise {
                ExerciseDetailView(exercise: exercise)
                    .environmentObject(dataManager)
            }
        }
    }
    
    // MARK: - Helper Methods
    
    private func filterExercises() {
        filteredExercises = dataManager.exercises
    }
}

// Simple exercise row component - renamed to avoid conflicts
struct ExerciseListRow: View {
    let exercise: Exercise
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                // Simple icon
                ZStack {
                    Circle()
                        .fill(Color.blue.opacity(0.2))
                        .frame(width: 48, height: 48)
                    
                    Image(systemName: getIconName())
                        .font(.system(size: 20))
                        .foregroundColor(.blue)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(exercise.name)
                        .font(.headline)
                        .foregroundColor(.white)
                    Text(exercise.muscleGroups.joined(separator: ", "))
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 14))
                    .foregroundColor(.gray)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(Color.black)
        }
        .buttonStyle(PlainButtonStyle())
        Divider()
            .background(Color.gray.opacity(0.3))
            .padding(.horizontal, 16)
    }
    
    // Local icon function to reduce complexity
    private func getIconName() -> String {
        let groups = exercise.muscleGroups.map { $0.lowercased() }
        
        if groups.contains("chest") { return "heart.fill" }
        if groups.contains("back") { return "person.fill" }
        if groups.contains("shoulders") { return "person.crop.rectangle.fill" }
        if groups.contains("biceps") || groups.contains("triceps") || groups.contains("arms") { return "dumbbell.fill" }
        if groups.contains("legs") || groups.contains("quadriceps") || groups.contains("hamstrings") { return "figure.walk" }
        if groups.contains("core") || groups.contains("abdominals") { return "figure.core.training" }
        
        return "figure.mixed.cardio"
    }
}
