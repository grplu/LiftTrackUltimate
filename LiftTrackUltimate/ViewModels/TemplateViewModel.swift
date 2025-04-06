import Foundation
import Combine

class TemplateViewModel: ObservableObject {
    private let dataService: DataService
    private var cancellables = Set<AnyCancellable>()
    
    @Published var templates: [WorkoutTemplate] = []
    @Published var currentTemplate: WorkoutTemplate?
    @Published var isLoading = false
    @Published var error: Error?
    
    init(dataService: DataService = LocalDataService.shared) {
        self.dataService = dataService
        loadTemplates()
    }
    
    // MARK: - Template Management
    func loadTemplates() {
        isLoading = true
        templates = dataService.loadTemplates()
        isLoading = false
    }
    
    func createTemplate(name: String, exercises: [Exercise], icon: String) {
        // Convert Exercise objects to TemplateExercise objects
        let templateExercises = exercises.map { exercise in
            TemplateExercise(
                id: UUID(),
                exercise: exercise,
                targetSets: 3,
                targetReps: 10
            )
        }
        
        let template = WorkoutTemplate(
            id: UUID(),
            name: name,
            exercises: templateExercises,
            customIcon: icon,
            createdAt: Date(),
            lastModified: Date()
        )
        saveTemplate(template)
    }
    
    func saveTemplate(_ template: WorkoutTemplate) {
        dataService.saveTemplate(template)
        loadTemplates()
    }
    
    func updateTemplate(_ template: WorkoutTemplate) {
        var updatedTemplate = template
        updatedTemplate.lastModified = Date()
        dataService.updateTemplate(updatedTemplate)
        loadTemplates()
    }
    
    func deleteTemplate(_ template: WorkoutTemplate) {
        dataService.deleteTemplate(template)
        loadTemplates()
    }
    
    // MARK: - Template Search and Filtering
    func searchTemplates(query: String) -> [WorkoutTemplate] {
        guard !query.isEmpty else { return templates }
        return templates.filter { template in
            template.name.localizedCaseInsensitiveContains(query)
        }
    }
    
    func filterTemplates(by exercise: Exercise? = nil) -> [WorkoutTemplate] {
        guard let exercise = exercise else { return templates }
        return templates.filter { template in
            template.exercises.contains { $0.exercise.id == exercise.id }
        }
    }
    
    // MARK: - Template Statistics
    func getTemplateStats(for template: WorkoutTemplate) -> TemplateStats {
        let totalExercises = template.exercises.count
        let totalSets = template.exercises.reduce(0) { $0 + $1.targetSets }
        
        return TemplateStats(
            totalExercises: totalExercises,
            totalSets: totalSets
        )
    }
    
    // MARK: - Template Usage
    func getTemplateUsageCount(_ template: WorkoutTemplate) -> Int {
        let workouts = dataService.loadWorkouts()
        return workouts.filter { $0.templateId == template.id }.count
    }
    
    func getLastUsedDate(_ template: WorkoutTemplate) -> Date? {
        let workouts = dataService.loadWorkouts()
        return workouts
            .filter { $0.templateId == template.id }
            .sorted { $0.date > $1.date }
            .first?
            .date
    }
}

// MARK: - Supporting Types
struct TemplateStats {
    let totalExercises: Int
    let totalSets: Int
} 