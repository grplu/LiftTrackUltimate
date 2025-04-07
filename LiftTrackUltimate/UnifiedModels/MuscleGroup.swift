import Foundation

public enum MuscleGroup: String, CaseIterable, Codable {
    case chest = "Chest"
    case back = "Back"
    case shoulders = "Shoulders"
    case arms = "Arms"
    case biceps = "Biceps"
    case triceps = "Triceps"
    case forearms = "Forearms"
    case legs = "Legs"
    case quadriceps = "Quadriceps"
    case hamstrings = "Hamstrings"
    case calves = "Calves"
    case glutes = "Glutes"
    case abdominals = "Abdominals"
    case obliques = "Obliques"
    case lowerBack = "Lower Back"
    case fullBody = "Full Body"
    case cardiovascular = "Cardiovascular"
    case core = "Core"
    case none = "None"
    
    public var name: String {
        return self.rawValue
    }
    
    public var displayName: String {
        return name
    }
    
    public var iconName: String {
        switch self {
        case .chest: return "heart.fill"
        case .back: return "person.fill"
        case .legs, .quadriceps, .hamstrings, .calves, .glutes: return "figure.walk"
        case .shoulders: return "person.crop.rectangle.fill"
        case .arms, .biceps, .triceps, .forearms: return "hand.raised.fill"
        case .core, .abdominals, .obliques: return "figure.core.training"
        case .lowerBack: return "figure.strengthtraining.traditional"
        case .fullBody: return "figure.mixed.cardio"
        case .cardiovascular: return "heart.circle.fill"
        case .none: return "questionmark"
        }
    }
    
    public var subregions: [String] {
        switch self {
        case .chest:
            return ["Upper Chest", "Middle Chest", "Lower Chest", "Inner Chest", "Outer Chest"]
        case .back:
            return ["Upper Back", "Lats", "Lower Back", "Traps", "Rhomboids"]
        case .legs:
            return ["Quads", "Hamstrings", "Calves", "Glutes", "Hip Flexors", "Adductors"]
        case .shoulders:
            return ["Front Deltoids", "Side Deltoids", "Rear Deltoids", "Rotator Cuff"]
        case .arms:
            return ["Biceps", "Triceps", "Forearms", "Brachialis"]
        case .core:
            return ["Abs", "Obliques", "Lower Abs", "Serratus"]
        default:
            return []
        }
    }
} 