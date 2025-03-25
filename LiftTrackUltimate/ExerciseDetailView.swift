import SwiftUI

struct ExerciseDetailView: View {
    @EnvironmentObject var dataManager: DataManager
    @Environment(\.dismiss) private var dismiss
    @State private var showingEditView = false
    @State private var showingDeleteAlert = false
    @State private var showingCustomDeleteConfirmation = false
    @State private var selectedTab = 0
    @State private var animateContent = false
    @State private var isFavorite = false
    
    var exercise: Exercise
    
    // Check if this is a custom exercise that can be deleted
    private var isCustomExercise: Bool {
        // Since there's no defaultExercises property in DataManager,
        // we'll check if the exercise is one of the sample exercises
        
        // Define names of sample exercises created in loadSampleData
        // These are considered "default" and not deletable
        let defaultExerciseNames = [
            "Bench Press", "Incline Bench Press", "Decline Bench Press", "Dumbbell Flyes",
            "Cable Crossover", "Push-Ups", "Deadlift", "Pull-Up", "Bent Over Row",
            "Lat Pulldown", "T-Bar Row", "Face Pull", "Overhead Press", "Lateral Raise",
            "Front Raise", "Rear Delt Flye", "Arnold Press", "Bicep Curl", "Hammer Curl",
            "Tricep Pushdown", "Tricep Extension", "Preacher Curl", "Skull Crusher",
            "Squat", "Leg Press", "Leg Extension", "Leg Curl", "Calf Raise", "Lunges",
            "Romanian Deadlift", "Hip Thrust", "Plank", "Crunch", "Leg Raise",
            "Russian Twist", "Side Plank", "Mountain Climber", "Running", "Cycling",
            "Rowing", "Jumping Rope", "Elliptical", "Stair Climber"
        ]
        
        // Check if the current exercise's name is in the default list
        return !defaultExerciseNames.contains(exercise.name)
    }
    
    // Tab titles
    private let tabs = ["Overview", "History", "Records"]
    
    // Get performance history
    private var performanceHistory: ExercisePerformance? {
        return dataManager.getLastPerformance(for: exercise)
    }
    
    var body: some View {
        ExerciseDetailContent(
            exercise: exercise,
            performanceHistory: performanceHistory,
            tabs: tabs,
            selectedTab: $selectedTab,
            animateContent: $animateContent,
            isFavorite: $isFavorite,
            showingEditView: $showingEditView,
            showingCustomDeleteConfirmation: $showingCustomDeleteConfirmation,
            isCustomExercise: isCustomExercise,
            dismiss: dismiss,
            dataManager: dataManager
        )
        .navigationTitle("Exercise Details")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                HStack(spacing: 16) {
                    // Edit button
                    Button(action: {
                        showingEditView = true
                    }) {
                        Image(systemName: "pencil")
                            .foregroundColor(.blue)
                    }
                    
                    // Delete button - only show for custom exercises
                    if isCustomExercise {
                        Button(action: {
                            showingCustomDeleteConfirmation = true
                        }) {
                            Image(systemName: "trash")
                                .foregroundColor(.red)
                        }
                    }
                }
            }
        }
        .sheet(isPresented: $showingEditView) {
            EditExerciseView(exercise: exercise) { updatedExercise in
                // Find and update the exercise in the data manager
                var updatedExercises = dataManager.exercises
                if let index = updatedExercises.firstIndex(where: { $0.id == exercise.id }) {
                    updatedExercises[index] = updatedExercise
                    dataManager.updateExercises(updatedExercises)
                }
            }
            .environmentObject(dataManager)
        }
        .overlay(
            Group {
                if showingCustomDeleteConfirmation {
                    ZStack {
                        // Dimmed background
                        Color.black.opacity(0.6)
                            .edgesIgnoringSafeArea(.all)
                            .onTapGesture {
                                // Allow tapping outside to dismiss
                                withAnimation {
                                    showingCustomDeleteConfirmation = false
                                }
                            }
                        
                        // Alert container
                        VStack(spacing: 0) {
                            // Top part with warning content
                            VStack(spacing: 16) {
                                // Warning icon
                                Image(systemName: "exclamationmark.triangle.fill")
                                    .font(.system(size: 40))
                                    .foregroundColor(.red)
                                    .padding(.top, 24)
                                
                                Text("Delete Exercise")
                                    .font(.system(size: 20, weight: .bold))
                                    .foregroundColor(.white)
                                
                                Text("Are you sure you want to delete '\(exercise.name)'?")
                                    .font(.system(size: 16))
                                    .foregroundColor(.gray)
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal, 20)
                                
                                Text("This action cannot be undone.")
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(.red)
                                    .padding(.bottom, 20)
                            }
                            
                            Divider()
                                .background(Color.gray.opacity(0.5))
                            
                            // Bottom part with action buttons
                            HStack(spacing: 0) {
                                Button(action: {
                                    withAnimation {
                                        showingCustomDeleteConfirmation = false
                                    }
                                }) {
                                    Text("Cancel")
                                        .font(.system(size: 17))
                                        .fontWeight(.regular)
                                        .foregroundColor(.white)
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 16)
                                }
                                
                                Divider()
                                    .background(Color.gray.opacity(0.5))
                                    .frame(height: 50)
                                
                                Button(action: {
                                    // Filter out this exercise
                                    let updatedExercises = dataManager.exercises.filter { $0.id != exercise.id }
                                    dataManager.updateExercises(updatedExercises)
                                    withAnimation {
                                        showingCustomDeleteConfirmation = false
                                    }
                                    dismiss()
                                }) {
                                    Text("Delete")
                                        .font(.system(size: 17))
                                        .fontWeight(.semibold)
                                        .foregroundColor(.red)
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 16)
                                }
                            }
                        }
                        .background(Color(UIColor.systemBackground).opacity(0.95))
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                        .frame(width: min(UIScreen.main.bounds.width - 50, 300))
                        .shadow(color: Color.black.opacity(0.2), radius: 20, x: 0, y: 10)
                        .transition(.opacity.combined(with: .scale))
                    }
                    .animation(.easeInOut(duration: 0.2), value: showingCustomDeleteConfirmation)
                }
            }
        )
        .onAppear {
            // Animate content in
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7).delay(0.1)) {
                animateContent = true
            }
        }
    }
}

