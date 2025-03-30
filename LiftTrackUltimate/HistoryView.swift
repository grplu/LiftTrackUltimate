import SwiftUI

// Shared formatters at file level to avoid redeclaration issues
extension DateFormatter {
    static let dayFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "EE"
        return formatter
    }()
    
    static let monthDayFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        return formatter
    }()
    
    static let timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        return formatter
    }()
    
    static let monthYearFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter
    }()
}

struct HistoryView: View {
    @EnvironmentObject var dataManager: DataManager
    @State private var isLoading = true
    @State private var monthlyWorkouts: [String: [AppWorkout]] = [:]
    @State private var selectedMonth: String = ""
    
    var body: some View {
        ZStack {
            // Background
            Color.black.edgesIgnoringSafeArea(.all)
            
            if isLoading {
                // Simple loading indicator
                VStack {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .blue))
                        .scaleEffect(1.5)
                        .padding(.bottom, 20)
                    
                    Text("Loading your workout history...")
                        .foregroundColor(.gray)
                }
            } else if dataManager.workouts.isEmpty {
                // Empty state - no animations
                VStack(spacing: 20) {
                    Image(systemName: "calendar.badge.exclamationmark")
                        .font(.system(size: 60))
                        .foregroundColor(.gray)
                    
                    Text("No Workouts Yet")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Text("Complete your first workout to see it here.")
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                    
                    NavigationLink(destination: WorkoutView()) {
                        Text("Start a Workout")
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.blue)
                            .cornerRadius(10)
                    }
                    .padding(.top, 10)
                }
                .padding()
            } else {
                // Workouts history
                VStack(alignment: .leading, spacing: 0) {
                    // Title
                    Text("Workout History")
                        .font(.system(size: 36, weight: .bold))
                        .foregroundColor(.white)
                        .padding(.horizontal)
                        .padding(.top, 16)
                        .padding(.bottom, 16)
                    
                    // Statistics card
                    SimpleWorkoutStatsCard()
                        .padding(.horizontal)
                        .padding(.bottom, 16)
                    
                    // Main scrollable content
                    ScrollView {
                        VStack(spacing: 24) {
                            // Separate the sections in a standard VStack
                            ForEach(Array(monthlyWorkouts.keys.sorted()), id: \.self) { month in
                                if let workouts = monthlyWorkouts[month], !workouts.isEmpty {
                                    SimpleMonthSection(month: month, workouts: workouts)
                                }
                            }
                            
                            // Padding at the bottom for safe area
                            Spacer(minLength: 80)
                        }
                        .padding(.horizontal)
                    }
                }
            }
        }
        .onAppear {
            // Load data without delay
            loadWorkouts()
            isLoading = false
        }
    }
    
    private func loadWorkouts() {
        // Organize workouts by month
        var tempMonthlyWorkouts: [String: [AppWorkout]] = [:]
        
        for workout in dataManager.workouts {
            let monthYearString = DateFormatter.monthYearFormatter.string(from: workout.date)
            
            if tempMonthlyWorkouts[monthYearString] == nil {
                tempMonthlyWorkouts[monthYearString] = []
            }
            
            tempMonthlyWorkouts[monthYearString]?.append(workout)
        }
        
        // Sort workouts within each month by date (newest first)
        for (month, workouts) in tempMonthlyWorkouts {
            tempMonthlyWorkouts[month] = workouts.sorted { $0.date > $1.date }
        }
        
        monthlyWorkouts = tempMonthlyWorkouts
        
        // Set selected month to current month if workouts exist for it
        let currentMonthYear = DateFormatter.monthYearFormatter.string(from: Date())
        if tempMonthlyWorkouts[currentMonthYear] != nil {
            selectedMonth = currentMonthYear
        } else if let firstMonth = tempMonthlyWorkouts.keys.sorted().first {
            selectedMonth = firstMonth
        }
    }
}

// Simplified month section without animations
struct SimpleMonthSection: View {
    var month: String
    var workouts: [AppWorkout]
    @State private var expanded = true
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Month header
            Button(action: {
                withAnimation(.easeInOut(duration: 0.2)) {
                    expanded.toggle()
                }
            }) {
                HStack {
                    Text(month)
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    Text("\(workouts.count) workouts")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    
                    Image(systemName: expanded ? "chevron.up" : "chevron.down")
                        .foregroundColor(.gray)
                        .font(.system(size: 14, weight: .semibold))
                        .padding(6)
                        .background(Color.gray.opacity(0.2))
                        .clipShape(Circle())
                }
            }
            .buttonStyle(PlainButtonStyle())
            
            if expanded {
                // Workout cards
                ForEach(workouts) { workout in
                    NavigationLink(destination: WorkoutDetailView(workout: workout)) {
                        SimpleHistoryWorkoutCard(workout: workout)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
        }
        .padding(.vertical, 8)
        .background(Color.black)
    }
}

// Updated workout card with template icon
struct SimpleHistoryWorkoutCard: View {
    var workout: AppWorkout
    
