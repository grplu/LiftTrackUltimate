import SwiftUI

struct WorkoutExerciseCard: View {
    @Binding var exercise: WorkoutExercise
    var onAddSet: () -> Void
    @EnvironmentObject var dataManager: DataManager
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Exercise name and muscle groups
            VStack(alignment: .leading, spacing: 4) {
                Text(exercise.exercise.name)
                    .font(.headline)
                
                Text(exercise.exercise.muscleGroups.joined(separator: ", "))
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(.top, 8)
            
            // Column headers
            HStack {
                Text("Set")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.secondary)
                    .frame(width: 40, alignment: .center)
                
                Text("Last Time")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.secondary)
                    .frame(minWidth: 90, alignment: .leading)
                    .padding(.leading, 4)
                
                Spacer()
                
                Text("kg")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.secondary)
                    .frame(width: 50, alignment: .center)
                
                Text("Reps")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.secondary)
                    .frame(width: 50, alignment: .center)
                
                Text("Done")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.secondary)
                    .frame(width: 40, alignment: .center)
            }
            .padding(.horizontal, 4)
            .padding(.top, 4)
            
            // Sets
            ForEach(exercise.sets.indices, id: \.self) { setIndex in
                HStack {
                    // Set number
                    Text("\(setIndex + 1)")
                        .font(.system(size: 16, weight: .medium))
                        .frame(width: 40, alignment: .center)
                    
                    // Last time info
                    Text(getLastTimeInfo(for: exercise.exercise, setIndex: setIndex))
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                        .frame(minWidth: 90, alignment: .leading)
                        .padding(.leading, 4)
                    
                    Spacer()
                    
                    // Weight input
                    TextField("0", value: $exercise.sets[setIndex].weight, format: .number)
                        .keyboardType(.decimalPad)
                        .multilineTextAlignment(.center)
                        .font(.system(size: 16))
                        .frame(width: 50)
                        .padding(6)
                        .background(Color(.systemGray6))
                        .cornerRadius(8)
                    
                    // Reps input
                    TextField("0", value: $exercise.sets[setIndex].reps, format: .number)
                        .keyboardType(.numberPad)
                        .multilineTextAlignment(.center)
                        .font(.system(size: 16))
                        .frame(width: 50)
                        .padding(6)
                        .background(Color(.systemGray6))
                        .cornerRadius(8)
                    
                    // Completed toggle
                    Button(action: {
                        exercise.sets[setIndex].completed.toggle()
                    }) {
                        Image(systemName: exercise.sets[setIndex].completed ? "checkmark.circle.fill" : "circle")
                            .font(.system(size: 22))
                            .foregroundColor(exercise.sets[setIndex].completed ? .green : .gray)
                    }
                    .buttonStyle(BorderlessButtonStyle())
                    .frame(width: 40, alignment: .center)
                }
                .padding(.vertical, 6)
            }
            
            // Add set button
            Button(action: onAddSet) {
                HStack {
                    Image(systemName: "plus.circle")
                    Text("Add Set")
                        .font(.system(size: 14, weight: .medium))
                }
                .foregroundColor(.blue)
                .padding(.vertical, 8)
                .frame(maxWidth: .infinity)
                .background(Color.blue.opacity(0.1))
                .cornerRadius(8)
            }
            .buttonStyle(BorderlessButtonStyle())
            .padding(.top, 4)
        }
        .padding()
        .background(Color(.systemGray6).opacity(0.3))
        .cornerRadius(12)
    }
    
    // Helper function to get last time performance info
    private func getLastTimeInfo(for exercise: Exercise, setIndex: Int) -> String {
        if let weight = dataManager.getSetWeight(for: exercise, setIndex: setIndex),
           let reps = dataManager.getSetReps(for: exercise, setIndex: setIndex) {
            return "\(String(format: "%.1f", weight)) kg × \(reps)"
        } else {
            return "No previous data"
        }
    }
}
