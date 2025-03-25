import SwiftUI

struct ActiveWorkoutView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var dataManager: DataManager
    
    var template: WorkoutTemplate?
    var onEnd: () -> Void
    
    @State private var workoutName: String
    @State private var exercises: [WorkoutExercise] = []
    @State private var startTime = Date()
    @State private var elapsedTime: TimeInterval = 0
    @State private var timer: Timer? = nil
    @State private var showingFinishAlert = false
    @State private var showingExerciseSelection = false
    @State private var heartRate: Int = Int.random(in: 65...85) // Mock heart rate
    @State private var isTimerPaused: Bool = false
    @State private var showingCompletionAnimation = false
    
    // For keyboard dismissal
    @FocusState private var focusedField: String?
    
    // Timer for heart rate simulation
    @State private var heartRateTimer: Timer? = nil
    
    init(template: WorkoutTemplate?, onEnd: @escaping () -> Void) {
        self.template = template
        self.onEnd = onEnd
        _workoutName = State(initialValue: template?.name ?? "Quick Workout")
    }
    
    var body: some View {
        ZStack {
            // Background color
            Color.black.edgesIgnoringSafeArea(.all)
            
            // Content area
            ScrollView {
                VStack(spacing: 24) {
                    // Custom navigation bar
                    HStack {
                        Button(action: {
                            showingFinishAlert = true
                        }) {
                            HStack(spacing: 6) {
                                Image(systemName: "chevron.left")
                                Text("Back")
                            }
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.blue)
                        }
                        
                        Spacer()
                        
                        // Removed the three dots menu button
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 12)
                    
                    // Workout header
                    VStack(spacing: 16) {
                        // Editable workout name
                        TextField("Workout Name", text: $workoutName)
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                            .padding(.top, 8)
                            .focused($focusedField, equals: "workoutName")
                        
                        // Timer and heart rate
                        HStack(spacing: 20) {
                            // Timer display
                            HStack {
                                TimerDisplay(elapsedTime: elapsedTime)
                                
                                // Play/pause button
                                Button(action: {
                                    toggleTimerPause()
                                }) {
                                    ZStack {
                                        Circle()
                                            .fill(Color.blue.opacity(0.2))
                                            .frame(width: 50, height: 50)
                                        
                                        Image(systemName: isTimerPaused ? "play.fill" : "pause.fill")
                                            .font(.system(size: 20))
                                            .foregroundColor(.blue)
                                    }
                                }
                            }
                            
                            // Heart rate display
                            HeartRateDisplay(heartRate: heartRate)
                        }
                        .padding(.vertical, 8)
                    }
                    .padding(.horizontal)
                    
                    // Exercise cards - always expanded
                    ForEach(exercises) { exercise in
                        ExerciseCard(
                            exercise: exercise,
                            onSetComplete: { setIndex, isComplete in
                                toggleSetCompletion(for: exercise, setIndex: setIndex, isComplete: isComplete)
                            },
                            onAddSet: {
                                addSet(to: exercise)
                            },
                            onUpdateWeight: { setIndex, weight in
                                updateWeight(for: exercise, setIndex: setIndex, weight: weight)
                            },
                            onUpdateReps: { setIndex, reps in
                                updateReps(for: exercise, setIndex: setIndex, reps: reps)
                            },
                            dataManager: dataManager,
                            focusedField: $focusedField,
                            exerciseId: exercise.id.uuidString
                        )
                    }
                    
                    // Add exercise button
                    Button(action: {
                        dismissKeyboard()
                        showingExerciseSelection = true
                    }) {
                        HStack {
                            Image(systemName: "plus.circle.fill")
                                .font(.system(size: 20))
                            
                            Text("Add Exercise")
                                .font(.system(size: 16, weight: .semibold))
                        }
                        .foregroundColor(.blue)
                        .padding(.vertical, 16)
                        .frame(maxWidth: .infinity)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color.blue.opacity(0.1))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16)
                                        .stroke(Color.blue.opacity(0.3), lineWidth: 1)
                                )
                        )
                        .padding(.horizontal)
                    }
                    
                    // Action buttons
                    VStack(spacing: 16) {
                        // Complete workout button
                        Button(action: {
                            dismissKeyboard()
                            completeWorkout()
                        }) {
                            Text("Complete Workout")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(.white)
                                .padding(.vertical, 16)
                                .frame(maxWidth: .infinity)
                                .background(
                                    RoundedRectangle(cornerRadius: 16)
                                        .fill(Color.green)
                                )
                                .padding(.horizontal)
                        }
                        
                        // Cancel workout button
                        Button(action: {
                            dismissKeyboard()
                            showingFinishAlert = true
                        }) {
                            Text("Cancel Workout")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.white)
                                .padding(.vertical, 16)
                                .frame(maxWidth: .infinity)
                                .background(
                                    RoundedRectangle(cornerRadius: 16)
                                        .fill(Color.red)
                                )
                                .padding(.horizontal)
                        }
                    }
                    
                    // Extra padding at bottom for safe area
                    Spacer().frame(height: 40)
                }
                .padding(.top, 16)
            }
            // Add background tap gesture to dismiss keyboard
            .contentShape(Rectangle())
            .onTapGesture {
                dismissKeyboard()
            }
            
            // Completion animation overlay
            if showingCompletionAnimation {
                WorkoutCompletionAnimation()
            }
        }
        .navigationBarHidden(true)
        .sheet(isPresented: $showingFinishAlert) {
            ZStack {
                Color.black.opacity(0.9).edgesIgnoringSafeArea(.all)
                
                VStack(spacing: 24) {
                    // Icon - using timer.badge.exclamationmark which fits the workout theme better
                    Image(systemName: "timer.badge.exclamationmark")
                        .font(.system(size: 40))
                        .foregroundColor(.white)
                        .padding(.top, 24)
                    
                    // Alert message
                    Text("End workout without saving progress?")
                        .font(.system(size: 20, weight: .medium))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 30)
                        .fixedSize(horizontal: false, vertical: true)
                    
                    Spacer()
                    
                    // Continue button with blue accent
                    Button(action: {
                        showingFinishAlert = false
                    }) {
                        Text("Continue Workout")
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundColor(.blue)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(
                                RoundedRectangle(cornerRadius: 14)
                                    .fill(Color.blue.opacity(0.15))
                            )
                    }
                    .padding(.horizontal, 24)
                    
                    // Discard button with destructive styling
                    Button(action: {
                        showingFinishAlert = false
                        onEnd()
                        dismiss()
                    }) {
                        Text("Discard Workout")
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundColor(.red)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(
                                RoundedRectangle(cornerRadius: 14)
                                    .fill(Color.red.opacity(0.15))
                            )
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 24)
                }
                .frame(width: 320, height: 300)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color(.systemGray6).opacity(0.95))
                        .shadow(color: Color.black.opacity(0.2), radius: 20)
                )
                .transition(.scale)
            }
            .background(BackgroundClearView())
        }
        .sheet(isPresented: $showingExerciseSelection) {
            ExerciseSelectionView { exercise in
                addExercise(exercise)
            }
            .environmentObject(dataManager)
        }
        .onAppear {
            UITextField.appearance().tintColor = .white // Set cursor color to white
            initializeWorkout()
            startTimer()
            startHeartRateSimulation()
        }
        .onDisappear {
            stopTimer()
            stopHeartRateSimulation()
        }
    }
    
    // Helper to dismiss keyboard
    private func dismissKeyboard() {
        focusedField = nil
    }
    
    // Helper to initialize workout from template
    private func initializeWorkout() {
        guard let template = template else { return }
        
        // Create workout exercises from template
        for templateExercise in template.exercises {
            var exerciseSets: [ExerciseSet] = []
            
            for _ in 0..<templateExercise.targetSets {
                // Use default reps if not set
                let reps = templateExercise.targetReps ?? 10
                
                // Get last weight used for this exercise if available
                let lastPerformance = dataManager.getLastPerformance(for: templateExercise.exercise)
                let weight = lastPerformance?.lastUsedWeight
                
                // Create a new set with the values
                let newSet = ExerciseSet(reps: reps, weight: weight)
                exerciseSets.append(newSet)
            }
            
            let workoutExercise = WorkoutExercise(exercise: templateExercise.exercise, sets: exerciseSets)
            exercises.append(workoutExercise)
        }
    }
    
    // Timer functions
    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            if !isTimerPaused {
                elapsedTime += 1.0
            }
        }
    }
    
    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    private func toggleTimerPause() {
        isTimerPaused.toggle()
    }
    
    // Heart rate simulation
    private func startHeartRateSimulation() {
        heartRateTimer = Timer.scheduledTimer(withTimeInterval: 3.0, repeats: true) { _ in
            // Simulate slight heart rate changes
            heartRate = max(60, min(180, heartRate + Int.random(in: -3...5)))
        }
    }
    
    private func stopHeartRateSimulation() {
        heartRateTimer?.invalidate()
        heartRateTimer = nil
    }
    
    // Exercise management functions
    private func addExercise(_ exercise: Exercise) {
        // Default to 3 sets of 10 reps
        let sets = [
            ExerciseSet(reps: 10, weight: nil),
            ExerciseSet(reps: 10, weight: nil),
            ExerciseSet(reps: 10, weight: nil)
        ]
        
        let workoutExercise = WorkoutExercise(exercise: exercise, sets: sets)
        exercises.append(workoutExercise)
    }
    
    private func addSet(to exercise: WorkoutExercise) {
        if let index = exercises.firstIndex(where: { $0.id == exercise.id }) {
            // Get the last set (if any)
            let lastSet = exercises[index].sets.last
            
            // Create new set with simple parameters
            let reps = lastSet?.reps ?? 10
            let weight = lastSet?.weight
            
            // Create new set with correct parameter order
            let newSet = ExerciseSet(reps: reps, weight: weight)
            
            exercises[index].sets.append(newSet)
        }
    }
    
    private func toggleSetCompletion(for exercise: WorkoutExercise, setIndex: Int, isComplete: Bool) {
        if let exerciseIndex = exercises.firstIndex(where: { $0.id == exercise.id }),
           setIndex < exercises[exerciseIndex].sets.count {
            exercises[exerciseIndex].sets[setIndex].completed = isComplete
        }
    }
    
    private func updateWeight(for exercise: WorkoutExercise, setIndex: Int, weight: Double?) {
        if let exerciseIndex = exercises.firstIndex(where: { $0.id == exercise.id }),
           setIndex < exercises[exerciseIndex].sets.count {
            exercises[exerciseIndex].sets[setIndex].weight = weight
        }
    }
    
    private func updateReps(for exercise: WorkoutExercise, setIndex: Int, reps: Int?) {
        if let exerciseIndex = exercises.firstIndex(where: { $0.id == exercise.id }),
           setIndex < exercises[exerciseIndex].sets.count {
            exercises[exerciseIndex].sets[setIndex].reps = reps
        }
    }
    
    private func completeWorkout() {
        // Create and save the completed workout
        let completedWorkout = AppWorkout(
            id: UUID(),
            name: workoutName,
            date: startTime,
            duration: elapsedTime,
            exercises: exercises
        )
        
        dataManager.saveWorkout(completedWorkout)
        
        // Save performance data for each exercise
        for exercise in exercises {
            dataManager.saveExercisePerformance(from: exercise)
        }
        
        // Show completion animation
        showingCompletionAnimation = true
        
        // Short delay to allow animation to play, then dismiss
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
            showingCompletionAnimation = false
            
            // After animation is hidden, dismiss the view
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                onEnd()
                dismiss()
            }
        }
    }
    
    private func cancelWorkout() {
        // Discard the workout without saving
        onEnd()
        dismiss()
    }
}

