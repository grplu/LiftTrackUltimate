import Foundation

// MARK: - Workout Statistics
struct WorkoutStatistics {
    let totalWorkouts: Int
    let totalExercises: Int
    let totalSets: Int
    let totalWeight: Double
    var totalDuration: TimeInterval = 0
    var totalCalories: Double = 0
    var lastWorkoutDate: Date?
    
    init(totalWorkouts: Int = 0,
         totalExercises: Int = 0,
         totalSets: Int = 0,
         totalWeight: Double = 0,
         totalDuration: TimeInterval = 0,
         totalCalories: Double = 0,
         lastWorkoutDate: Date? = nil) {
        self.totalWorkouts = totalWorkouts
        self.totalExercises = totalExercises
        self.totalSets = totalSets
        self.totalWeight = totalWeight
        self.totalDuration = totalDuration
        self.totalCalories = totalCalories
        self.lastWorkoutDate = lastWorkoutDate
    }
}

// MARK: - Weekly Progress
struct WeeklyProgress {
    let startDate: Date
    let endDate: Date
    let totalWorkouts: Int
    let totalExercises: Int
    let totalSets: Int
    let totalWeight: Double
    
    init(startDate: Date = Date(),
         endDate: Date = Date(),
         totalWorkouts: Int = 0,
         totalExercises: Int = 0,
         totalSets: Int = 0,
         totalWeight: Double = 0) {
        self.startDate = startDate
        self.endDate = endDate
        self.totalWorkouts = totalWorkouts
        self.totalExercises = totalExercises
        self.totalSets = totalSets
        self.totalWeight = totalWeight
    }
}

// MARK: - Monthly Progress
struct MonthlyProgress {
    let startDate: Date
    let endDate: Date
    let totalWorkouts: Int
    let totalExercises: Int
    let totalSets: Int
    let totalWeight: Double
    
    init(startDate: Date = Date(),
         endDate: Date = Date(),
         totalWorkouts: Int = 0,
         totalExercises: Int = 0,
         totalSets: Int = 0,
         totalWeight: Double = 0) {
        self.startDate = startDate
        self.endDate = endDate
        self.totalWorkouts = totalWorkouts
        self.totalExercises = totalExercises
        self.totalSets = totalSets
        self.totalWeight = totalWeight
    }
}

struct ExerciseStatistics {
    let exerciseId: UUID
    let exerciseName: String
    var totalSets: Int
    var totalReps: Int
    var totalWeight: Double
    var personalBest: Double
    var lastPerformed: Date?
    
    init(exerciseId: UUID, exerciseName: String, totalSets: Int, totalReps: Int, totalWeight: Double, personalBest: Double, lastPerformed: Date?) {
        self.exerciseId = exerciseId
        self.exerciseName = exerciseName
        self.totalSets = totalSets
        self.totalReps = totalReps
        self.totalWeight = totalWeight
        self.personalBest = personalBest
        self.lastPerformed = lastPerformed
    }
}

struct ExerciseProgress {
    let exerciseId: UUID
    let exerciseName: String
    let totalWorkouts: Int
    let weightProgress: [Double]
    let personalBest: Double
    let lastPerformed: Date?
    
    init(exerciseId: UUID, exerciseName: String, totalWorkouts: Int, weightProgress: [Double], personalBest: Double, lastPerformed: Date?) {
        self.exerciseId = exerciseId
        self.exerciseName = exerciseName
        self.totalWorkouts = totalWorkouts
        self.weightProgress = weightProgress
        self.personalBest = personalBest
        self.lastPerformed = lastPerformed
    }
} 