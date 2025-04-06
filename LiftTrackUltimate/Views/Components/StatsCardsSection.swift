import SwiftUI

struct StatsCardsSection: View {
    let profile: UserProfile
    let animate: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Statistics")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.white)
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 16) {
                StatCard(
                    title: "Total Workouts",
                    value: "\(profile.stats.totalWorkouts)",
                    icon: "figure.walk",
                    color: .blue,
                    animate: animate
                )
                
                StatCard(
                    title: "Total Hours",
                    value: String(format: "%.1f", profile.stats.totalDuration / 3600),
                    icon: "clock.fill",
                    color: .green,
                    animate: animate
                )
                
                StatCard(
                    title: "Avg Heart Rate",
                    value: String(format: "%.0f", profile.stats.averageHeartRate),
                    icon: "heart.fill",
                    color: .red,
                    animate: animate
                )
                
                StatCard(
                    title: "Calories",
                    value: String(format: "%.0f", profile.stats.caloriesBurned),
                    icon: "flame.fill",
                    color: .orange,
                    animate: animate
                )
            }
        }
        .padding()
        .background(Color.black.opacity(0.3))
        .cornerRadius(15)
    }
}

struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    let animate: Bool
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title)
                .foregroundColor(color)
            
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.white)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color.black.opacity(0.5))
        .cornerRadius(10)
        .scaleEffect(animate ? 1 : 0.8)
        .animation(.spring(response: 0.5, dampingFraction: 0.6), value: animate)
    }
} 