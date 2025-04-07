import Foundation

public enum ExerciseCategory: String, CaseIterable, Codable {
    case strength = "Strength"
    case cardio = "Cardio"
    case flexibility = "Flexibility"
    case core = "Core"
    case balance = "Balance"
    case olympic = "Olympic"
    case plyometric = "Plyometric"
    case other = "Other"
} 