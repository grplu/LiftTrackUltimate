import Foundation

struct UserProfile: Codable {
    var id = UUID()
    var name: String = ""
    var age: Int = 0
    var weight: Double = 0
    var height: Double = 0
    var fitnessLevel: FitnessLevel = .beginner
    var weeklyGoal: Int = 3  // Number of workouts per week
    var preferredWorkoutDuration: TimeInterval = 3600  // 1 hour in seconds
    var achievements: [Achievement] = []
    var stats: WorkoutStats = WorkoutStats()
    
    // MARK: - Fitness Level Enum
    enum FitnessLevel: String, Codable {
        case beginner = "Beginner"
        case intermediate = "Intermediate"
        case advanced = "Advanced"
    }
    
    // Default initializer
    init() {
        // Default values are set by property initializers
    }
    
    // Custom initializer with name parameter
    init(name: String) {
        self.name = name
    }
    
    enum CodingKeys: String, CodingKey {
        case id, name, age, weight, height, fitnessLevel, weeklyGoal, preferredWorkoutDuration, achievements, stats
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        age = try container.decode(Int.self, forKey: .age)
        weight = try container.decode(Double.self, forKey: .weight)
        height = try container.decode(Double.self, forKey: .height)
        fitnessLevel = try container.decode(UserProfile.FitnessLevel.self, forKey: .fitnessLevel)
        weeklyGoal = try container.decode(Int.self, forKey: .weeklyGoal)
        preferredWorkoutDuration = try container.decode(TimeInterval.self, forKey: .preferredWorkoutDuration)
        achievements = try container.decode([Achievement].self, forKey: .achievements)
        stats = try container.decode(WorkoutStats.self, forKey: .stats)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encode(age, forKey: .age)
        try container.encode(weight, forKey: .weight)
        try container.encode(height, forKey: .height)
        try container.encode(fitnessLevel, forKey: .fitnessLevel)
        try container.encode(weeklyGoal, forKey: .weeklyGoal)
        try container.encode(preferredWorkoutDuration, forKey: .preferredWorkoutDuration)
        try container.encode(achievements, forKey: .achievements)
        try container.encode(stats, forKey: .stats)
    }
}

// MARK: - WorkoutStats
struct WorkoutStats: Codable {
    var totalWorkouts: Int = 0
    var totalDuration: TimeInterval = 0
    var averageHeartRate: Double = 0
    var caloriesBurned: Double = 0
    var totalWeight: Double = 0
    var personalBests: [String: Double] = [:]  // Exercise name to weight/time
    var weeklyProgress: [Int: Int] = [:]  // Day of week to number of workouts
}

// MARK: - Achievement
struct Achievement: Codable, Identifiable {
    var id = UUID()
    var title: String
    var description: String
    var isUnlocked: Bool
    var dateUnlocked: Date?
    var type: AchievementType
    
    init(id: UUID = UUID(), title: String, description: String, isUnlocked: Bool = false, dateUnlocked: Date? = nil, type: AchievementType) {
        self.id = id
        self.title = title
        self.description = description
        self.isUnlocked = isUnlocked
        self.dateUnlocked = dateUnlocked
        self.type = type
    }
}

// MARK: - Achievement Type Enum
enum AchievementType: String, Codable {
    case workoutCount
    case weightLifted
    case streak
    case totalWeight
    case uniqueExercises
    case perfectWorkouts
    case personalBest
} 