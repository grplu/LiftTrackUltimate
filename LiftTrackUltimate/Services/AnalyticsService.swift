import Foundation
import Combine

class AnalyticsService: ObservableObject {
    static let shared = AnalyticsService()
    
    private let dataService: DataService
    private var cancellables = Set<AnyCancellable>()
    
    @Published private(set) var workoutStats: WorkoutStatistics?
    @Published private(set) var exerciseStats: [UUID: ExerciseStatistics] = [:]
    @Published private(set) var weeklyProgress: WeeklyProgress?
    @Published private(set) var monthlyProgress: MonthlyProgress?
    
    private init(dataService: DataService = LocalDataService.shared) {
        self.dataService = dataService
        setupObservers()
        updateStatistics()
    }
    
    // MARK: - Statistics Management
    private func setupObservers() {
        NotificationCenter.default.publisher(for: .workoutDataChanged)
            .sink { [weak self] _ in
                self?.updateStatistics()
            }
            .store(in: &cancellables)
    }
    
    private func updateStatistics() {
        let workouts = dataService.loadWorkouts()
        updateWorkoutStatistics(workouts)
        updateExerciseStatistics(workouts)
        updateProgressStatistics(workouts)
    }
    
    private func updateWorkoutStatistics(_ workouts: [AppWorkout]) {
        let completedWorkouts = workouts.filter { !$0.exercises.isEmpty }
        
        let totalWorkouts = completedWorkouts.count
        let totalExercises = completedWorkouts.reduce(0) { $0 + $1.exercises.count }
        let totalSets = completedWorkouts.reduce(0) { $0 + $1.exercises.reduce(0) { $0 + $1.sets.count } }
        let totalWeight = completedWorkouts.reduce(0.0) { total, workout in
            total + workout.exercises.reduce(0.0) { $0 + $1.sets.reduce(0.0) { $0 + ($1.weight ?? 0.0) } }
        }
        
        workoutStats = WorkoutStatistics(
            totalWorkouts: totalWorkouts,
            totalExercises: totalExercises,
            totalSets: totalSets,
            totalWeight: totalWeight
        )
    }
    
    private func updateExerciseStatistics(_ workouts: [AppWorkout]) {
        var stats: [UUID: ExerciseStatistics] = [:]
        
        for workout in workouts {
            for exercise in workout.exercises {
                let exerciseId = exercise.exercise.id
                var exerciseStats = stats[exerciseId] ?? ExerciseStatistics(
                    exerciseId: exerciseId,
                    exerciseName: exercise.exercise.name,
                    totalSets: 0,
                    totalReps: 0,
                    totalWeight: 0,
                    personalBest: 0,
                    lastPerformed: nil
                )
                
                exerciseStats.totalSets += exercise.sets.count
                exerciseStats.totalReps += exercise.sets.reduce(0) { $0 + $1.reps }
                exerciseStats.totalWeight += exercise.sets.reduce(0.0) { $0 + ($1.weight ?? 0.0) }
                
                let maxWeight = exercise.sets.map { $0.weight ?? 0.0 }.max() ?? 0
                exerciseStats.personalBest = max(exerciseStats.personalBest, maxWeight)
                
                if let lastDate = exerciseStats.lastPerformed {
                    exerciseStats.lastPerformed = max(lastDate, workout.date)
                } else {
                    exerciseStats.lastPerformed = workout.date
                }
                
                stats[exerciseId] = exerciseStats
            }
        }
        
        exerciseStats = stats
    }
    
    private func updateProgressStatistics(_ workouts: [AppWorkout]) {
        let calendar = Calendar.current
        let today = Date()
        
        // Weekly progress
        let weekStart = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: today))!
        let weekEnd = calendar.date(byAdding: .day, value: 7, to: weekStart)!
        
        let weeklyWorkouts = workouts.filter { workout in
            workout.date >= weekStart && workout.date < weekEnd
        }
        
        weeklyProgress = WeeklyProgress(
            startDate: weekStart,
            endDate: weekEnd,
            totalWorkouts: weeklyWorkouts.count,
            totalExercises: weeklyWorkouts.reduce(0) { $0 + $1.exercises.count },
            totalSets: weeklyWorkouts.reduce(0) { $0 + $1.exercises.reduce(0) { $0 + $1.sets.count } },
            totalWeight: weeklyWorkouts.reduce(0.0) { total, workout in
                total + workout.exercises.reduce(0.0) { $0 + $1.sets.reduce(0.0) { $0 + ($1.weight ?? 0.0) } }
            }
        )
        
        // Monthly progress
        let monthStart = calendar.date(from: calendar.dateComponents([.year, .month], from: today))!
        let monthEnd = calendar.date(byAdding: .month, value: 1, to: monthStart)!
        
        let monthlyWorkouts = workouts.filter { workout in
            workout.date >= monthStart && workout.date < monthEnd
        }
        
        monthlyProgress = MonthlyProgress(
            startDate: monthStart,
            endDate: monthEnd,
            totalWorkouts: monthlyWorkouts.count,
            totalExercises: monthlyWorkouts.reduce(0) { $0 + $1.exercises.count },
            totalSets: monthlyWorkouts.reduce(0) { $0 + $1.exercises.reduce(0) { $0 + $1.sets.count } },
            totalWeight: monthlyWorkouts.reduce(0.0) { total, workout in
                total + workout.exercises.reduce(0.0) { $0 + $1.sets.reduce(0.0) { $0 + ($1.weight ?? 0.0) } }
            }
        )
    }
    
    // MARK: - Public Methods
    func getExerciseProgress(_ exerciseId: UUID) -> ExerciseProgress? {
        guard let stats = exerciseStats[exerciseId] else { return nil }
        
        let workouts = dataService.loadWorkouts()
        let exerciseWorkouts = workouts.filter { workout in
            workout.exercises.contains { $0.exercise.id == exerciseId }
        }
        
        let weightProgress = exerciseWorkouts.map { workout in
            workout.exercises.first { $0.exercise.id == exerciseId }?
                .sets.map { $0.weight ?? 0.0 }
                .max() ?? 0.0
        }
        
        return ExerciseProgress(
            exerciseId: exerciseId,
            exerciseName: stats.exerciseName,
            totalWorkouts: exerciseWorkouts.count,
            weightProgress: weightProgress,
            personalBest: stats.personalBest,
            lastPerformed: stats.lastPerformed
        )
    }
    
    func getWorkoutFrequency() -> [Date: Int] {
        let workouts = dataService.loadWorkouts()
        let calendar = Calendar.current
        
        var frequency: [Date: Int] = [:]
        
        for workout in workouts {
            let day = calendar.startOfDay(for: workout.date)
            frequency[day, default: 0] += 1
        }
        
        return frequency
    }
    
    func getMostFrequentExercises(limit: Int = 5) -> [ExerciseStatistics] {
        Array(exerciseStats.values)
            .sorted { $0.totalSets > $1.totalSets }
            .prefix(limit)
            .map { $0 }
    }
    
    func getPersonalBests() -> [ExerciseStatistics] {
        Array(exerciseStats.values)
            .sorted { $0.personalBest > $1.personalBest }
            .filter { $0.personalBest > 0 }
            .map { $0 }
    }
} 