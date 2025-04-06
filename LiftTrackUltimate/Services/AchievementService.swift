import Foundation
import Combine

class AchievementService: ObservableObject {
    static let shared = AchievementService()
    
    private let dataService: DataService
    private let notificationService: NotificationService
    private var cancellables = Set<AnyCancellable>()
    
    @Published private(set) var achievements: [Achievement] = []
    @Published private(set) var progress: [String: Double] = [:]
    
    private init(dataService: DataService = LocalDataService.shared,
                notificationService: NotificationService = .shared) {
        self.dataService = dataService
        self.notificationService = notificationService
        loadAchievements()
        setupObservers()
    }
    
    // MARK: - Achievement Management
    private func loadAchievements() {
        achievements = [
            Achievement(
                id: UUID(),
                title: "First Workout",
                description: "Complete your first workout",
                isUnlocked: false,
                type: .workoutCount
            ),
            Achievement(
                id: UUID(),
                title: "3 Day Streak",
                description: "Complete workouts for 3 consecutive days",
                isUnlocked: false,
                type: .streak
            ),
            Achievement(
                id: UUID(),
                title: "Weight Warrior",
                description: "Lift a total of 1000kg across all workouts",
                isUnlocked: false,
                type: .totalWeight
            ),
            Achievement(
                id: UUID(),
                title: "Exercise Explorer",
                description: "Try 10 different exercises",
                isUnlocked: false,
                type: .uniqueExercises
            ),
            Achievement(
                id: UUID(),
                title: "Perfect Form",
                description: "Complete 5 workouts with all exercises performed correctly",
                isUnlocked: false,
                type: .perfectWorkouts
            )
        ]
    }
    
    private func setupObservers() {
        NotificationCenter.default.publisher(for: .workoutDataDidChange)
            .sink { [weak self] _ in
                self?.updateProgress()
            }
            .store(in: &cancellables)
    }
    
    private func updateProgress() {
        let workouts = dataService.loadWorkouts()
        
        // Calculate various metrics
        let workoutCount = workouts.count
        let streak = calculateWorkoutStreak(workouts)
        let uniqueExercises = Set(workouts.flatMap { $0.exercises.map { $0.name } }).count
        var totalWeight = 0.0
        for workout in workouts {
            for exercise in workout.exercises {
                for set in exercise.sets {
                    totalWeight += (set.weight ?? 0.0)
                }
            }
        }
        let perfectWorkouts = workouts.filter { workout in
            workout.exercises.allSatisfy { $0.sets.allSatisfy { $0.formQuality == .perfect } }
        }.count
        
        // Update progress dictionary
        progress = [
            "workoutCount": Double(workoutCount),
            "streak": Double(streak),
            "uniqueExercises": Double(uniqueExercises),
            "totalWeight": totalWeight,
            "perfectWorkouts": Double(perfectWorkouts)
        ]
        
        // Check for newly unlocked achievements
        checkAchievements()
    }
    
    private func calculateWorkoutStreak(_ workouts: [AppWorkout]) -> Int {
        guard !workouts.isEmpty else { return 0 }
        
        let calendar = Calendar.current
        let sortedDates = workouts.map { $0.date }.sorted()
        var currentStreak = 1
        var maxStreak = 1
        
        for i in 1..<sortedDates.count {
            let previousDate = calendar.startOfDay(for: sortedDates[i - 1])
            let currentDate = calendar.startOfDay(for: sortedDates[i])
            
            if calendar.dateComponents([.day], from: previousDate, to: currentDate).day == 1 {
                currentStreak += 1
                maxStreak = max(maxStreak, currentStreak)
            } else if calendar.dateComponents([.day], from: previousDate, to: currentDate).day != 0 {
                currentStreak = 1
            }
        }
        
        return maxStreak
    }
    
    private func checkAchievements() {
        for achievement in achievements {
            if !isAchievementUnlocked(achievement) && checkAchievement(achievement) {
                unlockAchievement(achievement)
            }
        }
    }
    
    private func isAchievementUnlocked(_ achievement: Achievement) -> Bool {
        achievement.isUnlocked
    }
    
    private func checkAchievement(_ achievement: Achievement) -> Bool {
        guard let currentProgress = progress[achievement.type.rawValue] else { return false }
        
        let requirement: Double
        switch achievement.type {
        case .workoutCount:
            requirement = 1
        case .streak:
            requirement = 3
        case .totalWeight:
            requirement = 1000
        case .uniqueExercises:
            requirement = 10
        case .perfectWorkouts:
            requirement = 5
        case .weightLifted:
            requirement = 500
        case .personalBest:
            requirement = 1
        }
        
        return currentProgress >= requirement
    }
    
    private func unlockAchievement(_ achievement: Achievement) {
        if let index = achievements.firstIndex(where: { $0.id == achievement.id }) {
            var updatedAchievement = achievement
            updatedAchievement.isUnlocked = true
            updatedAchievement.dateUnlocked = Date()
            achievements[index] = updatedAchievement
        }
        
        notificationService.scheduleAchievementNotification(
            title: achievement.title,
            description: achievement.description
        )
    }
    
    // MARK: - Public Methods
    func getProgress(for achievementType: AchievementType) -> Double {
        progress[achievementType.rawValue] ?? 0.0
    }
    
    func getUnlockedAchievements() -> [Achievement] {
        achievements.filter { isAchievementUnlocked($0) }
    }
    
    func getLockedAchievements() -> [Achievement] {
        achievements.filter { !isAchievementUnlocked($0) }
    }
} 