import SwiftUI
import AudioToolbox

// MARK: - Models
class GameState: ObservableObject {
    @Published var score: Int = 0
    @Published var currentBadges: Set<Badge> = []
    @Published var completedTasks: Set<String> = []
    @Published var emergencyKitItems: [EmergencyItem] = []
    @Published var isTrainingComplete = false
}

struct SoundEffect {
    static let correct: SystemSoundID = 1004  // Tock sound
    static let wrong: SystemSoundID = 1053 // Wrong sound
    static let complete: SystemSoundID = 1025 // Ding sound
    static let emergency: SystemSoundID = 1057 // Alert sound
}

struct Badge: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let icon: String
    let description: String
}

struct EmergencyItem: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let icon: String
    var isCollected: Bool = false
}

struct EmergencyStep: Identifiable {
    let id = UUID()
    let title: String
    let subtitle: String
    let mainContent: AnyView
    let buttonText: String
    let points: Int
    let requiredTime: Int // Seconds required for this step
}

struct EmergencyNumber {
    let number: String
    let description: String
    let options: [String]
    let correctAnswer: Int
}

enum EmergencyType {
    case tornado
    case earthquake
    case hurricane
    case flood
    
    var icon: String {
        switch self {
        case .tornado: return "tornado"
        case .earthquake: return "waveform.path.ecg"
        case .hurricane: return "hurricane"
        case .flood: return "water.waves"
        }
    }
    
    var name: String {
        switch self {
        case .tornado: return "Tornado"
        case .earthquake: return "Earthquake"
        case .hurricane: return "Hurricane"
        case .flood: return "Flood"
        }
    }
}

// MARK: - Meeting Points Data
struct MeetingPoint: Identifiable {
    let id = UUID()
    let name: String
    let description: String
    let emergencyType: EmergencyType
    var isMarked = false
    
    static let defaultPoints = [
        // Tornado
        MeetingPoint(
            name: "Storm Shelter",
            description: "Underground shelter for tornado protection",
            emergencyType: .tornado
        ),
        MeetingPoint(
            name: "Community Center",
            description: "Designated tornado safe room",
            emergencyType: .tornado
        ),
        
        // Earthquake
        MeetingPoint(
            name: "School Field",
            description: "Open area away from buildings",
            emergencyType: .earthquake
        ),
        MeetingPoint(
            name: "City Park",
            description: "Large open space gathering point",
            emergencyType: .earthquake
        ),
        
        // Hurricane
        MeetingPoint(
            name: "Emergency Shelter",
            description: "County designated hurricane shelter",
            emergencyType: .hurricane
        ),
        MeetingPoint(
            name: "Evacuation Center",
            description: "Main evacuation facility",
            emergencyType: .hurricane
        ),
        
        // Flooding
        MeetingPoint(
            name: "High Ground Assembly",
            description: "Elevated safe zone",
            emergencyType: .flood
        ),
        MeetingPoint(
            name: "Highland School",
            description: "Secondary evacuation point",
            emergencyType: .flood
        )
    ]
}