// Helper view to make sheet background transparent
struct BackgroundClearView: UIViewRepresentable {
    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        DispatchQueue.main.async {
            view.superview?.superview?.backgroundColor = .clear
        }
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {}
}

// Workout Completion Animation
struct WorkoutCompletionAnimation: View {
    @State private var scale: CGFloat = 0.8
    @State private var opacity: Double = 0
    @State private var pulsate: Bool = false
    
    var body: some View {
        ZStack {
            // Semi-transparent background
            Color.black.opacity(0.5)
                .edgesIgnoringSafeArea(.all)
            
            // Simple success message
            VStack(spacing: 16) {
                // Success icon
                ZStack {
                    Circle()
                        .fill(Color.green)
                        .frame(width: 80, height: 80)
                        .opacity(pulsate ? 0.8 : 1.0)
                        .scaleEffect(pulsate ? 1.05 : 1.0)
                    
                    Image(systemName: "checkmark")
                        .font(.system(size: 40, weight: .bold))
                        .foregroundColor(.white)
                }
                
                Text("Workout Complete!")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(.white)
            }
            .padding(30)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color(.systemGray6).opacity(0.9))
            )
            .scaleEffect(scale)
            .opacity(opacity)
        }
        .onAppear {
            // Simple fade in and subtle scale animation
            withAnimation(.easeInOut(duration: 0.3)) {
                scale = 1.0
                opacity = 1.0
            }
            
            // Subtle pulse effect
            withAnimation(Animation.easeInOut(duration: 0.8).repeatCount(2, autoreverses: true)) {
                pulsate = true
            }
        }
    }
}