// We've integrated the custom alert directly in the view rather than as separate components

// MARK: - Main Content View
struct ExerciseDetailContent: View {
    var exercise: Exercise
    var performanceHistory: ExercisePerformance?
    var tabs: [String]
    @Binding var selectedTab: Int
    @Binding var animateContent: Bool
    @Binding var isFavorite: Bool
    @Binding var showingEditView: Bool
    @Binding var showingCustomDeleteConfirmation: Bool
    var isCustomExercise: Bool
    var dismiss: DismissAction
    var dataManager: DataManager
    
    var body: some View {
        ZStack {
            // Background
            Color.black.edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 0) {
                ScrollView {
                    VStack(spacing: 0) {
                        // Hero section
                        ExerciseHeroSection(
                            exercise: exercise,
                            performanceHistory: performanceHistory,
                            animateContent: animateContent
                        )
                        
                        // Tab selector
                        TabSelector(
                            tabs: tabs,
                            selectedTab: $selectedTab,
                            animateContent: animateContent
                        )
                        
                        // Tab content
                        TabContentView(
                            selectedTab: selectedTab,
                            exercise: exercise,
                            dataManager: dataManager,
                            animateContent: animateContent
                        )
                    }
                    .padding(.bottom, 50)
                }
                
                // Add Delete button at bottom for custom exercises
                if isCustomExercise {
                    Button(action: {
                        showingCustomDeleteConfirmation = true
                    }) {
                        HStack {
                            Image(systemName: "trash")
                                .foregroundColor(.white)
                            
                            Text("Delete Exercise")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.white)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.red.opacity(0.7))
                        )
                        .padding(.horizontal)
                        .padding(.bottom, 15)
                    }
                    .transition(.opacity)
                }
            }
        }
    }
}

// MARK: - Hero Section
struct ExerciseHeroSection: View {
    var exercise: Exercise
    var performanceHistory: ExercisePerformance?
    var animateContent: Bool
    
