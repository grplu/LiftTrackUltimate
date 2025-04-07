import Foundation

// A dedicated class to handle storage for template properties
public class TemplateStorageManager {
    public static let shared = TemplateStorageManager()
    
    private let weightKey = "templateExerciseWeight"
    private var weightCache: [UUID: Double] = [:]
    
    private init() {
        // Private initializer to enforce singleton pattern
    }
    
    // MARK: - Icon Color Storage
    
    public func getIconColor(for template: WorkoutTemplate) -> String? {
        return UserDefaults.standard.string(forKey: "template_color_\(template.id.uuidString)")
    }
    
    public func setIconColor(_ color: String?, for template: WorkoutTemplate) {
        if let color = color {
            UserDefaults.standard.set(color, forKey: "template_color_\(template.id.uuidString)")
        } else {
            UserDefaults.standard.removeObject(forKey: "template_color_\(template.id.uuidString)")
        }
    }
    
    // MARK: - Weight Storage
    
    // Save target weight for a template exercise
    public func saveTargetWeight(_ weight: Double?, for exercise: TemplateExercise) {
        guard let weight = weight else {
            weightCache.removeValue(forKey: exercise.id)
            return
        }
        
        weightCache[exercise.id] = weight
    }
    
    // Get target weight for a template exercise
    public func getTargetWeight(for exercise: TemplateExercise) -> Double? {
        return weightCache[exercise.id]
    }
    
    // Clear all cached weights
    public func clearWeightCache() {
        weightCache.removeAll()
    }
} 