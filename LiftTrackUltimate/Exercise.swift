import Foundation

struct Exercise: Identifiable, Codable {
    var id = UUID()
    var name: String
    var category: String
    var muscleGroups: [String]
    var instructions: String?
}
