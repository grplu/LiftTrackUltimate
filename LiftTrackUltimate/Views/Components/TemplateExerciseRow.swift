import SwiftUI

struct TemplateExerciseRow: View {
    var exercise: TemplateExercise
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Exercise header
            HStack(spacing: 16) {
                // Exercise icon with circle background
                ZStack {
                    Circle()
                        .fill(Color.blue.opacity(0.2))
                        .frame(width: 40, height: 40)
                    
                    Image(systemName: getIconForMuscleGroup(exercise.exercise.muscleGroups.first ?? ""))
                        .font(.system(size: 16))
                        .foregroundColor(.blue)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(exercise.exercise.name)
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                    
                    // Stats row
                    HStack(spacing: 12) {
                        // Sets
                        HStack(spacing: 4) {
                            Image(systemName: "chart.bar.fill")
                                .font(.system(size: 12))
                                .foregroundColor(.blue.opacity(0.8))
                            
                            Text("\(exercise.targetSets) sets")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                        
                        // Reps
                        if let targetReps = exercise.targetReps {
                            HStack(spacing: 4) {
                                Image(systemName: "repeat")
                                    .font(.system(size: 12))
                                    .foregroundColor(.green.opacity(0.8))
                                
                                Text("\(targetReps) reps")
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                            }
                        }
                        
                        // Weight if available
                        if let targetWeight = exercise.targetWeight {
                            HStack(spacing: 4) {
                                Image(systemName: "scalemass.fill")
                                    .font(.system(size: 12))
                                    .foregroundColor(.orange.opacity(0.8))
                                
                                Text("\(Int(targetWeight))kg")
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                            }
                        }
                    }
                }
                
                Spacer()
            }
            .padding(.vertical, 16)
            .padding(.horizontal, 16)
        }
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemGray6).opacity(0.15))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                )
        )
        .padding(.horizontal)
    }
    
    // Helper function to get icon based on muscle group
    private func getIconForMuscleGroup(_ muscleGroup: String) -> String {
        let muscle = muscleGroup.lowercased()
        
        if muscle.contains("chest") {
            return "heart.fill"
        } else if muscle.contains("back") {
            return "figure.strengthtraining.traditional"
        } else if muscle.contains("shoulder") || muscle.contains("delt") {
            return "person.bust"
        } else if muscle.contains("bicep") || muscle.contains("tricep") || muscle.contains("arm") {
            return "figure.arms.open"
        } else if muscle.contains("core") || muscle.contains("abdominal") {
            return "figure.core.training"
        } else if muscle.contains("leg") || muscle.contains("quad") || muscle.contains("hamstring") {
            return "figure.walk"
        }
        
        return "dumbbell.fill"
    }
} 