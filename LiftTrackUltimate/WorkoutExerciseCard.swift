import SwiftUI

struct WorkoutExerciseCard: View {
    @Binding var exercise: WorkoutExercise
    var onAddSet: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(exercise.exercise.name)
                .font(.headline)
                .padding(.top, 8)
            
            // Sets
            ForEach(exercise.sets.indices, id: \.self) { setIndex in
                HStack {
                    Text("Set \(setIndex + 1)")
                        .font(.subheadline)
                        .frame(width: 50, alignment: .leading)
                    
                    // Reps input
                    TextField("10", value: $exercise.sets[setIndex].reps, format: .number)
                        .keyboardType(.numberPad)
                        .multilineTextAlignment(.center)
                        .frame(width: 50)
                        .padding(8)
                        .background(Color(.systemGray6))
                        .cornerRadius(8)
                    
                    // Weight input (if needed)
                    TextField("kg", value: $exercise.sets[setIndex].weight, format: .number)
                        .keyboardType(.decimalPad)
                        .multilineTextAlignment(.center)
                        .frame(width: 50)
                        .padding(8)
                        .background(Color(.systemGray6))
                        .cornerRadius(8)
                    
                    Spacer()
                    
                    // Completed toggle - Using button with BorderlessButtonStyle
                    Button(action: {
                        var updatedSets = exercise.sets
                        updatedSets[setIndex].completed.toggle()  // Using completed instead of isCompleted
                        exercise.sets = updatedSets
                    }) {
                        Image(systemName: exercise.sets[setIndex].completed ? "checkmark.circle.fill" : "circle")
                            .font(.system(size: 22))
                            .foregroundColor(exercise.sets[setIndex].completed ? .green : .gray)
                    }
                    .buttonStyle(BorderlessButtonStyle()) // This is crucial for proper response
                }
                .padding(.vertical, 4)
            }
            
            // Add set button
            Button(action: onAddSet) {
                HStack {
                    Image(systemName: "plus")
                    Text("Add Set")
                        .font(.system(size: 14, weight: .medium))
                }
                .foregroundColor(.blue)
                .padding(.top, 4)
            }
            .buttonStyle(BorderlessButtonStyle()) // This is crucial for proper response
            .padding(.bottom, 8)
        }
        .padding()
        .background(Color(.systemGray6).opacity(0.5))
        .cornerRadius(12)
    }
}