// MARK: - Supporting Views

struct TimerDisplay: View {
    var elapsedTime: TimeInterval
    
    var formattedTime: String {
        let hours = Int(elapsedTime) / 3600
        let minutes = (Int(elapsedTime) % 3600) / 60
        let seconds = Int(elapsedTime) % 60
        return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }
    
    var body: some View {
        Text(formattedTime)
            .font(.system(size: 32, weight: .semibold, design: .monospaced))
            .foregroundColor(.white)
    }
}

struct HeartRateDisplay: View {
    var heartRate: Int
    
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "heart.fill")
                .foregroundColor(.red)
                .font(.system(size: 18))
            
            Text("\(heartRate)")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.white)
            
            Text("BPM")
                .font(.system(size: 14))
                .foregroundColor(.gray)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.red.opacity(0.15))
        )
    }
}

// Always expanded exercise card
struct ExerciseCard: View {
    var exercise: WorkoutExercise
    var onSetComplete: (Int, Bool) -> Void
    var onAddSet: () -> Void
    var onUpdateWeight: (Int, Double?) -> Void
    var onUpdateReps: (Int, Int?) -> Void
    var dataManager: DataManager
    var focusedField: FocusState<String?>.Binding
    var exerciseId: String
    
    var body: some View {
        VStack(spacing: 0) {
            // Exercise header
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(exercise.exercise.name)
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.white)
                    
                    Text(exercise.exercise.muscleGroups.joined(separator: ", "))
                        .font(.system(size: 14))
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
                // Completion indicator
                let completedSets = exercise.sets.filter { $0.completed }.count
                let totalSets = exercise.sets.count
                
                if completedSets > 0 {
                    Text("\(completedSets)/\(totalSets)")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(completedSets == totalSets ? .green : .orange)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(
                            Capsule()
                                .fill(
                                    (completedSets == totalSets ? Color.green : Color.orange)
                                        .opacity(0.15)
                                )
                        )
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 20)
            
            // Table header
            HStack {
                Text("Set")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.gray)
                    .frame(width: 40, alignment: .center)
                
                Text("Last Time")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.gray)
                    .frame(width: 80, alignment: .center)
                
