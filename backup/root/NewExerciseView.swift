import SwiftUI
import UIKit  // For UIApplication access 

// Custom extension to help with color opacity ambiguity 

private func saveExercise() {
    let newExercise = Exercise(
        id: UUID(),
        name: name,
        category: selectedCategory.rawValue,
        muscleGroups: Array(selectedMuscleGroups).map { $0.rawValue },
        instructions: instructions.isEmpty ? nil : instructions,
        isFavorite: false,
        equipment: equipment.isEmpty ? nil : equipment
    )
    
    dataManager.saveExercise(newExercise)
    dismiss()
} 