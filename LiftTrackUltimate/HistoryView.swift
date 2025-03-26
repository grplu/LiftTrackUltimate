import SwiftUI

struct HistoryView: View {
    @EnvironmentObject var dataManager: DataManager
    @State private var isLoading = true
    @State private var monthlyWorkouts: [String: [AppWorkout]] = [:]
    @State private var selectedMonth: String = ""
    @State private var animateEntrance = false
    
    var body: some View {
        // REMOVED NavigationView - THIS IS THE KEY CHANGE
        ZStack {
            // Background
            Color.black.edgesIgnoringSafeArea(.all)
            
            if isLoading {
                // Loading state with dumbbell animation
                VStack {
                    LoadingDumbbellAnimation()
                        .frame(width: 100, height: 100)
                        .padding(.bottom, 20)
                    
                    Text("Loading your workout history...")
                        .foregroundColor(.gray)
                }
            } else if dataManager.workouts.isEmpty {
                // Empty state
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
                .opacity(animateEntrance ? 1 : 0)
                .offset(y: animateEntrance ? 0 : 20)
                .animation(.spring(response: 0.6, dampingFraction: 0.8), value: animateEntrance)
            } else {
                // Workouts history
                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        // Title with animation
                        Text("Workout History")
                            .font(.system(size: 36, weight: .bold))
                            .foregroundColor(.white)
                            .padding(.horizontal)
                            .padding(.top, 16)
                            .opacity(animateEntrance ? 1 : 0)
                            .offset(y: animateEntrance ? 0 : -20)
                            .animation(.spring(response: 0.6, dampingFraction: 0.8), value: animateEntrance)
                        
                        // Statistics card
                        WorkoutStatsCard()
                            .padding(.horizontal)
                            .opacity(animateEntrance ? 1 : 0)
                            .offset(y: animateEntrance ? 0 : 30)
                            .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.1), value: animateEntrance)
                        
                        // Monthly sections
                        ForEach(Array(monthlyWorkouts.keys.sorted().enumerated()), id: \.element) { index, month in
                            if let workouts = monthlyWorkouts[month], !workouts.isEmpty {
                                MonthSection(month: month, workouts: workouts, index: index)
                                    .opacity(animateEntrance ? 1 : 0)
                                    .offset(y: animateEntrance ? 0 : 40)
                                    .animation(
                                        .spring(response: 0.6, dampingFraction: 0.8)
                                        .delay(0.2 + Double(index) * 0.1),
                                        value: animateEntrance
                                    )
                            }
                        }
                        
                        Spacer(minLength: 80)
                    }
                }
            }
        }
        .onAppear {
            // Show loading animation briefly
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                loadWorkouts()
                
                // Animate entrance after data is loaded
                withAnimation {
                    isLoading = false
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    animateEntrance = true
                }
            }
        }
    }
    
    private func loadWorkouts() {
        // Organize workouts by month
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMM yyyy"
        
        var tempMonthlyWorkouts: [String: [AppWorkout]] = [:]
        
        for workout in dataManager.workouts {
            let monthYearString = dateFormatter.string(from: workout.date)
            
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
        let currentMonthYear = dateFormatter.string(from: Date())
        if tempMonthlyWorkouts[currentMonthYear] != nil {
            selectedMonth = currentMonthYear
        } else if let firstMonth = tempMonthlyWorkouts.keys.sorted().first {
            selectedMonth = firstMonth
        }
    }
}

struct MonthSection: View {
    var month: String
    var workouts: [AppWorkout]
    var index: Int
    @State private var expanded = true
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Month header
            Button(action: {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
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
            .padding(.horizontal)
            
            if expanded {
                // Workout cards
                ForEach(Array(workouts.enumerated()), id: \.element.id) { index, workout in
                    NavigationLink(destination: WorkoutDetailView(workout: workout)) {
                        HistoryWorkoutCard(workout: workout, index: index)
                            .padding(.horizontal)
                    }
                    .buttonStyle(PlainButtonStyle())
                    .transition(.asymmetric(
                        insertion: .opacity.combined(with: .scale(scale: 0.95).combined(with: .offset(y: 20))),
                        removal: .opacity.combined(with: .scale(scale: 0.95).combined(with: .offset(y: 20)))
                    ))
                }
            }
        }
    }
}

struct HistoryWorkoutCard: View {
    var workout: AppWorkout
    var index: Int
    @State var appear = false  // Removed 'private' to fix accessibility error
    init(workout: AppWorkout, index: Int) {
            self.workout = workout
            self.index = index
        }
    