                Text("kg")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.gray)
                    .frame(width: 70, alignment: .center)
                
                Text("Reps")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.gray)
                    .frame(width: 70, alignment: .center)
                
                Text("Done")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.gray)
                    .frame(width: 60, alignment: .center)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 10)
            
            // Sets rows
            ForEach(Array(exercise.sets.enumerated()), id: \.element.id) { index, set in
                DetailedSetRow(
                    setNumber: index + 1,
                    lastTimeText: getLastTimeText(for: exercise.exercise, setIndex: index),
                    currentWeight: set.weight,
                    currentReps: set.reps,
                    isCompleted: set.completed,
                    onToggleComplete: { isComplete in
                        onSetComplete(index, isComplete)
                    },
                    onUpdateWeight: { weight in
                        onUpdateWeight(index, weight)
                    },
                    onUpdateReps: { reps in
                        onUpdateReps(index, reps)
                    },
                    focusedField: focusedField,
                    weightFieldId: "\(exerciseId)_weight_\(index)",
                    repsFieldId: "\(exerciseId)_reps_\(index)"
                )
                
                Divider()
                    .background(Color.gray.opacity(0.2))
                    .padding(.horizontal, 20)
            }
            
            // Add Set button
            Button(action: onAddSet) {
                HStack {
                    Image(systemName: "plus.circle.fill")
                        .foregroundColor(.blue)
                    
                    Text("Add Set")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.blue)
                }
                .padding(.vertical, 16)
                .frame(maxWidth: .infinity)
            }
            .buttonStyle(PlainButtonStyle())
            .padding(.top, 8)
            .padding(.bottom, 16)
        }
        .background(
            RoundedRectangle(cornerRadius: 18)
                .fill(Color(.systemGray6).opacity(0.2))
                .overlay(
                    RoundedRectangle(cornerRadius: 18)
                        .stroke(Color.white.opacity(0.05), lineWidth: 1)
                )
        )
        .padding(.horizontal)
    }
    
    // Helper to format last time text
    private func getLastTimeText(for exercise: Exercise, setIndex: Int) -> String {
        let lastPerformance = dataManager.getLastPerformance(for: exercise)
        
        if setIndex < lastPerformance?.setWeights.count ?? 0,
           let weight = lastPerformance?.setWeights[setIndex],
           let reps = lastPerformance?.setReps[setIndex] {
            return "\(String(format: "%.1f", weight))×\(reps)"
        }
        return "—"
    }
}

// Detailed set row with optimized text input
struct DetailedSetRow: View {
    var setNumber: Int
    var lastTimeText: String
    var currentWeight: Double?
    var currentReps: Int?
    var isCompleted: Bool
    var onToggleComplete: (Bool) -> Void
    var onUpdateWeight: (Double?) -> Void
    var onUpdateReps: (Int?) -> Void
    var focusedField: FocusState<String?>.Binding
    var weightFieldId: String
    var repsFieldId: String
    
