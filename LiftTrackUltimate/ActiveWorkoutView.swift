import SwiftUI
import UIKit

struct ActiveWorkoutView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var dataManager: DataManager
    
    // Reference to the WorkoutSessionManager
    @ObservedObject private var sessionManager = WorkoutSessionManager.shared
    
    var template: WorkoutTemplate?
    var onEnd: () -> Void
    
    // For keyboard dismissal
    @FocusState private var focusedField: String?
    
    // Local state for UI elements
    @State private var showingFinishAlert = false
    @State private var showingExerciseSelection = false
    @State private var showingCompletionAnimation = false
    
    // Animation states
    @State private var animateAddSet = false
    @State private var animateRemoveSet = false
    
    // Celebration animation state
    @State private var celebrate: Bool = false
    @State private var lastCompletionPercentage: Double = 0 // Track previous value
    
    init(template: WorkoutTemplate?, onEnd: @escaping () -> Void) {
        self.template = template
        self.onEnd = onEnd
    }
    
    // Calculate the overall completion percentage
    private var completionPercentage: Double {
        let totalSets = sessionManager.exercises.reduce(0) { $0 + $1.sets.count }
        if totalSets == 0 { return 0 }
        
        let completedSets = sessionManager.exercises.reduce(0) { $0 + $1.sets.filter(\.completed).count }
        return Double(completedSets) / Double(totalSets) * 100
    }
    
    var body: some View {
        ZStack {
            // Background color
            Color.black.edgesIgnoringSafeArea(.all)
            
            // Content area
            VStack(spacing: 0) {
                // Progress indicator with floating percentage and celebration animation
                ZStack(alignment: .leading) {
                    // Background track
                    Rectangle()
                        .fill(Color.gray.opacity(0.2))
                        .frame(height: 6)
                        .edgesIgnoringSafeArea(.horizontal)
                    
                    // Progress fill with gradient
                    Rectangle()
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [Color.blue, Color.green]),
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: UIScreen.main.bounds.width * CGFloat(completionPercentage / 100), height: 6)
                        .animation(.spring(response: 0.3), value: completionPercentage)
                        .edgesIgnoringSafeArea(.horizontal)
                        // Celebration animation overlay
                        .overlay(
                            Group {
                                if completionPercentage >= 100 && celebrate {
                                    Rectangle()
                                        .fill(Color.white.opacity(0.5))
                                        .frame(height: 6)
                                        .opacity(celebrate ? 0.7 : 0)
                                        .animation(Animation.easeInOut(duration: 0.5).repeatCount(3, autoreverses: true), value: celebrate)
                                }
                            }
                        )
                    
                    // Percentage indicator positioning
                    GeometryReader { geometry in
                        // Calculate bubble position constrained within the screen
                        let progressWidth = min(geometry.size.width * CGFloat(completionPercentage / 100), geometry.size.width)
                        let bubbleWidth: CGFloat = 40 // Estimated width of the bubble
                        
                        // Position bubble, ensuring it stays within screen bounds
                        let xPosition = min(max(progressWidth - bubbleWidth/2, 20), geometry.size.width - bubbleWidth - 20)
                        
                        // Only show when progress is above 1%
                        if completionPercentage > 1 {
                            Text("\(Int(completionPercentage))%")
                                .font(.system(size: 10, weight: .bold))
                                .foregroundColor(.white)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(
                                    Capsule()
                                        .fill(Color.black.opacity(0.6))
                                )
                                .position(x: xPosition, y: 12) // Position it ON the bar, not above it
                                .animation(.spring(response: 0.3), value: completionPercentage)
                        }
                    }
                }
                .frame(height: 24) // Increased height to accommodate the bubble ON the bar
                // onChange modifier to detect 100% completion
                .onChange(of: completionPercentage) { oldValue, newValue in
                    // Check if we've just reached 100%
                    if newValue >= 100 && lastCompletionPercentage < 100 {
                        withAnimation {
                            celebrate = true
                        }
                        
                        // Strong haptic feedback when reaching 100%
                        let feedback = UINotificationFeedbackGenerator()
                        feedback.notificationOccurred(.success)
                        
                        // Reset after animation completes
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.6) {
                            celebrate = false
                        }
                    }
                    // Update the last value
                    lastCompletionPercentage = newValue
                }
                
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
                        }
                        .padding(.horizontal)
                        .padding(.vertical, 12)
                        
                        // Workout header
                        VStack(spacing: 16) {
                            // Editable workout name
                            TextField("Workout Name", text: $sessionManager.workoutName)
                                .font(.system(size: 28, weight: .bold))
                                .foregroundColor(.white)
                                .multilineTextAlignment(.center)
                                .padding(.top, 8)
                                .focused($focusedField, equals: "workoutName")
                            
                            // Timer and heart rate
                            HStack(spacing: 20) {
                                // Timer display
                                HStack {
                                    TimerDisplay(elapsedTime: sessionManager.elapsedTime)
                                    
                                    // Play/pause button - Increased size
                                    Button(action: {
                                        sessionManager.togglePause()
                                        
                                        // Haptic feedback when play/pause is pressed
                                        let feedback = UIImpactFeedbackGenerator(style: .medium)
                                        feedback.impactOccurred()
                                    }) {
                                        ZStack {
                                            Circle()
                                                .fill(Color.blue.opacity(0.2))
                                                .frame(width: 54, height: 54)
                                            
                                            Image(systemName: sessionManager.isTimerPaused ? "play.fill" : "pause.fill")
                                                .font(.system(size: 24))
                                                .foregroundColor(.blue)
                                        }
                                    }
                                }
                                
                                // Heart rate display
                                HeartRateDisplay(heartRate: sessionManager.heartRate)
                            }
                            .padding(.vertical, 8)
                        }
                        .padding(.horizontal)
                        
                        // Exercise cards - always expanded
                        ForEach(sessionManager.exercises) { exercise in
                            ActiveWorkoutExerciseCard(
                                exercise: exercise,
                                onSetComplete: { setIndex, isComplete in
                                    if let exerciseIndex = sessionManager.exercises.firstIndex(where: { $0.id == exercise.id }) {
                                        sessionManager.toggleSetCompletion(for: exerciseIndex, setIndex: setIndex)
                                    }
                                    
                                    // Haptic feedback when set is completed
                                    if isComplete {
                                        let feedback = UIImpactFeedbackGenerator(style: .light)
                                        feedback.impactOccurred()
                                    }
                                },
                                onAddSet: {
                                    // Haptic feedback when set is added
                                    let feedback = UIImpactFeedbackGenerator(style: .medium)
                                    feedback.impactOccurred()
                                    
                                    // Add the set
                                    sessionManager.addSet(to: sessionManager.exercises.firstIndex(where: { $0.id == exercise.id }) ?? 0)
                                    
                                    // Trigger animation
                                    withAnimation {
                                        animateAddSet = true
                                    }
                                    
                                    // Reset animation state after delay
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                        animateAddSet = false
                                    }
                                },
                                onDeleteSet: { setIndex in
                                    // Haptic feedback when set is removed
                                    let feedback = UIImpactFeedbackGenerator(style: .medium)
                                    feedback.impactOccurred()
                                    
                                    // Trigger animation
                                    withAnimation {
                                        animateRemoveSet = true
                                    }
                                    
                                    // Remove the set after a slight delay to allow animation
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                        if let exerciseIndex = sessionManager.exercises.firstIndex(where: { $0.id == exercise.id }) {
                                            sessionManager.removeSet(at: setIndex, from: exerciseIndex)
                                        }
                                        
                                        // Reset animation state after delay
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                                            animateRemoveSet = false
                                        }
                                    }
                                },
                                onUpdateWeight: { setIndex, weight in
                                    if let exerciseIndex = sessionManager.exercises.firstIndex(where: { $0.id == exercise.id }) {
                                        sessionManager.updateWeight(weight, for: exerciseIndex, setIndex: setIndex)
                                    }
                                },
                                onUpdateReps: { setIndex, reps in
                                    if let exerciseIndex = sessionManager.exercises.firstIndex(where: { $0.id == exercise.id }) {
                                        if let repsValue = reps {
                                            sessionManager.updateReps(repsValue, for: exerciseIndex, setIndex: setIndex)
                                        }
                                    }
                                },
                                dataManager: dataManager,
                                focusedField: $focusedField,
                                exerciseId: exercise.id.uuidString,
                                animateAddSet: animateAddSet,
                                animateRemoveSet: animateRemoveSet
                            )
                            .padding(.bottom, 15)
                        }
                        
                        // Add exercise button
                        Button(action: {
                            dismissKeyboard()
                            showingExerciseSelection = true
                            
                            // Haptic feedback
                            let feedback = UIImpactFeedbackGenerator(style: .medium)
                            feedback.impactOccurred()
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
                                
                                // Haptic feedback
                                let feedback = UINotificationFeedbackGenerator()
                                feedback.notificationOccurred(.success)
                                
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
                                
                                // Haptic feedback
                                let feedback = UIImpactFeedbackGenerator(style: .medium)
                                feedback.impactOccurred()
                                
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
                    .padding(.top, 4) // Small padding for separation
                }
                // Add background tap gesture to dismiss keyboard
                .contentShape(Rectangle())
                .onTapGesture {
                    dismissKeyboard()
                }
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
                        sessionManager.cancelWorkout()
                        
                        // Haptic feedback
                        let feedback = UINotificationFeedbackGenerator()
                        feedback.notificationOccurred(.error)
                        
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
            ExerciseSelectionView(
                selectedExercises: [],  // No exercises selected initially
                onSelectionComplete: { exercises in
                    // Add each selected exercise to the session
                    for exercise in exercises {
                        sessionManager.addExercise(exercise)
                    }
                }
            )
            .environmentObject(dataManager)
        }
        .onAppear {
            UITextField.appearance().tintColor = .white // Set cursor color to white
            
            // Start new workout session if needed
            if !sessionManager.isActive {
                sessionManager.startWorkout(template: template)
            }
        }
    }
    
    // Helper to dismiss keyboard
    private func dismissKeyboard() {
        focusedField = nil
    }
    
    // Complete the workout with animation
    private func completeWorkout() {
        // Don't allow completing if no exercises or all exercises are empty
        let hasCompletedSets = sessionManager.exercises.contains { exercise in
            exercise.sets.contains { $0.completed }
        }
        
        if sessionManager.exercises.isEmpty || !hasCompletedSets {
            let feedback = UINotificationFeedbackGenerator()
            feedback.notificationOccurred(.error)
            return
        }
        
        // Show completion animation
        withAnimation {
            showingCompletionAnimation = true
        }
        
        // After animation is hidden, complete the workout
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            sessionManager.completeWorkout()
            // Call onEnd directly instead of using notification
            onEnd()
            dismiss()
        }
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