    var body: some View {
        HStack(spacing: 16) {
            // Left column - date info
            VStack(alignment: .center, spacing: 4) {
                Text(dayFormatter.string(from: workout.date))
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                
                Text(monthDayFormatter.string(from: workout.date))
                    .font(.system(size: 13))
                    .foregroundColor(.gray)
                
                Text(timeFormatter.string(from: workout.date))
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
                Text(workout.name)
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.white)
                
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
            }
            
            Spacer()
            
            // Right chevron
            Image(systemName: "chevron.right")
                .foregroundColor(.gray)
                .font(.system(size: 14))
        }
        .padding(16)
        .background(
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(.systemGray6).opacity(0.3),
                    Color(.systemGray6).opacity(0.2)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .cornerRadius(16)
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.1 * Double(index))) {
                appear = true
            }
        }
    }
    
    private var dayFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "EE"
        return formatter
    }()
    
    private var monthDayFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        return formatter
    }()
    
    private var timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        return formatter
    }()
    
    private func formatDuration(_ duration: TimeInterval) -> String {
        let minutes = Int(duration) / 60
        return "\(minutes) min"
    }
}

struct WorkoutStatsCard: View {
    @EnvironmentObject var dataManager: DataManager
    @State private var appear = false
    
    var body: some View {
        VStack(spacing: 16) {
            // Title
            HStack {
                Text("Your Progress")
                    .font(.headline)
                    .foregroundColor(.white)
                
                Spacer()
                
                // Time period selector (could be functional in the future)
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
                statView(
                    value: "\(dataManager.workouts.count)",
                    label: "Workouts",
                    icon: "figure.strengthtraining.traditional",
                    color: .blue,
                    delay: 0.1
                )
                
                // Divider
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 1, height: 40)
                
                // Total exercises
                statView(
                    value: "\(totalExercises)",
                    label: "Exercises",
                    icon: "dumbbell.fill",
                    color: .green,
                    delay: 0.2
                )
                
                // Divider
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 1, height: 40)
                
                // Total sets
                statView(
                    value: "\(totalSets)",
                    label: "Sets",
                    icon: "repeat",
                    color: .orange,
                    delay: 0.3
                )
            }
        }
        .padding(16)
        .background(Color(.systemGray6).opacity(0.2))
        .cornerRadius(16)
        .onAppear {
            withAnimation(.easeOut(duration: 0.3)) {
                appear = true
            }
        }
    }
    
    private var totalExercises: Int {
        return dataManager.workouts.reduce(0) { $0 + $1.exercises.count }
    }
    
    private var totalSets: Int {
        return dataManager.workouts.reduce(0) { total, workout in
            total + workout.exercises.reduce(0) { $0 + $1.sets.count }
        }
    }
    
    private func statView(value: String, label: String, icon: String, color: Color, delay: Double) -> some View {
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
            .scaleEffect(appear ? 1 : 0.5)
            .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(delay), value: appear)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(value)
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.white)
                    .opacity(appear ? 1 : 0)
                    .animation(.easeOut(duration: 0.3).delay(delay + 0.1), value: appear)
                
                Text(label)
                    .font(.caption)
                    .foregroundColor(.gray)
                    .opacity(appear ? 1 : 0)
                    .animation(.easeOut(duration: 0.3).delay(delay + 0.2), value: appear)
            }
        }
        .frame(maxWidth: .infinity)
    }
}

// Renamed to avoid conflict with the one in WorkoutDetailView
struct LoadingDumbbellAnimation: View {
    @State private var rotate = false
    
    var body: some View {
        ZStack {
            // Left weight
            Circle()
                .fill(LinearGradient(
                    gradient: Gradient(colors: [Color.blue.opacity(0.7), Color.blue.opacity(0.5)]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ))
                .frame(width: 50, height: 50)
                .offset(x: -40)
            
            // Bar
            RoundedRectangle(cornerRadius: 6)
                .fill(LinearGradient(
                    gradient: Gradient(colors: [Color.gray.opacity(0.8), Color.gray.opacity(0.6)]),
                    startPoint: .top,
                    endPoint: .bottom
                ))
                .frame(width: 80, height: 12)
            
            // Right weight
            Circle()
                .fill(LinearGradient(
                    gradient: Gradient(colors: [Color.blue.opacity(0.7), Color.blue.opacity(0.5)]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ))
                .frame(width: 50, height: 50)
                .offset(x: 40)
        }
        .shadow(color: Color.blue.opacity(0.3), radius: 10, x: 0, y: 5)
        .rotationEffect(Angle(degrees: rotate ? 10 : -10))
        .animation(Animation.easeInOut(duration: 1.2).repeatForever(autoreverses: true), value: rotate)
        .onAppear {
            rotate = true
        }
    }
}
