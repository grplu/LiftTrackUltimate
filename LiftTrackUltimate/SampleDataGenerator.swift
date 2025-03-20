import Foundation

class SampleDataGenerator {
    static func generateExercises() -> [Exercise] {
        return [
            Exercise(name: "Bench Press", category: "Strength", muscleGroups: ["Chest", "Triceps"], instructions: "Lie on bench, lower barbell to chest, press up."),
            Exercise(name: "Squat", category: "Strength", muscleGroups: ["Quadriceps", "Glutes"], instructions: "Stand with feet shoulder width apart, bend knees, lower body as if sitting."),
            Exercise(name: "Deadlift", category: "Strength", muscleGroups: ["Back", "Legs"], instructions: "Stand over barbell, bend and grip bar, lift by extending hips and knees."),
            Exercise(name: "Pull-up", category: "Strength", muscleGroups: ["Back", "Biceps"], instructions: "Hang from bar, pull body up until chin clears bar."),
            Exercise(name: "Overhead Press", category: "Strength", muscleGroups: ["Shoulders", "Triceps"], instructions: "Stand with barbell at shoulders, press overhead."),
            Exercise(name: "Running", category: "Cardio", muscleGroups: ["Full Body"], instructions: "Run at comfortable pace, maintain good posture."),
            Exercise(name: "Cycling", category: "Cardio", muscleGroups: ["Legs", "Cardiovascular"], instructions: "Maintain steady cadence, adjust resistance as needed."),
            Exercise(name: "Plank", category: "Core", muscleGroups: ["Abdominals", "Lower Back"], instructions: "Hold push-up position on forearms, keep body straight."),
            Exercise(name: "Lunges", category: "Strength", muscleGroups: ["Quadriceps", "Glutes", "Hamstrings"], instructions: "Step forward, lower back knee toward ground, return to standing.")
        ]
    }
    
    static func generateWorkoutTemplates() -> [WorkoutTemplate] {
        let exercises = generateExercises()
        
        return [
            WorkoutTemplate(
                name: "Upper Body Strength",
                exercises: [
                    TemplateExercise(exercise: exercises[0], targetSets: 3, targetReps: 10),
                    TemplateExercise(exercise: exercises[3], targetSets: 3, targetReps: 8),
                    TemplateExercise(exercise: exercises[4], targetSets: 3, targetReps: 10)
                ]
            ),
            WorkoutTemplate(
                name: "Lower Body Strength",
                exercises: [
                    TemplateExercise(exercise: exercises[1], targetSets: 4, targetReps: 8),
                    TemplateExercise(exercise: exercises[2], targetSets: 3, targetReps: 6),
                    TemplateExercise(exercise: exercises[8], targetSets: 3, targetReps: 12)
                ]
            ),
            WorkoutTemplate(
                name: "Full Body Workout",
                exercises: [
                    TemplateExercise(exercise: exercises[0], targetSets: 3, targetReps: 10),
                    TemplateExercise(exercise: exercises[1], targetSets: 3, targetReps: 8),
                    TemplateExercise(exercise: exercises[3], targetSets: 3, targetReps: 8),
                    TemplateExercise(exercise: exercises[7], targetSets: 3, targetReps: nil)
                ]
            ),
            WorkoutTemplate(
                name: "Cardio Session",
                exercises: [
                    TemplateExercise(exercise: exercises[5], targetSets: 1, targetReps: nil),
                    TemplateExercise(exercise: exercises[6], targetSets: 1, targetReps: nil)
                ]
            )
        ]
    }
    
    static func generateSampleWorkouts() -> [AppWorkout] {
        let exercises = generateExercises()
        let now = Date()
        
        // Create sample workout data
        var sampleWorkouts = [
            AppWorkout(
                name: "Morning Strength",
                date: now.addingTimeInterval(-86400), // Yesterday
                duration: 3600, // 1 hour
                exercises: [
                    WorkoutExercise(
                        exercise: exercises[0],
                        sets: [
                            ExerciseSet(reps: 10, weight: 135, completed: true),
                            ExerciseSet(reps: 10, weight: 135, completed: true),
                            ExerciseSet(reps: 8, weight: 135, completed: true)
                        ]
                    ),
                    WorkoutExercise(
                        exercise: exercises[3],
                        sets: [
                            ExerciseSet(reps: 8, weight: 0, completed: true),
                            ExerciseSet(reps: 8, weight: 0, completed: true),
                            ExerciseSet(reps: 6, weight: 0, completed: true)
                        ]
                    )
                ]
            ),
            AppWorkout(
                name: "Evening Cardio",
                date: now.addingTimeInterval(-172800), // 2 days ago
                duration: 1800, // 30 minutes
                exercises: [
                    WorkoutExercise(
                        exercise: exercises[5],
                        sets: [
                            ExerciseSet(duration: 1800, distance: 5.0, completed: true)
                        ]
                    )
                ]
            ),
            AppWorkout(
                name: "Lower Body Day",
                date: now.addingTimeInterval(-259200), // 3 days ago
                duration: 2700, // 45 minutes
                exercises: [
                    WorkoutExercise(
                        exercise: exercises[1],
                        sets: [
                            ExerciseSet(reps: 10, weight: 185, completed: true),
                            ExerciseSet(reps: 10, weight: 185, completed: true),
                            ExerciseSet(reps: 8, weight: 205, completed: true)
                        ]
                    )
                ]
            )
        ]
        
        // Add notes to workouts
        var workout1 = sampleWorkouts[0]
        workout1.notes = "Felt good today. Focus on form with bench press."
        sampleWorkouts[0] = workout1
        
        var workout2 = sampleWorkouts[1]
        workout2.notes = "Easy 5k run. Kept a steady pace."
        sampleWorkouts[1] = workout2
        
        return sampleWorkouts
    }
}