// Always expanded exercise card
struct ActiveWorkoutExerciseCard: View {
    var exercise: WorkoutExercise
    var onSetComplete: (Int, Bool) -> Void
    var onAddSet: () -> Void
    var onDeleteSet: (Int) -> Void
    var onUpdateWeight: (Int, Double?) -> Void
    var onUpdateReps: (Int, Int?) -> Void
    var dataManager: DataManager
    var focusedField: FocusState<String?>.Binding
    var exerciseId: String
    
    // Animation state flags
    var animateAddSet: Bool
    var animateRemoveSet: Bool
    
    // Calculate the first set that can be edited (first uncompleted set)
    private var firstEditableSetIndex: Int {
        // If there are no completed sets, only the first set is editable
        if !exercise.sets.contains(where: { $0.completed }) {
            return 0
        }
        
        // Find the index of the first uncompleted set
        for (index, set) in exercise.sets.enumerated() {
            if !set.completed {
                return index
            }
        }
        
        // If all sets are completed, the next one would be editable
        return exercise.sets.count
    }
    
    // Determine if a set is editable (can be edited and completed)
    private func isSetEditable(at index: Int) -> Bool {
        // A set is editable if it's already completed or if it's the first uncompleted set
        return exercise.sets[index].completed || index == firstEditableSetIndex
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Exercise header
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(exercise.exercise.name)
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.white)
                    
