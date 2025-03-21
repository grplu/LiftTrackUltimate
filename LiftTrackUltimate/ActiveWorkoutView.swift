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
    @State private var showingExerciseSelection = false
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
                            showingExerciseSelection = true
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
        .sheet(isPresented: $showingExerciseSelection) {
            ExerciseSelectionView { exercise in
                addExerciseToWorkout(exercise)
            }
            .environmentObject(dataManager)
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
                
                // Create sets with individual weights from previous workout
                let totalSets = lastPerformance?.totalSets ?? templateExercise.targetSets
                
                let sets = (0..<totalSets).map { setIndex -> ExerciseSet in
                    let reps = DataManager.shared.getSetReps(for: templateExercise.exercise, setIndex: setIndex) ?? templateExercise.targetReps
                    let weight = DataManager.shared.getSetWeight(for: templateExercise.exercise, setIndex: setIndex)
                    
                    return ExerciseSet(
                        reps: reps,
                        weight: weight
                    )
                }
                
                return WorkoutExercise(
                    exercise: templateExercise.exercise,
                    sets: sets
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
    
    private func addExerciseToWorkout(_ exercise: Exercise) {
        // Try to get last performance
        let lastPerformance = dataManager.getLastPerformance(for: exercise)
        
        // Determine sets and reps
        let totalSets = lastPerformance?.totalSets ?? 3
        let defaultReps = lastPerformance?.lastUsedReps ?? 10
        
        // Create sets with individual weights from previous workout
        let sets = (0..<totalSets).map { setIndex -> ExerciseSet in
            let reps = dataManager.getSetReps(for: exercise, setIndex: setIndex) ?? defaultReps
            let weight = dataManager.getSetWeight(for: exercise, setIndex: setIndex)
            
            return ExerciseSet(
                reps: reps,
                weight: weight
            )
        }
        
        // Create the workout exercise
        let workoutExercise = WorkoutExercise(
            exercise: exercise,
            sets: sets
        )
        
        // Add to workout
        workout.exercises.append(workoutExercise)
    }
    
    private func saveExercisePerformances() {
        for exercise in workout.exercises {
            // Save performance data with individual set data
            dataManager.saveExercisePerformance(from: exercise)
        }
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
        let currentExercise = workout.exercises[exerciseIndex]
        
        // Determine default values based on the last set
        var defaultReps: Int? = 10
        var defaultWeight: Double? = nil
        
        if let lastSet = currentExercise.sets.last, lastSet.completed {
            // If there's a completed set, use those values
            defaultReps = lastSet.reps
            defaultWeight = lastSet.weight
        } else {
            // Try to get values from performance history
            let setIndex = currentExercise.sets.count // Next set index
            defaultReps = dataManager.getSetReps(for: currentExercise.exercise, setIndex: setIndex) ?? 10
            defaultWeight = dataManager.getSetWeight(for: currentExercise.exercise, setIndex: setIndex)
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
