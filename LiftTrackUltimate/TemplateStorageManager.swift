import Foundation

// A dedicated class to handle storage for template properties
class TemplateStorageManager {
    static let shared = TemplateStorageManager()
    
    private init() {}
    
    // MARK: - Icon Color Storage
    
    func getIconColor(for template: WorkoutTemplate) -> String? {
        return UserDefaults.standard.string(forKey: "template_color_\(template.id.uuidString)")
    }
    
    func setIconColor(_ color: String?, for template: WorkoutTemplate) {
        if let color = color {
            UserDefaults.standard.set(color, forKey: "template_color_\(template.id.uuidString)")
        } else {
            UserDefaults.standard.removeObject(forKey: "template_color_\(template.id.uuidString)")
        }
    }
    
    // MARK: - Weight Storage
    
    func getTargetWeight(for exercise: TemplateExercise) -> Double? {
        let key = "template_exercise_weight_\(exercise.id.uuidString)"
        return UserDefaults.standard.object(forKey: key) as? Double
    }
    
    func setTargetWeight(_ weight: Double?, for exercise: TemplateExercise) {
        let key = "template_exercise_weight_\(exercise.id.uuidString)"
        if let weight = weight {
            UserDefaults.standard.set(weight, forKey: key)
        } else {
            UserDefaults.standard.removeObject(forKey: key)
        }
    }
}