                    Text(exercise.exercise.muscleGroups.joined(separator: ", "))
                        .font(.system(size: 16))
                        .foregroundColor(Color.gray.opacity(0.8))
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
            
            // Instruction tip for sequential set completion
            if firstEditableSetIndex < exercise.sets.count {
                HStack(spacing: 8) {
                    Image(systemName: "info.circle.fill")
                        .foregroundColor(.blue)
                        .font(.system(size: 14))
                    
                    Text("Complete sets in order. Set \(firstEditableSetIndex + 1) is ready to be completed.")
                        .font(.system(size: 13))
                        .foregroundColor(.gray)
                    
                    Spacer()
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 12)
            }
            
            // Added subtle divider between header and table
            Divider()
                .background(Color.gray.opacity(0.3))
                .padding(.horizontal, 20)
            
            // Table header with improved styling
            HStack {
                Text("Set")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.white)
                    .frame(width: 40, alignment: .center)
                
                Text("Last Time")
                    .font(.system(size: 12, weight: .regular))
                    .foregroundColor(Color.gray.opacity(0.7))
                    .frame(width: 100, alignment: .center)
                
                Text("kg")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.white)
                    .frame(width: 70, alignment: .center)
                
                Text("Reps")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.white)
                    .frame(width: 70, alignment: .center)
                
                Text("Done")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.white)
                    .frame(width: 60, alignment: .center)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 10)
            
            // Sets rows with improved visuals and animation
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
                        if let reps = reps {
                            onUpdateReps(index, reps)
                        }
                    },
                    focusedField: focusedField,
                    weightFieldId: "\(exerciseId)_weight_\(index)",
                    repsFieldId: "\(exerciseId)_reps_\(index)",
                    onDelete: exercise.sets.count > 1 ? { onDeleteSet(index) } : nil,
                    // Pass the animation flag for the last set
                    isLastSet: index == exercise.sets.count - 1,
                    animateAddSet: animateAddSet,
                    animateRemoveSet: animateRemoveSet,
                    isEditableNow: isSetEditable(at: index),
                    isNextToComplete: index == firstEditableSetIndex
                )
                
                Divider()
                    .background(Color.gray.opacity(0.3))
                    .padding(.horizontal, 20)
            }
            
            // Add/Remove Set buttons with enhanced styling
            HStack {
                Button(action: onAddSet) {
                    HStack {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 18))
                            .foregroundColor(.blue)
                        
                        Text("Add Set")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.blue)
                    }
                    .padding(.vertical, 15)
                    .padding(.horizontal, 10)
                    .frame(maxWidth: .infinity)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.blue.opacity(0.1))
                            .shadow(color: Color.blue.opacity(0.2), radius: 3, x: 0, y: 2)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.blue.opacity(0.3), lineWidth: 1)
                    )
                }
                .buttonStyle(PlainButtonStyle())
                .padding(.horizontal, 10)
                
                if exercise.sets.count > 1 {
                    Button(action: {
                        onDeleteSet(exercise.sets.count - 1)
                    }) {
                        HStack {
                            Image(systemName: "minus.circle.fill")
                                .font(.system(size: 18))
                                .foregroundColor(.red)
                            
                            Text("Remove Set")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.red)
                        }
                        .padding(.vertical, 15)
                        .padding(.horizontal, 10)
                        .frame(maxWidth: .infinity)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.red.opacity(0.1))
                                .shadow(color: Color.red.opacity(0.2), radius: 3, x: 0, y: 2)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.red.opacity(0.3), lineWidth: 1)
                        )
                    }
                    .buttonStyle(PlainButtonStyle())
                    .padding(.horizontal, 10)
                    // Only allow removing sets if all sets are completed or the last set is not editable
                    .disabled(firstEditableSetIndex < exercise.sets.count)
                }
            }
            .padding(.top, 12)
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
    
    private func getLastTimeText(for exercise: Exercise, setIndex: Int) -> String {
        let lastPerformance = dataManager.getLastPerformance(for: exercise)
        
        if setIndex < lastPerformance?.setWeights.count ?? 0,
           let weight = lastPerformance?.setWeights[setIndex],
           let reps = lastPerformance?.setReps[setIndex] {
            return "\(String(format: "%.1f", weight)) kg × \(reps)"
        }
        return "—"
    }
}