    // Local state for text fields with preset values
    @State private var weightText: String
    @State private var repsText: String
    
    // Initialize properly
    init(setNumber: Int, lastTimeText: String, currentWeight: Double?, currentReps: Int?, isCompleted: Bool,
         onToggleComplete: @escaping (Bool) -> Void, onUpdateWeight: @escaping (Double?) -> Void, onUpdateReps: @escaping (Int?) -> Void,
         focusedField: FocusState<String?>.Binding, weightFieldId: String, repsFieldId: String) {
        
        self.setNumber = setNumber
        self.lastTimeText = lastTimeText
        self.currentWeight = currentWeight
        self.currentReps = currentReps
        self.isCompleted = isCompleted
        self.onToggleComplete = onToggleComplete
        self.onUpdateWeight = onUpdateWeight
        self.onUpdateReps = onUpdateReps
        self.focusedField = focusedField
        self.weightFieldId = weightFieldId
        self.repsFieldId = repsFieldId
        
        // Initialize the text fields with current values
        _weightText = State(initialValue: currentWeight != nil ? String(format: "%.1f", currentWeight!) : "")
        _repsText = State(initialValue: currentReps != nil ? "\(currentReps!)" : "")
    }
    
    var body: some View {
        HStack {
            // Set number
            Text("\(setNumber)")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.white)
                .frame(width: 40, alignment: .center)
            
            // Last time
            Text(lastTimeText)
                .font(.system(size: 14))
                .foregroundColor(.gray)
                .frame(width: 80, alignment: .center)
            
            // Weight input - optimized with numeric keyboard and focus control
            ZStack {
                // Prefilled weight (for immediate display without focus delay)
                if focusedField.wrappedValue != weightFieldId {
                    Text(weightText.isEmpty ? "0" : weightText)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(weightText.isEmpty ? .gray : .white)
                        .frame(maxWidth: .infinity, alignment: .center)
                }
                
                TextField("", text: $weightText)
                    .keyboardType(.decimalPad)
                    .font(.system(size: 16, weight: .medium))
                    .multilineTextAlignment(.center)
                    .foregroundColor(.white)
                    .focused(focusedField, equals: weightFieldId)
                    .opacity(focusedField.wrappedValue == weightFieldId ? 1 : 0)
                    .onChange(of: weightText) { newValue in
                        let cleanedValue = newValue.replacingOccurrences(of: ",", with: ".")
                        if cleanedValue.isEmpty {
                            onUpdateWeight(nil)
                        } else if let value = Double(cleanedValue) {
                            onUpdateWeight(value)
                        }
                    }
            }
            .frame(width: 70, height: 40)
            .background(Color(.systemGray6).opacity(0.3))
            .cornerRadius(10)
            .onTapGesture {
                focusedField.wrappedValue = weightFieldId
            }
            
            // Reps input - optimized with numeric keyboard and focus control
            ZStack {
                // Prefilled reps (for immediate display without focus delay)
                if focusedField.wrappedValue != repsFieldId {
                    Text(repsText.isEmpty ? "0" : repsText)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(repsText.isEmpty ? .gray : .white)
                        .frame(maxWidth: .infinity, alignment: .center)
                }
                
                TextField("", text: $repsText)
                    .keyboardType(.numberPad)
                    .font(.system(size: 16, weight: .medium))
                    .multilineTextAlignment(.center)
                    .foregroundColor(.white)
                    .focused(focusedField, equals: repsFieldId)
                    .opacity(focusedField.wrappedValue == repsFieldId ? 1 : 0)
                    .onChange(of: repsText) { newValue in
                        if newValue.isEmpty {
                            onUpdateReps(nil)
                        } else if let value = Int(newValue) {
                            onUpdateReps(value)
                        }
                    }
            }
            .frame(width: 70, height: 40)
            .background(Color(.systemGray6).opacity(0.3))
            .cornerRadius(10)
            .onTapGesture {
                focusedField.wrappedValue = repsFieldId
            }
            
            // Completion toggle
            Button(action: {
                onToggleComplete(!isCompleted)
            }) {
                ZStack {
                    Circle()
                        .stroke(isCompleted ? Color.green : Color.gray.opacity(0.5), lineWidth: 2)
                        .frame(width: 30, height: 30)
                    
                    if isCompleted {
                        Circle()
                            .fill(Color.green)
                            .frame(width: 22, height: 22)
                    }
                }
            }
            .frame(width: 60, alignment: .center)
        }
        .padding(.vertical, 8)
    }
}
