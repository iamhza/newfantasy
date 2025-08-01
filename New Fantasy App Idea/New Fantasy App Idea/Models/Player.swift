import Foundation

struct Player: Identifiable, Codable, Hashable {
    let id: UUID
    let externalId: String?
    let name: String
    let position: PlayerPosition
    let team: String?
    let league: String?
    let country: String?
    let age: Int?
    let height: Int?
    let weight: Int?
    let jerseyNumber: Int?
    let photoUrl: String?
    let isActive: Bool
    let isInjured: Bool
    let injuryStatus: String?
    let createdAt: Date
    let updatedAt: Date
    
    // Computed properties
    var displayName: String {
        return name
    }
    
    var positionAbbreviation: String {
        return position.rawValue
    }
    
    var isAvailable: Bool {
        return isActive && !isInjured
    }
    
    enum PlayerPosition: String, CaseIterable, Codable {
        case goalkeeper = "GK"
        case defender = "DEF"
        case midfielder = "MID"
        case forward = "FWD"
        
        var displayName: String {
            switch self {
            case .goalkeeper: return "Goalkeeper"
            case .defender: return "Defender"
            case .midfielder: return "Midfielder"
            case .forward: return "Forward"
            }
        }
        
        var color: String {
            switch self {
            case .goalkeeper: return "blue"
            case .defender: return "green"
            case .midfielder: return "orange"
            case .forward: return "red"
            }
        }
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case externalId = "external_id"
        case name
        case position
        case team
        case league
        case country
        case age
        case height
        case weight
        case jerseyNumber = "jersey_number"
        case photoUrl = "photo_url"
        case isActive = "is_active"
        case isInjured = "is_injured"
        case injuryStatus = "injury_status"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}

// MARK: - Player Stats
struct PlayerStats: Identifiable, Codable {
    let id: UUID
    let playerId: UUID
    let season: String
    let league: String?
    let team: String?
    let matchesPlayed: Int
    let minutesPlayed: Int
    let goals: Int
    let assists: Int
    let passesCompleted: Int
    let keyPasses: Int
    let cleanSheets: Int
    let saves: Int
    let yellowCards: Int
    let redCards: Int
    let fantasyPoints: Double
    let createdAt: Date
    let updatedAt: Date
    
    enum CodingKeys: String, CodingKey {
        case id
        case playerId = "player_id"
        case season
        case league
        case team
        case matchesPlayed = "matches_played"
        case minutesPlayed = "minutes_played"
        case goals
        case assists
        case passesCompleted = "passes_completed"
        case keyPasses = "key_passes"
        case cleanSheets = "clean_sheets"
        case saves
        case yellowCards = "yellow_cards"
        case redCards = "red_cards"
        case fantasyPoints = "fantasy_points"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}

// MARK: - Player with Stats
struct PlayerWithStats {
    let player: Player
    let stats: PlayerStats?
    
    var projectedPoints: Double {
        return stats?.fantasyPoints ?? 0.0
    }
    
    var formRating: Double {
        guard let stats = stats else { return 0.0 }
        // Calculate form based on recent performance
        let basePoints = stats.fantasyPoints
        let minutesBonus = Double(stats.minutesPlayed) * 0.1
        let consistencyBonus = stats.matchesPlayed > 0 ? 2.0 : 0.0
        return basePoints + minutesBonus + consistencyBonus
    }
} 