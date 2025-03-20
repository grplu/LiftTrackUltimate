import SwiftUI

struct ExerciseDetailView: View {
    var exercise: Exercise
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Header section
                VStack(alignment: .leading, spacing: 5) {
                    Text(exercise.name)
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    Text(exercise.category)
                        .font(.headline)
                        .foregroundColor(.secondary)
                }
                .padding()
                
                // Muscles targeted
                VStack(alignment: .leading, spacing: 10) {
                    Text("Muscles Targeted")
                        .font(.headline)
                    
                    HStack {
                        ForEach(exercise.muscleGroups, id: \.self) { muscle in
                            Text(muscle)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(Color.blue.opacity(0.1))
                                .foregroundColor(.blue)
                                .cornerRadius(20)
                        }
                    }
                }
                .padding()
                
                // Instructions
                if let instructions = exercise.instructions {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Instructions")
                            .font(.headline)
                        
                        Text(instructions)
                            .foregroundColor(.secondary)
                    }
                    .padding()
                } else {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Instructions")
                            .font(.headline)
                        
                        Text("No detailed instructions available for this exercise.")
                            .foregroundColor(.secondary)
                    }
                    .padding()
                }
            }
        }
        .navigationTitle("Exercise Details")
        .navigationBarTitleDisplayMode(.inline)
    }
}
