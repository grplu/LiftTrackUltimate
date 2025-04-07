// More efficient function to add exercises to template
func addExerciseToTemplate(exercise: Exercise) {
    print("Adding exercise: \(exercise.name)")
    
    // Check if the exercise is already in the template to avoid duplicates
    if selectedExercises.contains(where: { $0.exercise.id == exercise.id }) {
        print("Exercise already in template, skipping")
        return
    }
    
    // Get last performance for default values if available
    let lastWeight = TemplateStorageManager.shared.getLastUsedWeight(for: exercise)
    
    // Create a template exercise with default values
    let templateExercise = TemplateExercise(
        id: UUID(),
        exercise: exercise,
        targetSets: 3,  // Default
        targetReps: 10, // Default
        targetWeight: lastWeight // Pass directly as Double?
    )
    
    // Add it to the array
    withAnimation {
        selectedExercises.append(templateExercise)
        print("Added exercise successfully. Total exercises: \(selectedExercises.count)")
    }
} 