import Foundation
import SwiftUI

// This extension file contains DataManager functions for handling template icons

extension DataManager {
    // Create a workout from a template, preserving the template icon
    func createWorkoutFromTemplate(_ template: WorkoutTemplate) -> AppWorkout {
        // Create workout exercises from template exercises
        var workoutExercises: [WorkoutExercise] = []
        
        for templateExercise in template.exercises {
            // Create sets based on template target sets and reps
            var sets: [ExerciseSet] = []
            for _ in 0..<templateExercise.targetSets {
                // Check for saved performance data for this exercise
                let lastPerformance = getLastPerformance(for: templateExercise.exercise)
                
                // Use performance data or template data
                let reps = templateExercise.targetReps ?? lastPerformance?.lastUsedReps ?? 10
                let weight = lastPerformance?.lastUsedWeight
                
                let set = ExerciseSet(
                    reps: reps,
                    weight: weight,
                    completed: false
                )
                sets.append(set)
            }
            
            let workoutExercise = WorkoutExercise(
                exercise: templateExercise.exercise,
                sets: sets
            )
            
            workoutExercises.append(workoutExercise)
        }
        
        // Create workout with template ID and icon
        let workout = AppWorkout(
            name: template.name,
            date: Date(),
            duration: 0, // Will be updated as workout progresses
            exercises: workoutExercises,
            templateId: template.id,
            templateIcon: template.customIcon // Store the template icon
        )
        
        return workout
    }
    
    // Helper function to get template icon for display consistency across the app
    func getTemplateIcon(template: WorkoutTemplate) -> String {
        // If user has selected a custom icon, use that
        if let customIcon = template.customIcon, !customIcon.isEmpty {
            return customIcon
        }
        
        // Otherwise fall back to the auto-determined one based on muscle groups
        return determineMuscleBasedIcon(for: template)
    }
    
    // Determine icon based on primary muscle group
    func determineMuscleBasedIcon(for template: WorkoutTemplate) -> String {
        // Count occurrences of each muscle group
        var muscleGroupCounts: [String: Int] = [:]
        
        for exerciseTemplate in template.exercises {
            for muscleGroup in exerciseTemplate.exercise.muscleGroups {
                muscleGroupCounts[muscleGroup, default: 0] += 1
            }
        }
        
        // Find the primary muscle group
        let primaryMuscleGroup = muscleGroupCounts.max(by: { $0.value < $1.value })?.key ?? "Mixed"
        let mainMuscle = primaryMuscleGroup.lowercased()
        
        if mainMuscle.contains("chest") {
            return "heart.fill"
        } else if mainMuscle.contains("back") {
            return "figure.strengthtraining.traditional"
        } else if mainMuscle.contains("shoulder") || mainMuscle.contains("delt") {
            return "person.bust"
        } else if mainMuscle.contains("bicep") || mainMuscle.contains("tricep") || mainMuscle.contains("arm") {
            return "figure.arms.open"
        } else if mainMuscle.contains("core") || mainMuscle.contains("ab") {
            return "figure.core.training"
        } else if mainMuscle.contains("leg") || mainMuscle.contains("quad") || mainMuscle.contains("hamstring") {
            return "figure.walk"
        } else {
            return "figure.mixed.cardio"
        }
    }
    
    // Get color based on primary muscle group or icon
    func getAccentColor(for iconName: String) -> Color {
        switch iconName {
        case "heart.fill":
            return .red
        case "figure.strengthtraining.traditional":
            return .blue
        case "person.bust":
            return .purple
        case "figure.arms.open":
            return .green
        case "figure.core.training":
            return .yellow
        case "figure.walk":
            return .orange
        default:
            return .blue
        }
    }
}
