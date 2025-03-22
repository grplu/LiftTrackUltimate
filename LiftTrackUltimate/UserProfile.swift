import Foundation

struct UserProfile: Codable {
    var id = UUID()
    var name: String
    var fitnessGoal: String
    
    // Physical information
    var height: Double?
    var weight: Double?
    var birthDate: Date?
    
    // Profile image data
    var profilePicture: Data?
    
    // Preferences
    var useMetricSystem: Bool = true
    var prefersDarkMode: Bool = false
    var notificationsEnabled: Bool = true
    
    // Exercise memory for each exercise
    var exerciseMemory: [ExerciseMemory] = []
    
    // Helper property for easier access
    var exerciseMemories: [ExerciseMemory] {
        return exerciseMemory
    }
    
    // Additional computed properties for stats
    var age: Int? {
        guard let birthDate = birthDate else { return nil }
        return Calendar.current.dateComponents([.year], from: birthDate, to: Date()).year
    }
    
    var bmi: Double? {
        guard let height = height, let weight = weight, height > 0 else { return nil }
        // BMI = weight(kg) / (height(m) * height(m))
        let heightInMeters = height / 100
        return weight / (heightInMeters * heightInMeters)
    }
    
    // Coding keys for encoder/decoder
    enum CodingKeys: String, CodingKey {
        case id, name, fitnessGoal, height, weight, birthDate, profilePicture
        case useMetricSystem, prefersDarkMode, notificationsEnabled
        case exerciseMemory
    }
    
    // Manual implementation of Codable protocol
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        fitnessGoal = try container.decode(String.self, forKey: .fitnessGoal)
        height = try container.decodeIfPresent(Double.self, forKey: .height)
        weight = try container.decodeIfPresent(Double.self, forKey: .weight)
        birthDate = try container.decodeIfPresent(Date.self, forKey: .birthDate)
        profilePicture = try container.decodeIfPresent(Data.self, forKey: .profilePicture)
        useMetricSystem = try container.decodeIfPresent(Bool.self, forKey: .useMetricSystem) ?? true
        prefersDarkMode = try container.decodeIfPresent(Bool.self, forKey: .prefersDarkMode) ?? false
        notificationsEnabled = try container.decodeIfPresent(Bool.self, forKey: .notificationsEnabled) ?? true
        exerciseMemory = try container.decodeIfPresent([ExerciseMemory].self, forKey: .exerciseMemory) ?? []
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encode(fitnessGoal, forKey: .fitnessGoal)
        try container.encodeIfPresent(height, forKey: .height)
        try container.encodeIfPresent(weight, forKey: .weight)
        try container.encodeIfPresent(birthDate, forKey: .birthDate)
        try container.encodeIfPresent(profilePicture, forKey: .profilePicture)
        try container.encode(useMetricSystem, forKey: .useMetricSystem)
        try container.encode(prefersDarkMode, forKey: .prefersDarkMode)
        try container.encode(notificationsEnabled, forKey: .notificationsEnabled)
        try container.encode(exerciseMemory, forKey: .exerciseMemory)
    }
    
    // Standard initializer
    init(name: String, fitnessGoal: String) {
        self.name = name
        self.fitnessGoal = fitnessGoal
    }
    
    // Convenience initializer with more parameters
    init(name: String, fitnessGoal: String, height: Double? = nil, weight: Double? = nil, birthDate: Date? = nil) {
        self.name = name
        self.fitnessGoal = fitnessGoal
        self.height = height
        self.weight = weight
        self.birthDate = birthDate
    }
    
    // Function to update exercise memory
    mutating func updateExerciseMemory(exerciseId: UUID, reps: Int?, sets: Int?, weight: Double?) {
        // Find index of existing memory for this exercise
        if let index = exerciseMemory.firstIndex(where: { $0.exerciseId == exerciseId }) {
            // Update existing memory
            var updatedMemory = exerciseMemory[index]
            updatedMemory.reps = reps ?? updatedMemory.reps
            updatedMemory.sets = sets ?? updatedMemory.sets
            updatedMemory.weight = weight ?? updatedMemory.weight
            updatedMemory.lastUsed = Date()
            updatedMemory.lastReps = reps
            updatedMemory.lastSets = sets
            updatedMemory.lastWeight = weight
            updatedMemory.lastPerformanceDate = Date()
            exerciseMemory[index] = updatedMemory
        } else {
            // Add new memory
            exerciseMemory.append(
                ExerciseMemory(
                    exerciseId: exerciseId,
                    reps: reps ?? 10,
                    sets: sets ?? 3,
                    weight: weight
                )
            )
        }
    }
    
    // Calculate body stats
    func getBodyStatsSummary() -> String {
        var summary = ""
        
        if let height = height {
            summary += "Height: \(String(format: "%.1f", height)) cm\n"
        }
        
        if let weight = weight {
            summary += "Weight: \(String(format: "%.1f", weight)) kg\n"
        }
        
        if let bmiValue = bmi {
            summary += "BMI: \(String(format: "%.1f", bmiValue))"
            
            // Add BMI category
            let bmiCategory: String
            if bmiValue < 18.5 {
                bmiCategory = "Underweight"
            } else if bmiValue < 25 {
                bmiCategory = "Normal weight"
            } else if bmiValue < 30 {
                bmiCategory = "Overweight"
            } else {
                bmiCategory = "Obesity"
            }
            
            summary += " (\(bmiCategory))"
        }
        
        return summary.isEmpty ? "No physical data available" : summary
    }
}