    var body: some View {
        VStack(spacing: 20) {
            // Icon
            ZStack {
                Circle()
                    .fill(LinearGradient(
                        gradient: Gradient(colors: [Color.blue.opacity(0.7), Color.blue.opacity(0.3)]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ))
                    .frame(width: 100, height: 100)
                    .shadow(color: Color.blue.opacity(0.3), radius: 8, x: 0, y: 4)
                
                Image(systemName: getExerciseIcon(for: exercise))
                    .font(.system(size: 40))
                    .foregroundColor(.white)
            }
            .scaleEffect(animateContent ? 1.0 : 0.5)
            .opacity(animateContent ? 1.0 : 0)
            
            // Exercise name
            Text(exercise.name)
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
                .opacity(animateContent ? 1.0 : 0)
                .offset(y: animateContent ? 0 : 20)
            
            // Muscle groups
            Text(exercise.muscleGroups.joined(separator: ", "))
                .font(.system(size: 16))
                .foregroundColor(.gray)
                .opacity(animateContent ? 1.0 : 0)
                .offset(y: animateContent ? 0 : 15)
            
            // Quick stats - only show if we have performance data
            if let performance = performanceHistory {
                QuickStatsView(performance: performance, animateContent: animateContent)
            }
        }
        .padding(.top, 20)
        .padding(.bottom, 30)
    }
    
    // Helper to get appropriate icon for exercise
    private func getExerciseIcon(for exercise: Exercise) -> String {
        if exercise.category.lowercased() == "cardio" {
            return "heart.circle"
        }
        
        let muscleGroups = exercise.muscleGroups.map { $0.lowercased() }
        
        if muscleGroups.contains("chest") {
            return "figure.arms.open"
        } else if muscleGroups.contains("back") {
            return "figure.strengthtraining.traditional"
        } else if muscleGroups.contains("shoulders") {
            return "figure.arms.open"
        } else if muscleGroups.contains("biceps") || muscleGroups.contains("triceps") || muscleGroups.contains("arms") {
            return "dumbbell.fill"
        } else if muscleGroups.contains("legs") || muscleGroups.contains("quadriceps") || muscleGroups.contains("hamstrings") {
            return "figure.walk"
        } else if muscleGroups.contains("abdominals") || muscleGroups.contains("core") {
            return "figure.core.training"
        }
        
        return "figure.mixed.cardio"
    }
}

// MARK: - Quick Stats View
struct QuickStatsView: View {
    var performance: ExercisePerformance
    var animateContent: Bool
    
    var body: some View {
        HStack(spacing: 30) {
            // Last used weight
            if let weight = performance.lastUsedWeight {
                StatBox(
                    title: "Best Weight",
                    value: String(format: "%.1f kg", weight),
                    icon: "scalemass.fill"
                )
            }
            
            // Last workout date
            if performance.date != nil {
                // Create a separate view to handle date display
                DateDisplayBox(date: performance.date)
            }
        }
        .opacity(animateContent ? 1.0 : 0)
        .offset(y: animateContent ? 0 : 20)
    }
}

// Separate view to handle date display
struct DateDisplayBox: View {
    var date: Date
    
    var body: some View {
        let dateString: String = {
            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            formatter.timeStyle = .none
            return formatter.string(from: date)
        }()
        
        return StatBox(
            title: "Last Used",
            value: dateString,
            icon: "calendar"
        )
    }
}

// MARK: - Tab Selector
struct TabSelector: View {
    var tabs: [String]
    @Binding var selectedTab: Int
    var animateContent: Bool
    
    var body: some View {
        HStack(spacing: 0) {
            ForEach(0..<tabs.count, id: \.self) { index in
                Button(action: {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        selectedTab = index
                    }
                }) {
                    Text(tabs[index])
                        .font(.system(size: 16, weight: selectedTab == index ? .semibold : .medium))
                        .foregroundColor(selectedTab == index ? .white : .gray)
                        .padding(.vertical, 12)
                        .frame(maxWidth: .infinity)
                }
                .background(
                    selectedTab == index ?
                        Color.blue.opacity(0.2) :
                        Color.clear
                )
            }
        }
        .background(Color(.systemGray6).opacity(0.3))
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .padding(.horizontal)
        .padding(.bottom, 20)
        .opacity(animateContent ? 1.0 : 0)
        .offset(y: animateContent ? 0 : 20)
    }
}

// MARK: - Tab Content View
struct TabContentView: View {
    var selectedTab: Int
    var exercise: Exercise
    var dataManager: DataManager
    var animateContent: Bool
    
    var body: some View {
        ZStack {
            // Overview tab
            if selectedTab == 0 {
                ExerciseOverviewTab(exercise: exercise)
                    .transition(.opacity)
            }
            // History tab
            else if selectedTab == 1 {
                ExerciseHistoryTab(exercise: exercise, dataManager: dataManager)
                    .transition(.opacity)
            }
            // Records tab
            else if selectedTab == 2 {
                ExerciseRecordsTab(exercise: exercise, dataManager: dataManager)
                    .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.3), value: selectedTab)
        .frame(minHeight: 400) // Ensure we have space for content
        .opacity(animateContent ? 1.0 : 0)
    }
}

