import SwiftUI

struct ActiveWorkoutView: View {
    var template: WorkoutTemplate?
    var onEnd: () -> Void
    
    @State private var workout: AppWorkout
    @State private var elapsedTime: TimeInterval = 0
    @State private var timer: Timer? = nil
    @State private var isShowingNotes = false
    @State private var notes = ""
    @State private var showFinishConfirmation = false
    @State private var addExerciseButtonScale: CGFloat = 1.0
    @State private var finishWorkoutButtonScale: CGFloat = 1.0
    @EnvironmentObject var dataManager: DataManager
    
    // Conforming to View protocol by adding body
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
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.5)) {
                        addExerciseButtonScale = 1.2
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.5)) {
                            addExerciseButtonScale = 1.0
                            // Add your exercise selection logic here
                        }
                    }
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
                    .scaleEffect(addExerciseButtonScale)
                }
                .padding(.horizontal)
                
                // Finish workout button
                Button(action: {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.5)) {
                        finishWorkoutButtonScale = 1.2
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.5)) {
                            finishWorkoutButtonScale = 1.0
                            finishWorkout()
                        }
                    }
                }) {
                    Text("Finish Workout")
                        .fontWeight(.semibold)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        .scaleEffect(finishWorkoutButtonScale)
                }
                .padding(.horizontal)
            }
            .padding(.vertical)
        }
        .navigationBarTitle("Workout", displayMode: .inline)
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
        .alert("Finish Workout?", isPresented: $showFinishConfirmation) {
            Button("Cancel", role: .cancel) {
                // Do nothing, just dismiss the alert
            }
            Button("Finish", role: .destructive) {
                // Save exercise performances
                saveExercisePerformances()
                
                // Proceed with finishing the workout
                workout.duration = elapsedTime
                workout.notes = notes
                dataManager.saveWorkout(workout)
                onEnd() // Call the onEnd callback
            }
        } message: {
            Text("Are you sure you want to finish this workout?")
        }
    }
    
    init(template: WorkoutTemplate?, onEnd: @escaping () -> Void) {
        self.template = template
        self.onEnd = onEnd
        
        // Initialize workout from template or empty
        let initialWorkout: AppWorkout
        if let template = template {
            let workoutExercises = template.exercises.map { templateExercise in
                // Try to get last performance or use template defaults
                let lastPerformance = DataManager.shared.getLastPerformance(for: templateExercise.exercise)
                
                return WorkoutExercise(
                    exercise: templateExercise.exercise,
                    sets: (0..<(lastPerformance?.totalSets ?? templateExercise.targetSets)).map { _ in
                        ExerciseSet(
                            reps: lastPerformance?.lastUsedReps ?? templateExercise.targetReps,
                            weight: lastPerformance?.lastUsedWeight
                        )
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
    
    // Remaining methods (saveExercisePerformances, calculateAveragePerformance, etc.)
    // should be added here, similar to the previous implementation
    
    private func saveExercisePerformances() {
        for exercise in workout.exercises {
            // Calculate average reps, sets, and weight
            let (avgReps, avgWeight, totalSets) = calculateAveragePerformance(for: exercise)
            
            // Create performance record
            let performance = ExercisePerformance(
                exerciseId: exercise.exercise.id,
                reps: avgReps,
                weight: avgWeight,
                sets: totalSets
            )
            
            // Save to DataManager
            dataManager.saveExercisePerformance(performance)
        }
    }
    
    private func calculateAveragePerformance(for workoutExercise: WorkoutExercise) -> (reps: Int, weight: Double?, sets: Int) {
        // If no sets, return default values
        guard !workoutExercise.sets.isEmpty else {
            return (10, nil, 3)
        }
        
        // Calculate average reps
        let repsValues = workoutExercise.sets.compactMap { $0.reps }
        let avgReps = repsValues.isEmpty ? 10 : Int(Double(repsValues.reduce(0, +)) / Double(repsValues.count))
        
        // Calculate average weight
        let weightValues = workoutExercise.sets.compactMap { $0.weight }
        let avgWeight = weightValues.isEmpty ? nil : weightValues.reduce(0, +) / Double(weightValues.count)
        
        // Total sets
        let totalSets = workoutExercise.sets.count
        
        return (reps: avgReps, weight: avgWeight, sets: totalSets)
    }
    
    private func finishWorkout() {
        showFinishConfirmation = true
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
        let defaultWeight: Double?
        
        if let lastSet = workout.exercises[exerciseIndex].sets.last {
            defaultReps = lastSet.reps
            defaultWeight = lastSet.weight
        } else {
            // Try to get from last performance
            let lastPerformance = DataManager.shared.getLastPerformance(for: workout.exercises[exerciseIndex].exercise)
            defaultReps = lastPerformance?.lastUsedReps ?? 10
            defaultWeight = lastPerformance?.lastUsedWeight
        }
        
        // Add a new set
        workout.exercises[exerciseIndex].sets.append(
            ExerciseSet(reps: defaultReps, weight: defaultWeight)
        )
    }
    
    private func formatTime(_ timeInterval: TimeInterval) -> String {
        let hours = Int(timeInterval) / 3600
        let minutes = (Int(timeInterval) % 3600) / 60
        let seconds = Int(timeInterval) % 60
        
        return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }
}
