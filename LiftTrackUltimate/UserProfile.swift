import Foundation

struct UserProfile: Identifiable, Codable {
    var id = UUID()
    var name: String
    var age: Int?
    var weight: Double? // in kg
    var height: Double? // in cm
    var fitnessGoal: String
    
    init(id: UUID = UUID(), name: String, age: Int? = nil, weight: Double? = nil, height: Double? = nil, fitnessGoal: String) {
        self.id = id
        self.name = name
        self.age = age
        self.weight = weight
        self.height = height
        self.fitnessGoal = fitnessGoal
    }
}