// Stat Box Component
struct StatBox: View {
    var title: String
    var value: String
    var icon: String
    
    var body: some View {
        VStack(spacing: 5) {
            Image(systemName: icon)
                .font(.system(size: 14))
                .foregroundColor(.blue)
            
            Text(value)
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.white)
            
            Text(title)
                .font(.system(size: 12))
                .foregroundColor(.gray)
        }
        .frame(minWidth: 80)
        .padding(.vertical, 10)
        .padding(.horizontal, 5)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemGray6).opacity(0.3))
        )
    }
}

// MARK: - Tab Content Views

// Overview Tab
struct ExerciseOverviewTab: View {
    var exercise: Exercise
    
    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            // Instructions
            VStack(alignment: .leading, spacing: 8) {
                Text("Instructions")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.white)
                
                if let instructions = exercise.instructions, !instructions.isEmpty {
                    Text(instructions)
                        .font(.system(size: 16))
                        .foregroundColor(.gray)
                        .lineSpacing(4)
                } else {
                    Text("No instructions available for this exercise.")
                        .font(.system(size: 16))
                        .foregroundColor(.gray)
                        .lineSpacing(4)
                        .italic()
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(.systemGray6).opacity(0.2))
            )
            
            // Target muscles
            VStack(alignment: .leading, spacing: 8) {
                Text("Target Muscles")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.white)
                
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                    ForEach(exercise.muscleGroups, id: \.self) { muscle in
                        HStack {
                            Circle()
                                .fill(Color.blue)
                                .frame(width: 8, height: 8)
                            
                            Text(muscle)
                                .font(.system(size: 16))
                                .foregroundColor(.white)
                            
                            Spacer()
                        }
                        .padding(.vertical, 6)
                    }
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(.systemGray6).opacity(0.2))
            )
            
            // Category
            VStack(alignment: .leading, spacing: 8) {
                Text("Category")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.white)
                
                Text(exercise.category)
                    .font(.system(size: 16))
                    .foregroundColor(.gray)
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(.systemGray6).opacity(0.2))
            )
        }
        .padding()
    }
}

// History Tab
struct ExerciseHistoryTab: View {
    var exercise: Exercise
    var dataManager: DataManager
    
    // Get workout history for this exercise
    private var exerciseWorkouts: [WorkoutHistoryItem] {
        let workouts = dataManager.workouts
        var historyItems: [WorkoutHistoryItem] = []
        
        // Loop through all workouts to find this exercise
        for workout in workouts {
            for workoutExercise in workout.exercises {
                if workoutExercise.exercise.id == exercise.id && workoutExercise.sets.contains(where: { $0.completed }) {
                    // Create a description of the sets
                    let completedSets = workoutExercise.sets.filter { $0.completed }
                    var setsDescription = ""
                    
                    for (index, set) in completedSets.enumerated() {
                        if let weight = set.weight, let reps = set.reps {
                            setsDescription += "\(String(format: "%.1f", weight))kg × \(reps)"
                            if index < completedSets.count - 1 {
                                setsDescription += ", "
                            }
                        }
                    }
                    
                    // Format the date
                    let formatter = DateFormatter()
                    formatter.dateStyle = .medium
                    formatter.timeStyle = .none
                    
                    historyItems.append(WorkoutHistoryItem(
                        date: formatter.string(from: workout.date),
                        setsDescription: setsDescription
                    ))
                    
                    // Break after finding the exercise in this workout
                    break
                }
            }
        }
        
        return historyItems
    }
    
    var body: some View {
        VStack(spacing: 0) {
            if exerciseWorkouts.isEmpty {
                EmptyHistoryView()
            } else {
                ForEach(exerciseWorkouts, id: \.date) { item in
                    WorkoutHistoryRow(item: item)
                }
            }
        }
        .padding(.top, 12)
    }
    
    // Simple struct to hold workout history data
    struct WorkoutHistoryItem {
        let date: String
        let setsDescription: String
    }
}

// Empty History View
struct EmptyHistoryView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "calendar.badge.exclamationmark")
                .font(.system(size: 50))
                .foregroundColor(.gray)
                .padding(.top, 40)
            
            Text("No workout history")
                .font(.headline)
                .foregroundColor(.white)
            
            Text("You haven't logged any workouts with this exercise yet.")
                .font(.subheadline)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
                .padding(.bottom, 40)
        }
    }
}