// Detailed set row with optimized text input and animations
struct DetailedSetRow: View {
    // Basic properties
    let setNumber: Int
    let lastTimeText: String
    let currentWeight: Double?
    let currentReps: Int
    let isCompleted: Bool
    let isEditableNow: Bool
    let isNextToComplete: Bool
    
    // Callbacks
    let onToggleComplete: (Bool) -> Void
    let onUpdateWeight: (Double?) -> Void
    let onUpdateReps: (Int?) -> Void
    let onDelete: (() -> Void)?
    
    // Focus state
    var focusedField: FocusState<String?>.Binding
    let weightFieldId: String
    let repsFieldId: String
    
    // Animation support
    let isLastSet: Bool
    let animateAddSet: Bool
    let animateRemoveSet: Bool
    
    // Local state
    @State private var weightText: String = ""
    @State private var repsText: String = ""
    @State private var showCompletionAnimation: Bool = false
    @State private var isPulsating: Bool = false
    
    // Standard initializer
    init(
        setNumber: Int,
        lastTimeText: String,
        currentWeight: Double?,
        currentReps: Int,
        isCompleted: Bool,
        onToggleComplete: @escaping (Bool) -> Void,
        onUpdateWeight: @escaping (Double?) -> Void,
        onUpdateReps: @escaping (Int?) -> Void,
        focusedField: FocusState<String?>.Binding,
        weightFieldId: String,
        repsFieldId: String,
        onDelete: (() -> Void)? = nil,
        isLastSet: Bool = false,
        animateAddSet: Bool = false,
        animateRemoveSet: Bool = false,
        isEditableNow: Bool = true,
        isNextToComplete: Bool = false
    ) {
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
        self.onDelete = onDelete
        self.isLastSet = isLastSet
        self.animateAddSet = animateAddSet
        self.animateRemoveSet = animateRemoveSet
        self.isEditableNow = isEditableNow
        self.isNextToComplete = isNextToComplete
        
        // Initialize text state
        _weightText = State(initialValue: currentWeight != nil ? String(format: "%.1f", currentWeight!) : "")
        _repsText = State(initialValue: "\(currentReps)")
    }
    
