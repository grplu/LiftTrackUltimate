import Foundation
import SwiftUI

// Extension to DataManager for favorites functionality
extension DataManager {
    
    // Key for storing favorite exercise IDs
    private var favoriteExercisesKey: String { "favoriteExerciseIds" }
    private var recentExercisesKey: String { "recentExerciseIds" }
    
    // MARK: - Favorite Exercises
    
    // Check if an exercise is favorited
    func isFavoriteExercise(_ exercise: Exercise) -> Bool {
        let favoriteIds = getFavoriteExerciseIds()
        return favoriteIds.contains(exercise.id)
    }
    
    // Get array of favorite exercise IDs
    func getFavoriteExerciseIds() -> [UUID] {
        guard let data = UserDefaults.standard.data(forKey: favoriteExercisesKey),
              let ids = try? JSONDecoder().decode([UUID].self, from: data) else {
            return []
        }
        return ids
    }
    
    // Get favorite exercises
    func getFavoriteExercises() -> [Exercise] {
        let favoriteIds = getFavoriteExerciseIds()
        return exercises.filter { favoriteIds.contains($0.id) }
    }
    
    // Toggle favorite status
    func toggleFavoriteExercise(_ exercise: Exercise) {
        var favoriteIds = getFavoriteExerciseIds()
        
        if let index = favoriteIds.firstIndex(of: exercise.id) {
            favoriteIds.remove(at: index)
        } else {
            favoriteIds.append(exercise.id)
        }
        
        saveFavoriteExerciseIds(favoriteIds)
    }
    
    // Save favorites to UserDefaults
    private func saveFavoriteExerciseIds(_ ids: [UUID]) {
        if let data = try? JSONEncoder().encode(ids) {
            UserDefaults.standard.set(data, forKey: favoriteExercisesKey)
        }
    }
    
    // MARK: - Recent Exercises
    
    // Track exercise usage for recents list
    func trackExerciseUsage(_ exercise: Exercise) {
        var recentIds = getRecentExerciseIds()
        
        // Remove if already in list (to move to front)
        if let index = recentIds.firstIndex(of: exercise.id) {
            recentIds.remove(at: index)
        }
        
        // Add to front of list
        recentIds.insert(exercise.id, at: 0)
        
        // Keep list to reasonable size
        if recentIds.count > 10 {
            recentIds = Array(recentIds.prefix(10))
        }
        
        saveRecentExerciseIds(recentIds)
    }
    
    // Get recent exercise IDs
    private func getRecentExerciseIds() -> [UUID] {
        guard let data = UserDefaults.standard.data(forKey: recentExercisesKey),
              let ids = try? JSONDecoder().decode([UUID].self, from: data) else {
            return []
        }
        return ids
    }
    
    // Get recent exercises
    func getRecentExercises(limit: Int = 5) -> [Exercise] {
        let recentIds = getRecentExerciseIds()
        var recentExercises: [Exercise] = []
        
        for id in recentIds {
            if let exercise = exercises.first(where: { $0.id == id }) {
                recentExercises.append(exercise)
                if recentExercises.count >= limit {
                    break
                }
            }
        }
        
        return recentExercises
    }
    
    // Save recent exercise IDs
    private func saveRecentExerciseIds(_ ids: [UUID]) {
        if let data = try? JSONEncoder().encode(ids) {
            UserDefaults.standard.set(data, forKey: recentExercisesKey)
        }
    }
    
    // MARK: - Template Relations
    
    // Check if exercise is used in any templates
    func isExerciseInTemplates(_ exercise: Exercise) -> Bool {
        return templates.contains { template in
            template.exercises.contains { $0.exercise.id == exercise.id }
        }
    }
    
    // Get all templates using a specific exercise
    func getTemplatesContainingExercise(_ exercise: Exercise) -> [WorkoutTemplate] {
        return templates.filter { template in
            template.exercises.contains { $0.exercise.id == exercise.id }
        }
    }
}
