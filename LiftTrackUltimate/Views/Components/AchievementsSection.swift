import SwiftUI

struct AchievementsSection: View {
    var profile: UserProfile
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Achievements")
                .font(.headline)
                .foregroundColor(.primary)
            
            if profile.achievements.isEmpty {
                Text("No achievements yet")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            } else {
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 160))], spacing: 16) {
                    ForEach(profile.achievements) { achievement in
                        AchievementCard(achievement: achievement)
                    }
                }
            }
        }
        .padding()
    }
}

struct AchievementCard: View {
    var achievement: Achievement
    private let dateFormatter = DateFormatter()
    
    init(achievement: Achievement) {
        self.achievement = achievement
        dateFormatter.dateStyle = .medium
    }
    
    var body: some View {
        VStack(alignment: .center) {
            Image(systemName: iconForType(achievement.type))
                .font(.title2)
                .foregroundColor(achievement.isUnlocked ? .yellow : .gray)
                .padding(.bottom, 4)
                
            Text(achievement.title)
                .font(.caption)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
            
            Text(achievement.description)
                .font(.caption)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
            
            if let date = achievement.dateUnlocked {
                Text(dateFormatter.string(from: date))
                    .font(.caption2)
                    .foregroundColor(.gray)
            }
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color.black.opacity(0.5))
        .cornerRadius(10)
        .opacity(achievement.isUnlocked ? 1 : 0.6)
    }
    
    func iconForType(_ type: AchievementType) -> String {
        switch type {
        case .workoutCount:
            return "figure.walk"
        case .weightLifted:
            return "dumbbell.fill"
        case .streak:
            return "flame.fill"
        case .totalWeight:
            return "weight.scale"
        case .uniqueExercises:
            return "square.grid.2x2.fill"
        case .perfectWorkouts:
            return "checkmark.seal.fill"
        case .personalBest:
            return "star.fill"
        }
    }
} 