    var body: some View {
        rowContent
            .padding(.vertical, 8)
            .background(rowBackground)
            .opacity(rowOpacity)
            .scaleEffect(isLastSet && animateAddSet ? 0.8 : 1.0)
            .animation(.spring(response: 0.3), value: animateAddSet)
            .animation(.easeInOut(duration: 0.2), value: animateRemoveSet)
            .contextMenu { contextMenuContent }
            .swipeActions(edge: .trailing) { swipeActionsContent }
            .onAppear(perform: setupAnimations)
    }
    
    // MARK: - View Components
    
    private var rowContent: some View {
        HStack {
            setNumberView
            lastTimeView
            weightInputField
            repsInputField
            completionButton
        }
    }
    
    private var setNumberView: some View {
        Text("\(setNumber)")
            .font(.system(size: 18, weight: .bold))
            .foregroundColor(setNumberColor)
            .frame(width: 40, alignment: .center)
    }
    
    private var lastTimeView: some View {
        Text(lastTimeText)
            .font(.system(size: 12))
            .foregroundColor(Color.gray.opacity(0.7))
            .frame(width: 100, alignment: .center)
    }
    
    private var weightInputField: some View {
        ZStack {
            if focusedField.wrappedValue != weightFieldId {
                Text(weightText.isEmpty ? "0" : weightText)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(weightText.isEmpty ? Color.white.opacity(0.5) : .white)
                    .frame(maxWidth: .infinity, alignment: .center)
            }
            
            TextField("", text: $weightText)
                .keyboardType(.decimalPad)
                .font(.system(size: 16, weight: .medium))
                .multilineTextAlignment(.center)
                .foregroundColor(.white)
                .focused(focusedField, equals: weightFieldId)
                .opacity(focusedField.wrappedValue == weightFieldId ? 1 : 0)
                .disabled(!isEditableNow)
                .onChange(of: weightText) { oldValue, newValue in
                    handleWeightChange(newValue)
                }
        }
        .frame(width: 70, height: 42)
        .background(Color(.systemGray6).opacity(isEditableNow ? 0.3 : 0.2))
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(inputBorderColor, lineWidth: isNextToComplete ? 2 : 1)
        )
        .cornerRadius(10)
        .onTapGesture {
            if isEditableNow {
                focusedField.wrappedValue = weightFieldId
            }
        }
    }
    
    private var repsInputField: some View {
        ZStack {
            if focusedField.wrappedValue != repsFieldId {
                Text(repsText.isEmpty ? "0" : repsText)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(repsText.isEmpty ? Color.white.opacity(0.5) : .white)
                    .frame(maxWidth: .infinity, alignment: .center)
            }
            
            TextField("", text: $repsText)
                .keyboardType(.numberPad)
                .font(.system(size: 16, weight: .medium))
                .multilineTextAlignment(.center)
                .foregroundColor(.white)
                .focused(focusedField, equals: repsFieldId)
                .opacity(focusedField.wrappedValue == repsFieldId ? 1 : 0)
                .disabled(!isEditableNow)
                .onChange(of: repsText) { oldValue, newValue in
                    handleRepsChange(newValue)
                }
        }
        .frame(width: 70, height: 42)
        .background(Color(.systemGray6).opacity(isEditableNow ? 0.3 : 0.2))
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(inputBorderColor, lineWidth: isNextToComplete ? 2 : 1)
        )
        .cornerRadius(10)
        .onTapGesture {
            if isEditableNow {
                focusedField.wrappedValue = repsFieldId
            }
        }
    }
    
    private var completionButton: some View {
        Button(action: handleCompletionToggle) {
            ZStack {
                Circle()
                    .stroke(completionCircleColor, lineWidth: 2)
                    .frame(width: 32, height: 32)
                
                completionCircleContent
            }
        }
        .disabled(!isEditableNow)
        .frame(width: 60, alignment: .center)
    }
    
    private var completionCircleContent: some View {
        Group {
            if isCompleted {
                Circle()
                    .fill(Color.green)
                    .frame(width: 24, height: 24)
                    .scaleEffect(showCompletionAnimation ? 1.2 : 1.0)
            } else if isNextToComplete {
                Image(systemName: "arrow.right.circle.fill")
                    .font(.system(size: 16))
                    .foregroundColor(Color.blue)
                    .scaleEffect(isPulsating ? 1.1 : 1.0)
            } else if !isEditableNow {
                Image(systemName: "lock.fill")
                    .font(.system(size: 12))
                    .foregroundColor(Color.gray.opacity(0.5))
            }
        }
    }
    
    @ViewBuilder
    private var contextMenuContent: some View {
        if let onDelete = onDelete, isEditableNow {
            Button(role: .destructive, action: onDelete) {
                Label("Delete Set", systemImage: "trash")
            }
        }
    }
    
    @ViewBuilder
    private var swipeActionsContent: some View {
        if let onDelete = onDelete, isEditableNow {
            Button(role: .destructive, action: onDelete) {
                Label("Delete", systemImage: "trash")
            }
        }
    }
    
    private var rowBackground: some View {
        Group {
            if isNextToComplete {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.blue.opacity(0.1))
                    .padding(.horizontal, 8)
            } else {
                Color.clear
            }
        }
    }
    
    // MARK: - Computed Properties
    
    private var setNumberColor: Color {
        if isEditableNow {
            return isNextToComplete ? .blue : .white
        } else {
            return .gray.opacity(0.6)
        }
    }
    
    private var inputBorderColor: Color {
        if isNextToComplete {
            return Color.blue.opacity(isPulsating ? 0.8 : 0.4)
        } else if isEditableNow {
            return Color.blue.opacity(0.4)
        } else {
            return Color.gray.opacity(0.3)
        }
    }
    
    private var completionCircleColor: Color {
        if isCompleted {
            return Color.green
        } else if isNextToComplete {
            return Color.blue.opacity(isPulsating ? 0.8 : 0.5)
        } else if isEditableNow {
            return Color.gray.opacity(0.5)
        } else {
            return Color.gray.opacity(0.2)
        }
    }
    
    private var rowOpacity: Double {
        if isLastSet && animateRemoveSet {
            return 0
        } else if !isEditableNow {
            return 0.7
        } else if isLastSet && animateAddSet {
            return 0.8
        } else {
            return 1.0
        }
    }
    
    // MARK: - Helper Methods
    
    private func setupAnimations() {
        if isNextToComplete {
            withAnimation(Animation.easeInOut(duration: 1.2).repeatForever(autoreverses: true)) {
                isPulsating = true
            }
        }
    }
    
    private func handleWeightChange(_ newValue: String) {
        let cleanedValue = newValue.replacingOccurrences(of: ",", with: ".")
        if cleanedValue.isEmpty {
            onUpdateWeight(nil)
        } else if let value = Double(cleanedValue) {
            onUpdateWeight(value)
        }
    }
    
    private func handleRepsChange(_ newValue: String) {
        if newValue.isEmpty {
            onUpdateReps(nil)
        } else if let value = Int(newValue) {
            onUpdateReps(value)
        }
    }
    
    private func handleCompletionToggle() {
        if isEditableNow {
            withAnimation(.spring(response: 0.3)) {
                showCompletionAnimation = !isCompleted
            }
            
            onToggleComplete(!isCompleted)
            
            if !isCompleted {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    withAnimation {
                        showCompletionAnimation = false
                    }
                }
            }
        }
    }
}

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
