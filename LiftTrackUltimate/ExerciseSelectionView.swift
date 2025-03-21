import SwiftUI

struct ExerciseSelectionView: View {
    enum SelectionMode {
        case single
        case multiple
    }
    
    var onSelect: (Exercise) -> Void
    var onSelectMultiple: (([Exercise]) -> Void)?
    
    @State private var searchText = ""
    @State private var selectedMuscleGroup: String? = nil
    @State private var selectedExercises: Set<UUID> = []
    @State private var selectionMode: SelectionMode = .single
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var dataManager: DataManager
    
    // Muscle group filters
    let muscleGroups = ["All", "Chest", "Back", "Shoulders", "Arms", "Legs", "Core"]
    
    // Use this function to access exercises
    var exercises: [Exercise] {
        // If dataManager has exercises, use those
        if !dataManager.exercises.isEmpty {
            return dataManager.exercises
        }
        // Otherwise fall back to the comprehensive list
        // (this ensures the view works even if used in isolation)
        return comprehensiveExerciseList
    }
    
    // Comprehensive strength exercise list as a fallback
    private let comprehensiveExerciseList = [
        // Your existing comprehensive list would be here
        Exercise(
            name: "Bench Press (Barbell)",
            category: "Strength",
            muscleGroups: ["Chest", "Triceps", "Shoulders"],
            instructions: "Lie on a flat bench, grip the bar with hands slightly wider than shoulder-width apart. Lower the bar to your chest, then press back up to starting position."
        )
        // ... rest of your list
    ]
    
    var filteredExercises: [Exercise] {
        // First filter by muscle group
        let muscleGroupFiltered: [Exercise]
        if selectedMuscleGroup == nil || selectedMuscleGroup == "All" {
            muscleGroupFiltered = exercises
        } else if selectedMuscleGroup == "Core" {
            // Special case for Core to include Abdominals
            muscleGroupFiltered = exercises.filter { exercise in
                let muscleGroups = exercise.muscleGroups
                return muscleGroups.contains(selectedMuscleGroup!) || muscleGroups.contains("Abdominals")
            }
        } else {
            // Regular case - just filter by the selected muscle group
            muscleGroupFiltered = exercises.filter { exercise in
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
        bodyContent
    }
    
    // Separate the body content to avoid compiler complexity issues
    private var bodyContent: some View {
        NavigationView {
            VStack {
                selectionModeToggle
                searchBar
                muscleGroupPicker
                exerciseList
                if selectionMode == .multiple && onSelectMultiple != nil {
                    multipleSelectionActions
                }
            }
            .navigationTitle("Select Exercise")
        }
    }
    
    // Break up the body into smaller components
    private var selectionModeToggle: some View {
        Group {
            if onSelectMultiple != nil {
                Picker("Selection Mode", selection: $selectionMode) {
                    Text("Single").tag(SelectionMode.single)
                    Text("Multiple").tag(SelectionMode.multiple)
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding(.horizontal)
                .padding(.top, 10)
            }
        }
    }
    
    private var searchBar: some View {
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
    }
    
    private var muscleGroupPicker: some View {
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
    }
    
    private var exerciseList: some View {
        List {
            ForEach(filteredExercises) { exercise in
                if selectionMode == .multiple && onSelectMultiple != nil {
                    MultipleSelectionRow(
                        exercise: exercise,
                        isSelected: selectedExercises.contains(exercise.id),
                        action: { toggleSelection(exercise) }
                    )
                } else {
                    Button(action: {
                        onSelect(exercise)
                    }) {
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
    }
    
    private var multipleSelectionActions: some View {
        HStack {
            Button(action: {
                // Clear selections
                selectedExercises.removeAll()
            }) {
                Text("Clear")
                    .foregroundColor(.red)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.red.opacity(0.1))
                    .cornerRadius(10)
            }
            
            Button(action: {
                // Add selected exercises
                let selected = filteredExercises.filter { selectedExercises.contains($0.id) }
                onSelectMultiple?(selected)
                dismiss()
            }) {
                Text("Add Selected (\(selectedExercises.count))")
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(selectedExercises.isEmpty ? Color.gray : Color.blue)
                    .cornerRadius(10)
            }
            .disabled(selectedExercises.isEmpty)
        }
        .padding()
    }
    
    private func toggleSelection(_ exercise: Exercise) {
        if selectedExercises.contains(exercise.id) {
            selectedExercises.remove(exercise.id)
        } else {
            selectedExercises.insert(exercise.id)
        }
    }
}

struct MultipleSelectionRow: View {
    var exercise: Exercise
    var isSelected: Bool
    var action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                VStack(alignment: .leading, spacing: 5) {
                    Text(exercise.name)
                        .font(.headline)
                    
                    Text(exercise.muscleGroups.joined(separator: ", "))
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding(.vertical, 5)
                
                Spacer()
                
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(isSelected ? .blue : .gray)
                    .font(.system(size: 22))
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(PlainButtonStyle())
    }
}
