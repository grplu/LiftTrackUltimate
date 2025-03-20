import SwiftUI

struct WorkoutDetailView: View {
    var workout: AppWorkout
    @State private var showingDeleteAlert = false
    @EnvironmentObject var dataManager: DataManager
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Header section
                VStack(alignment: .leading, spacing: 5) {
                    Text(workout.name)
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    Text(formattedDate(workout.date))
                        .foregroundColor(.secondary)
                    
                    Text(formattedDuration(workout.duration))
                        .foregroundColor(.secondary)
                }
                .padding()
                .background(Color(.systemBackground))
                .cornerRadius(10)
                .shadow(radius: 2)
                .padding(.horizontal)
                
                // Summary stats
                HStack {
                    SummaryStatCard(title: "Exercises", value: "\(workout.exercises.count)", iconName: "dumbbell.fill")
                    SummaryStatCard(title: "Sets", value: "\(workout.exercises.reduce(0) { $0 + $1.sets.count })", iconName: "repeat")
                }
                .padding(.horizontal)
                
                // Exercises section
                Text("Exercises")
                    .font(.headline)
                    .padding(.horizontal)
                
                if workout.exercises.isEmpty {
                    Text("No exercises recorded")
                        .foregroundColor(.secondary)
                        .padding()
                } else {
                    ForEach(workout.exercises) { exercise in
                        ExerciseCard(exercise: exercise)
                    }
                }
                
                // Notes section
                if let notes = workout.notes {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Notes")
                            .font(.headline)
                        
                        Text(notes)
                            .foregroundColor(.secondary)
                    }
                    .padding()
                    .background(Color(.systemBackground))
                    .cornerRadius(10)
                    .shadow(radius: 2)
                    .padding(.horizontal)
                }
            }
        }
        .navigationTitle("Workout Details")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    showingDeleteAlert = true
                }) {
                    Image(systemName: "trash")
                        .foregroundColor(.red)
                }
            }
        }
        .alert("Delete Workout", isPresented: $showingDeleteAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                dataManager.deleteWorkout(workout)
                dismiss()
            }
        } message: {
            Text("Are you sure you want to delete this workout? This action cannot be undone.")
        }
    }
    
    func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
    
    func formattedDuration(_ duration: TimeInterval) -> String {
        let hours = Int(duration) / 3600
        let minutes = (Int(duration) % 3600) / 60
        
        if hours > 0 {
            return "\(hours) hr \(minutes) min"
        } else {
            return "\(minutes) min"
        }
    }
}

struct ExerciseCard: View {
    var exercise: WorkoutExercise
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(exercise.exercise.name)
                .font(.headline)
            
            ForEach(exercise.sets) { set in
                HStack {
                    Text("Set \(exercise.sets.firstIndex(where: { $0.id == set.id })! + 1)")
                    
                    Spacer()
                    
                    if let reps = set.reps {
                        Text("\(reps) reps")
                    }
                    
                    if let weight = set.weight {
                        Text("\(weight, specifier: "%.1f") kg")
                    }
                    
                    Image(systemName: set.completed ? "checkmark.circle.fill" : "circle")
                        .foregroundColor(set.completed ? .green : .gray)
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(10)
        .shadow(radius: 2)
        .padding(.horizontal)
    }
}

struct SummaryStatCard: View {
    var title: String
    var value: String
    var iconName: String
    var color: Color = .blue
    
    var body: some View {
        VStack(spacing: 5) {
            Image(systemName: iconName)
                .font(.title3)
                .foregroundColor(color)
            
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(10)
        .shadow(radius: 2)
    }
}
