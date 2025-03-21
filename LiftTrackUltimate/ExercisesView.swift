import SwiftUI

struct ExercisesView: View {
    @EnvironmentObject var dataManager: DataManager
    @State private var searchText = ""
    @State private var selectedMuscleGroup: String? = nil
    @State private var showingNewExerciseView = false
    
    // Muscle group filters
    let muscleGroups = ["All", "Chest", "Back", "Shoulders", "Arms", "Legs", "Core"]
    
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
    
    var body: some View {
        NavigationView {
            VStack {
                // Search bar
                TextField("Search exercises", text: $searchText)
                    .padding(7)
                    .padding(.horizontal, 25)
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
                    .padding(.horizontal, 10)
                    .overlay(
                        HStack {
                            Image(systemName: "magnifyingglass")
                                .foregroundColor(.gray)
                                .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                                .padding(.leading, 15)
                            
                            if !searchText.isEmpty {
                                Button(action: {
                                    searchText = ""
                                }) {
                                    Image(systemName: "multiply.circle.fill")
                                        .foregroundColor(.gray)
                                        .padding(.trailing, 15)
                                }
                            }
                        }
                    )
                    .padding(.top, 10)
                
                // Muscle group picker
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10) {
                        ForEach(muscleGroups, id: \.self) { muscleGroup in
                            MuscleGroupPill(
                                muscleGroup: muscleGroup,
                                isSelected: selectedMuscleGroup == muscleGroup,
                                action: {
                                    if selectedMuscleGroup == muscleGroup {
                                        selectedMuscleGroup = nil
                                    } else {
                                        selectedMuscleGroup = muscleGroup
                                    }
                                }
                            )
                        }
                    }
                    .padding(.horizontal)
                }
                
                // Exercise list
                List {
                    ForEach(filteredExercises) { exercise in
                        NavigationLink(destination: ExerciseDetailView(exercise: exercise)) {
                            VStack(alignment: .leading, spacing: 5) {
                                Text(exercise.name)
                                    .font(.headline)
                                
                                Text(exercise.muscleGroups.joined(separator: ", "))
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                            .padding(.vertical, 5)
                        }
                    }
                }
            }
            .navigationTitle("Exercises")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showingNewExerciseView = true
                    }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingNewExerciseView) {
                NewExerciseView()
                    .environmentObject(dataManager)
            }
        }
    }
}
