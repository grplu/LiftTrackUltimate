import SwiftUI

struct HistoryView: View {
    @EnvironmentObject var dataManager: DataManager
    
    // Updated from Workout to AppWorkout
    @State private var workouts: [AppWorkout] = [
        AppWorkout(name: "Morning Strength", date: Date().addingTimeInterval(-86400), duration: 3600, exercises: []),
        AppWorkout(name: "Evening Cardio", date: Date().addingTimeInterval(-172800), duration: 1800, exercises: [])
    ]
    
    var body: some View {
        NavigationView {
            List {
                ForEach(workouts) { workout in
                    NavigationLink(destination: WorkoutDetailView(workout: workout)) {
                        WorkoutRow(workout: workout)
                    }
                }
            }
            .navigationTitle("Workout History")
        }
        .onAppear {
            // Load real workouts from DataManager if available
            if !dataManager.workouts.isEmpty {
                workouts = dataManager.workouts
            }
        }
    }
}

struct WorkoutRow: View {
    // Updated from Workout to AppWorkout
    var workout: AppWorkout
    
    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(workout.name)
                .font(.headline)
            
            HStack {
                Text(formattedDate(workout.date))
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Text(formattedDuration(workout.duration))
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 5)
    }
    
    func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
    
    func formattedDuration(_ duration: TimeInterval) -> String {
        let minutes = Int(duration) / 60
        return "\(minutes) min"
    }
}