// Workout History Row
struct WorkoutHistoryRow: View {
    var item: ExerciseHistoryTab.WorkoutHistoryItem
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(item.date)
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.white)
            
            Text(item.setsDescription)
                .font(.system(size: 14))
                .foregroundColor(.gray)
                .padding(.top, 2)
            
            Divider()
                .background(Color.gray.opacity(0.3))
                .padding(.top, 12)
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 16)
    }
}

// Records Tab
struct ExerciseRecordsTab: View {
    var exercise: Exercise
    var dataManager: DataManager
    
    // Get personal records
    private var records: [ExerciseRecord] {
        guard let performance = dataManager.getLastPerformance(for: exercise) else {
            return []
        }
        
        var recordsList: [ExerciseRecord] = []
        
        // Find max weight
        if let maxWeight = performance.setWeights.compactMap({ $0 }).max() {
            recordsList.append(ExerciseRecord(
                title: "Maximum Weight",
                value: "\(String(format: "%.1f", maxWeight)) kg",
                date: dateString(from: performance.date),
                icon: "arrow.up.circle.fill",
                iconColor: .blue
            ))
        }
        
        // Find max reps
        if let maxReps = performance.setReps.compactMap({ $0 }).max() {
            recordsList.append(ExerciseRecord(
                title: "Most Reps",
                value: "\(maxReps) reps",
                date: dateString(from: performance.date),
                icon: "repeat.circle.fill",
                iconColor: .orange
            ))
        }
        
        // Calculate volume if we have both weights and reps
        if !performance.setWeights.isEmpty && !performance.setReps.isEmpty {
            var totalVolume: Double = 0
            
            for i in 0..<min(performance.setWeights.count, performance.setReps.count) {
                if let weight = performance.setWeights[i], let reps = performance.setReps[i] {
                    totalVolume += weight * Double(reps)
                }
            }
            
            if totalVolume > 0 {
                recordsList.append(ExerciseRecord(
                    title: "Workout Volume",
                    value: "\(String(format: "%.1f", totalVolume)) kg",
                    date: dateString(from: performance.date),
                    icon: "chart.bar.fill",
                    iconColor: .green
                ))
            }
        }
        
        // Estimate 1RM if we have both weight and reps
        if let maxWeight = performance.setWeights.compactMap({ $0 }).max(),
           let reps = performance.setReps.first, let repsValue = reps, repsValue > 0 && repsValue < 10 {
            
            // Use Brzycki formula: 1RM = Weight × (36 / (37 - reps))
            let oneRM = maxWeight * (36.0 / (37.0 - Double(repsValue)))
            
            recordsList.append(ExerciseRecord(
                title: "Estimated 1RM",
                value: "\(String(format: "%.1f", oneRM)) kg",
                date: "Based on \(String(format: "%.1f", maxWeight))kg × \(repsValue) reps",
                icon: "star.circle.fill",
                iconColor: .yellow
            ))
        }
        
        return recordsList
    }
    
    private func dateString(from date: Date?) -> String {
        guard let date = date else { return "Unknown date" }
        
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                if records.isEmpty {
                    EmptyRecordsView()
                } else {
                    ForEach(records, id: \.title) { record in
                        RecordCard(record: record)
                    }
                }
            }
            .padding()
            .padding(.top, 10)
        }
    }
    
    // Simple struct to hold record data
    struct ExerciseRecord {
        let title: String
        let value: String
        let date: String
        let icon: String
        let iconColor: Color
    }
}

// Empty Records View
struct EmptyRecordsView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "chart.xyaxis.line")
                .font(.system(size: 50))
                .foregroundColor(.gray)
                .padding(.top, 40)
            
            Text("No records yet")
                .font(.headline)
                .foregroundColor(.white)
            
            Text("Complete a workout with this exercise to see your performance records.")
                .font(.subheadline)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
                .padding(.bottom, 40)
        }
    }
}

// Record Card Component
struct RecordCard: View {
    var record: ExerciseRecordsTab.ExerciseRecord
    
    var body: some View {
        HStack(spacing: 16) {
            // Icon
            Image(systemName: record.icon)
                .font(.system(size: 28))
                .foregroundColor(record.iconColor)
                .frame(width: 40)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(record.title)
                    .font(.system(size: 16))
                    .foregroundColor(.gray)
                
                Text(record.value)
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.white)
                
                Text(record.date)
                    .font(.system(size: 12))
                    .foregroundColor(.gray)
                    .padding(.top, 2)
            }
            
            Spacer()
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemGray6).opacity(0.2))
        )
    }
}
