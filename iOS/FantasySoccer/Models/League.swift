import Foundation

struct League: Identifiable, Codable {
    let id: UUID
    let name: String
    let description: String?
    let ownerId: UUID
    let maxTeams: Int
    let currentTeams: Int
    let draftDate: Date?
    let draftOrder: [UUID]?
    let seasonStartDate: Date?
    let seasonEndDate: Date?
    let isPublic: Bool
    let entryFee: Double
    let prizePool: [String: Double]?
    let scoringSettings: ScoringSettings
    let rosterSettings: RosterSettings
    let status: LeagueStatus
    let createdAt: Date
    let updatedAt: Date
    
    // Computed properties
    var isFull: Bool {
        return currentTeams >= maxTeams
    }
    
    var canJoin: Bool {
        return !isFull && status == .drafting
    }
    
    var isDraftComplete: Bool {
        return status != .drafting
    }
    
    enum LeagueStatus: String, CaseIterable, Codable {
        case drafting = "drafting"
        case active = "active"
        case completed = "completed"
        
        var displayName: String {
            switch self {
            case .drafting: return "Drafting"
            case .active: return "Active"
            case .completed: return "Completed"
            }
        }
    }
    
    struct ScoringSettings: Codable {
        let passesCompleted: Double
        let keyPasses: Double
        let assists: Double
        let goals: Double
        let cleanSheetsDef: Double
        let cleanSheetsMid: Double
        let cleanSheetsGk: Double
        let saves: Double
        let minutesPlayed: Double
        let yellowCards: Double
        let redCards: Double
        
        static let `default` = ScoringSettings(
            passesCompleted: 1.0,
            keyPasses: 2.0,
            assists: 6.0,
            goals: 10.0,
            cleanSheetsDef: 4.0,
            cleanSheetsMid: 4.0,
            cleanSheetsGk: 6.0,
            saves: 1.0,
            minutesPlayed: 0.1,
            yellowCards: -1.0,
            redCards: -3.0
        )
    }
    
    struct RosterSettings: Codable {
        let goalkeeper: Int
        let defender: Int
        let midfielder: Int
        let forward: Int
        let bench: Int
        
        var totalStarters: Int {
            return goalkeeper + defender + midfielder + forward
        }
        
        var totalRoster: Int {
            return totalStarters + bench
        }
        
        static let `default` = RosterSettings(
            goalkeeper: 1,
            defender: 4,
            midfielder: 4,
            forward: 2,
            bench: 6
        )
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case description
        case ownerId = "owner_id"
        case maxTeams = "max_teams"
        case currentTeams = "current_teams"
        case draftDate = "draft_date"
        case draftOrder = "draft_order"
        case seasonStartDate = "season_start_date"
        case seasonEndDate = "season_end_date"
        case isPublic = "is_public"
        case entryFee = "entry_fee"
        case prizePool = "prize_pool"
        case scoringSettings = "scoring_settings"
        case rosterSettings = "roster_settings"
        case status
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}

// MARK: - Team Model
struct Team: Identifiable, Codable {
    let id: UUID
    let leagueId: UUID
    let userId: UUID
    let name: String
    let logoUrl: String?
    let draftPosition: Int?
    let waiverPriority: Int
    let totalPoints: Double
    let wins: Int
    let losses: Int
    let ties: Int
    let createdAt: Date
    let updatedAt: Date
    
    // Computed properties
    var record: String {
        return "\(wins)-\(losses)-\(ties)"
    }
    
    var winPercentage: Double {
        let totalGames = wins + losses + ties
        guard totalGames > 0 else { return 0.0 }
        return Double(wins) / Double(totalGames)
    }
    
    var pointsPerGame: Double {
        let totalGames = wins + losses + ties
        guard totalGames > 0 else { return 0.0 }
        return totalPoints / Double(totalGames)
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case leagueId = "league_id"
        case userId = "user_id"
        case name
        case logoUrl = "logo_url"
        case draftPosition = "draft_position"
        case waiverPriority = "waiver_priority"
        case totalPoints = "total_points"
        case wins
        case losses
        case ties
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}

// MARK: - Roster Spot Model
struct RosterSpot: Identifiable, Codable {
    let id: UUID
    let teamId: UUID
    let playerId: UUID
    let position: RosterPosition
    let isStarting: Bool
    let addedAt: Date
    
    enum RosterPosition: String, CaseIterable, Codable {
        case goalkeeper = "GK"
        case defender = "DEF"
        case midfielder = "MID"
        case forward = "FWD"
        case bench = "BENCH"
        
        var displayName: String {
            switch self {
            case .goalkeeper: return "Goalkeeper"
            case .defender: return "Defender"
            case .midfielder: return "Midfielder"
            case .forward: return "Forward"
            case .bench: return "Bench"
            }
        }
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case teamId = "team_id"
        case playerId = "player_id"
        case position
        case isStarting = "is_starting"
        case addedAt = "added_at"
    }
}

// MARK: - Matchup Model
struct Matchup: Identifiable, Codable {
    let id: UUID
    let leagueId: UUID
    let week: Int
    let team1Id: UUID
    let team2Id: UUID
    let team1Score: Double
    let team2Score: Double
    let winnerId: UUID?
    let isTie: Bool
    let status: MatchupStatus
    let createdAt: Date
    let updatedAt: Date
    
    enum MatchupStatus: String, CaseIterable, Codable {
        case scheduled = "scheduled"
        case active = "active"
        case completed = "completed"
        
        var displayName: String {
            switch self {
            case .scheduled: return "Scheduled"
            case .active: return "Live"
            case .completed: return "Final"
            }
        }
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case leagueId = "league_id"
        case week
        case team1Id = "team1_id"
        case team2Id = "team2_id"
        case team1Score = "team1_score"
        case team2Score = "team2_score"
        case winnerId = "winner_id"
        case isTie = "is_tie"
        case status
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
} 