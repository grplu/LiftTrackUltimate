import SwiftUI

struct ActiveWorkoutView: View {
    var template: WorkoutTemplate?
    var onEnd: () -> Void
    
    @State private var workout: AppWorkout
    @State private var elapsedTime: TimeInterval = 0
    @State private var timer: Timer? = nil
    @State private var isShowingNotes = false
    @State private var notes = ""
    @EnvironmentObject var dataManager: DataManager
    
    init(template: WorkoutTemplate?, onEnd: @escaping () -> Void) {
        self.template = template
        self.onEnd = onEnd
        
        // Initialize workout from template or empty
        let initialWorkout: AppWorkout
        if let template = template {
            // Create workout exercises from template
            let workoutExercises = template.exercises.map { templateExercise in
                return WorkoutExercise(
                    exercise: templateExercise.exercise,
                    sets: (0..<templateExercise.targetSets).map { _ in
                        ExerciseSet(reps: templateExercise.targetReps)
                    }
                )
            }
            
            initialWorkout = AppWorkout(
                id: UUID(),
                name: template.name,
                date: Date(),
                duration: 0,
                exercises: workoutExercises,
                notes: ""
            )
        } else {
            // Empty workout
            initialWorkout = AppWorkout(
                id: UUID(),
                name: "Workout",
                date: Date(),
                duration: 0,
                exercises: [],
                notes: ""
            )
        }
        
        self._workout = State(initialValue: initialWorkout)
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // Workout header
                HStack {
                    TextField("Workout Name", text: $workout.name)
                        .font(.title)
                        .fontWeight(.bold)
                    
                    Spacer()
                    
                    Text(formatTime(elapsedTime))
                        .font(.system(size: 24, weight: .semibold, design: .monospaced))
                        .foregroundColor(.secondary)
                }
                .padding(.horizontal)
                
                // Exercise cards
                ForEach($workout.exercises.indices, id: \.self) { exerciseIndex in
                    WorkoutExerciseCard(
                        exercise: $workout.exercises[exerciseIndex],
                        onAddSet: {
                            addSet(to: exerciseIndex)
                        }
                    )
                    .padding(.horizontal)
                    .background(Color(.systemBackground))
                    .cornerRadius(12)
                    .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
                }
                
                // Add exercise button
                Button(action: {
                    // Show exercise selection
                }) {
                    HStack {
                        Image(systemName: "plus.circle.fill")
                        Text("Add Exercise")
                            .fontWeight(.semibold)
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue.opacity(0.1))
                    .foregroundColor(.blue)
                    .cornerRadius(10)
                }
                .padding(.horizontal)
                
                // Finish workout button
                Button(action: {
                    finishWorkout()
                }) {
                    Text("Finish Workout")
                        .fontWeight(.semibold)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .padding(.horizontal)
            }
            .padding(.vertical)
        }
        .navigationBarTitle("", displayMode: .inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    isShowingNotes = true
                }) {
                    Image(systemName: "note.text")
                }
            }
        }
        .sheet(isPresented: $isShowingNotes) {
            NavigationView {
                TextEditor(text: $notes)
                    .padding()
                    .navigationTitle("Workout Notes")
                    .toolbar {
                        ToolbarItem(placement: .navigationBarTrailing) {
                            Button("Done") {
                                isShowingNotes = false
                            }
                        }
                    }
            }
        }
        .onAppear {
            startTimer()
        }
        .onDisappear {
            stopTimer()
        }
    }
    
    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            elapsedTime += 1
        }
    }
    
    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    private func addSet(to exerciseIndex: Int) {
        // Get the existing reps value from the last set, if available
        let defaultReps: Int?
        if let lastSet = workout.exercises[exerciseIndex].sets.last {
            defaultReps = lastSet.reps
        } else {
            defaultReps = 10 // Default value if no previous set
        }
        
        // Add a new set
        workout.exercises[exerciseIndex].sets.append(
            ExerciseSet(reps: defaultReps)
        )
    }
    
    private func finishWorkout() {
        // Update workout with final details
        workout.duration = elapsedTime
        workout.notes = notes
        
        // Save the workout
        dataManager.saveWorkout(workout)
        
        // Call the onEnd callback
        onEnd()
    }
    
    private func formatTime(_ timeInterval: TimeInterval) -> String {
        let hours = Int(timeInterval) / 3600
        let minutes = (Int(timeInterval) % 3600) / 60
        let seconds = Int(timeInterval) % 60
        
        return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }
}
