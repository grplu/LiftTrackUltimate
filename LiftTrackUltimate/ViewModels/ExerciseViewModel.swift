import Foundation
import Combine

class ExerciseViewModel: ObservableObject {
    private let dataService: DataService
    private var cancellables = Set<AnyCancellable>()
    
    @Published var exercises: [Exercise] = []
    @Published var favoriteExercises: [Exercise] = []
    @Published var isLoading = false
    @Published var error: Error?
    
    init(dataService: DataService = LocalDataService.shared) {
        self.dataService = dataService
        loadExercises()
    }
    
    // MARK: - Exercise Management
    func loadExercises() {
        isLoading = true
        exercises = dataService.loadExercises()
        updateFavoriteExercises()
        isLoading = false
    }
    
    func saveExercise(_ exercise: Exercise) {
        dataService.saveExercise(exercise)
        loadExercises()
    }
    
    func updateExercise(_ exercise: Exercise) {
        dataService.updateExercise(exercise)
        loadExercises()
    }
    
    func deleteExercise(_ exercise: Exercise) {
        dataService.deleteExercise(exercise)
        loadExercises()
    }
    
    // MARK: - Favorite Exercises
    private func updateFavoriteExercises() {
        favoriteExercises = exercises.filter { $0.isFavorite }
    }
    
    func toggleFavorite(_ exercise: Exercise) {
        var updatedExercise = exercise
        updatedExercise.isFavorite.toggle()
        updateExercise(updatedExercise)
    }
    
    // MARK: - Exercise Performance
    func getExercisePerformance(_ exercise: Exercise) -> ExercisePerformance? {
        let performances = dataService.loadExercisePerformances()
        return performances.first { $0.exerciseId == exercise.id }
    }
    
    func updateExercisePerformance(_ performance: ExercisePerformance) {
        let exercise = Exercise(id: performance.exerciseId,
                              name: "",
                              category: "",
                              muscleGroups: [],
                              instructions: nil,
                              isFavorite: false,
                              equipment: nil)
        
        if getExercisePerformance(exercise) != nil {
            dataService.updateExercisePerformance(performance)
        } else {
            dataService.saveExercisePerformance(performance)
        }
    }
    
    // MARK: - Exercise Search and Filtering
    func searchExercises(query: String) -> [Exercise] {
        guard !query.isEmpty else { return exercises }
        return exercises.filter { exercise in
            exercise.name.localizedCaseInsensitiveContains(query) ||
            exercise.category.localizedCaseInsensitiveContains(query) ||
            exercise.muscleGroups.contains { $0.localizedCaseInsensitiveContains(query) }
        }
    }
    
    func filterExercises(by category: String? = nil, muscleGroups: [String] = [], equipment: [String] = []) -> [Exercise] {
        exercises.filter { exercise in
            let categoryMatch = category == nil || exercise.category == category
            let muscleGroupMatch = muscleGroups.isEmpty || !Set(exercise.muscleGroups).isDisjoint(with: Set(muscleGroups))
            let equipmentMatch = equipment.isEmpty || (exercise.equipment != nil && !Set([exercise.equipment!]).isDisjoint(with: Set(equipment)))
            return categoryMatch && muscleGroupMatch && equipmentMatch
        }
    }
    
    // MARK: - Exercise Categories
    var availableCategories: [String] {
        Array(Set(exercises.map { $0.category })).sorted()
    }
    
    var availableMuscleGroups: [String] {
        Array(Set(exercises.flatMap { $0.muscleGroups })).sorted()
    }
    
    var availableEquipment: [String] {
        Array(Set(exercises.compactMap { $0.equipment })).sorted()
    }
} 