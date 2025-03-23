import SwiftUI

struct CustomFinishWorkoutView: View {
    var workout: AppWorkout
    var onCancel: () -> Void
    var onFinish: () -> Void
    @State private var animateIn = false
    
    var body: some View {
        ZStack {
            // Dimmed background
            Color.black.opacity(0.4)
                .edgesIgnoringSafeArea(.all)
                .onTapGesture {
                    dismiss()
                }
            
            // Modal content
            VStack(spacing: 20) {
                // Header with trophy icon
                VStack(spacing: 16) {
                    Image(systemName: "trophy.fill")
                        .font(.system(size: 48))
                        .foregroundColor(.yellow)
                        .opacity(animateIn ? 1.0 : 0.0)
                        .scaleEffect(animateIn ? 1.0 : 0.5)
                    
                    Text("Finish Workout?")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.primary)
                    
                    Text("Great job on your \(workout.name) workout!")
                        .font(.body)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding(.top, 30)
                
                // Workout summary
                VStack(spacing: 12) {
                    summaryRow(icon: "dumbbell.fill", label: "Exercises", value: "\(workout.exercises.count)")
                    
                    summaryRow(icon: "repeat", label: "Sets", value: "\(workout.exercises.reduce(0) { $0 + $1.sets.count })")
                    
                    summaryRow(icon: "timer", label: "Duration", value: formatTime(workout.duration))
                }
                .padding()
                .background(Color(.systemGray6).opacity(0.5))
                .cornerRadius(16)
                
                // Buttons
                HStack(spacing: 16) {
                    // Cancel button
                    Button(action: dismiss) {
                        Text("Cancel")
                            .fontWeight(.medium)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(Color(.systemGray5))
                            .foregroundColor(.primary)
                            .cornerRadius(12)
                    }
                    
                    // Finish button
                    Button(action: {
                        withAnimation(.easeOut(duration: 0.2)) {
                            onFinish()
                        }
                    }) {
                        Text("Finish")
                            .fontWeight(.bold)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(Color.green)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                    }
                }
                .padding(.top, 8)
            }
            .padding(24)
            .background(Color(.systemBackground))
            .cornerRadius(24)
            .shadow(color: Color.black.opacity(0.2), radius: 20, x: 0, y: 10)
            .padding(.horizontal, 24)
            .opacity(animateIn ? 1.0 : 0.0)
            .offset(y: animateIn ? 0 : 30)
        }
        .onAppear {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                animateIn = true
            }
        }
    }
    
    private func dismiss() {
        withAnimation(.easeOut(duration: 0.2)) {
            animateIn = false
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            onCancel()
        }
    }
    
    private func summaryRow(icon: String, label: String, value: String) -> some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.blue)
                .frame(width: 28)
            
            Text(label)
                .foregroundColor(.secondary)
            
            Spacer()
            
            Text(value)
                .fontWeight(.semibold)
        }
    }
    
    private func formatTime(_ timeInterval: TimeInterval) -> String {
        let hours = Int(timeInterval) / 3600
        let minutes = (Int(timeInterval) % 3600) / 60
        
        if hours > 0 {
            return "\(hours) hr \(minutes) min"
        } else {
            return "\(minutes) min"
        }
    }
}
