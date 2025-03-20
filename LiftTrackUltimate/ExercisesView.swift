import SwiftUI

struct ExercisesView: View {
    @State private var searchText = ""
    @EnvironmentObject var dataManager: DataManager
    
    // Category headers
    let categories = ["Strength"]
    
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
                
                // Exercises list by category
                List {
                    ForEach(categories, id: \.self) { category in
                        Section(header: Text(category)) {
                            ForEach(filteredExercises(category: category)) { exercise in
                                NavigationLink(destination: ExerciseDetailView(exercise: exercise)) {
                                    ExerciseRow(exercise: exercise)
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("Exercises")
            .toolbar {
                Button(action: {
                    // Add custom exercise
                }) {
                    Image(systemName: "plus")
                }
            }
            .onAppear {
                // Make sure our dataManager has the comprehensive exercise list
                if dataManager.exercises.count < 10 {
                    dataManager.updateExercises(ExerciseSelectionView(onSelect: {_ in }).exercises)
                }
            }
        }
    }
    
    func filteredExercises(category: String) -> [Exercise] {
        let categoryExercises = dataManager.exercises.filter { $0.category == category }
        
        if searchText.isEmpty {
            return categoryExercises
        } else {
            return categoryExercises.filter {
                $0.name.lowercased().contains(searchText.lowercased()) ||
                $0.muscleGroups.joined(separator: " ").lowercased().contains(searchText.lowercased())
            }
        }
    }
}

struct ExerciseRow: View {
    var exercise: Exercise
    
    var body: some View {
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