    var body: some View {
        HStack(spacing: 16) {
            // Left column - date info
            VStack(alignment: .center, spacing: 4) {
                Text(DateFormatter.dayFormatter.string(from: workout.date))
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                
                Text(DateFormatter.monthDayFormatter.string(from: workout.date))
                    .font(.system(size: 13))
                    .foregroundColor(.gray)
                
                Text(DateFormatter.timeFormatter.string(from: workout.date))
                    .font(.system(size: 13))
                    .foregroundColor(.gray)
            }
            .frame(width: 70)
            
            // Divider
            Rectangle()
                .fill(Color.gray.opacity(0.3))
                .frame(width: 1)
                .padding(.vertical, 6)
            
            // Main content
            VStack(alignment: .leading, spacing: 8) {
                // Name row with template icon
                HStack(alignment: .center, spacing: 10) {
                    // Use the workout's icon or fall back to generic icon
                    ZStack {
                        Circle()
                            .fill(accentColor.opacity(0.2))
                            .frame(width: 32, height: 32)
                        
                        Image(systemName: workout.getIcon())
                            .font(.system(size: 14))
                            .foregroundColor(accentColor)
                    }
                    
                    Text(workout.name)
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.white)
                }
                
                // Stats row
                HStack(spacing: 16) {
                    // Exercises count
                    HStack(spacing: 4) {
                        Image(systemName: "dumbbell.fill")
                            .font(.system(size: 12))
                            .foregroundColor(.blue)
                        Text("\(workout.exercises.count)")
                            .font(.system(size: 14))
                            .foregroundColor(.gray)
                    }
                    
                    // Sets count
                    HStack(spacing: 4) {
                        Image(systemName: "repeat")
                            .font(.system(size: 12))
                            .foregroundColor(.green)
                        Text("\(workout.exercises.reduce(0) { $0 + $1.sets.count })")
                            .font(.system(size: 14))
                            .foregroundColor(.gray)
                    }
                    
                    // Duration
                    HStack(spacing: 4) {
                        Image(systemName: "clock.fill")
                            .font(.system(size: 12))
                            .foregroundColor(.orange)
                        Text(formatDuration(workout.duration))
                            .font(.system(size: 14))
                            .foregroundColor(.gray)
                    }
                }
                
                // Show notes if available
                if let notes = workout.notes, !notes.isEmpty {
                    Text(notes)
                        .font(.system(size: 12))
                        .foregroundColor(.gray)
                        .lineLimit(1)
                        .truncationMode(.tail)
                }
            }
            
            Spacer()
            
            // Right chevron
            Image(systemName: "chevron.right")
                .foregroundColor(.gray)
                .font(.system(size: 14))
        }
        .padding(16)
        .background(Color(.systemGray6).opacity(0.2))
        .cornerRadius(16)
    }
    
    private func formatDuration(_ duration: TimeInterval) -> String {
        let minutes = Int(duration) / 60
        return "\(minutes) min"
    }
    
    // Get an accent color based on the workout icon
    private var accentColor: Color {
        let icon = workout.getIcon()
        
        switch icon {
        case "heart.fill":
            return .red
        case "figure.strengthtraining.traditional":
            return .blue
        case "person.bust":
            return .purple
        case "figure.arms.open":
            return .green
        case "figure.core.training":
            return .yellow
        case "figure.walk":
            return .orange
        default:
            return .blue
        }
    }
}

// Simple stats card without animations
struct SimpleWorkoutStatsCard: View {
    @EnvironmentObject var dataManager: DataManager
    
    var body: some View {
        VStack(spacing: 16) {
            // Title
            HStack {
                Text("Your Progress")
                    .font(.headline)
                    .foregroundColor(.white)
                
                Spacer()
                
                // Time period selector
                Text("This Month")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(20)
            }
            
            // Stats row
            HStack(spacing: 0) {
                // Total workouts
                SimpleStatView(
                    value: "\(dataManager.workouts.count)",
                    label: "Workouts",
                    icon: "figure.strengthtraining.traditional",
                    color: .blue
                )
                
                // Divider
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 1, height: 40)
                
                // Total exercises
                SimpleStatView(
                    value: "\(totalExercises)",
                    label: "Exercises",
                    icon: "dumbbell.fill",
                    color: .green
                )
                
                // Divider
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 1, height: 40)
                
                // Total sets
                SimpleStatView(
                    value: "\(totalSets)",
                    label: "Sets",
                    icon: "repeat",
                    color: .orange
                )
            }
        }
        .padding(16)
        .background(Color(.systemGray6).opacity(0.2))
        .cornerRadius(16)
    }
    
    private var totalExercises: Int {
        return dataManager.workouts.reduce(0) { $0 + $1.exercises.count }
    }
    
    private var totalSets: Int {
        return dataManager.workouts.reduce(0) { total, workout in
            total + workout.exercises.reduce(0) { $0 + $1.sets.count }
        }
    }
}

// Simple stat view without animations
struct SimpleStatView: View {
    var value: String
    var label: String
    var icon: String
    var color: Color
    
    var body: some View {
        HStack(spacing: 10) {
            // Icon with background
            ZStack {
                Circle()
                    .fill(color.opacity(0.2))
                    .frame(width: 36, height: 36)
                
                Image(systemName: icon)
                    .font(.system(size: 16))
                    .foregroundColor(color)
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text(value)
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.white)
                
                Text(label)
                    .font(.caption)
                    .foregroundColor(.gray)
            }
        }
        .frame(maxWidth: .infinity)
    }
}
