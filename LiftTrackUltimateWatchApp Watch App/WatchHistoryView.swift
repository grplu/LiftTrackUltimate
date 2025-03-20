import SwiftUI

// Add this mini model at the top of the file
struct Workout: Identifiable {
    var id = UUID()
    var name: String
    var date: Date
    var duration: TimeInterval
    var exercises: [Any] // Using [Any] to simplify for the Watch app
}

struct WatchHistoryView: View {
    // Sample data
    let recentWorkouts = [
        Workout(name: "Morning Strength", date: Date().addingTimeInterval(-86400), duration: 3600, exercises: []),
        Workout(name: "Evening Cardio", date: Date().addingTimeInterval(-172800), duration: 1800, exercises: [])
    ]
    
    var body: some View {
        List {
            ForEach(recentWorkouts) { workout in
                VStack(alignment: .leading) {
                    Text(workout.name)
                        .font(.headline)
                    
                    Text(formattedDate(workout.date))
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text(formattedDuration(workout.duration))
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding(.vertical, 5)
            }
        }
        .navigationTitle("History")
    }
    
    func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        return formatter.string(from: date)
    }
    
    func formattedDuration(_ duration: TimeInterval) -> String {
        let minutes = Int(duration) / 60
        return "\(minutes) min"
    }
}
