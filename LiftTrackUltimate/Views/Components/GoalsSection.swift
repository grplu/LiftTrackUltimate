import SwiftUI

struct GoalsSection: View {
    let profile: UserProfile
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Goals")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.white)
            
            VStack(spacing: 12) {
                GoalRow(
                    title: "Weekly Workouts",
                    value: "\(profile.weeklyGoal)",
                    icon: "calendar",
                    progress: Double(profile.stats.weeklyProgress.values.reduce(0, +)) / Double(profile.weeklyGoal)
                )
                
                GoalRow(
                    title: "Workout Duration",
                    value: String(format: "%.0f min", profile.preferredWorkoutDuration / 60),
                    icon: "clock",
                    progress: profile.stats.totalDuration > 0 ? min(1.0, profile.stats.totalDuration / profile.preferredWorkoutDuration) : 0
                )
            }
        }
        .padding()
        .background(Color.black.opacity(0.3))
        .cornerRadius(15)
    }
}

struct GoalRow: View {
    let title: String
    let value: String
    let icon: String
    let progress: Double
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.blue)
                .frame(width: 30)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline)
                    .foregroundColor(.white)
                
                Text(value)
                    .font(.headline)
                    .foregroundColor(.white)
            }
            
            Spacer()
            
            CircularProgressView(progress: progress)
                .frame(width: 30, height: 30)
        }
        .padding()
        .background(Color.black.opacity(0.5))
        .cornerRadius(10)
    }
}

struct CircularProgressView: View {
    let progress: Double
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(lineWidth: 4)
                .opacity(0.3)
                .foregroundColor(.blue)
            
            Circle()
                .trim(from: 0, to: CGFloat(min(progress, 1.0)))
                .stroke(style: StrokeStyle(lineWidth: 4, lineCap: .round, lineJoin: .round))
                .foregroundColor(.blue)
                .rotationEffect(Angle(degrees: 270))
                .animation(.linear, value: progress)
        }
    }
} 