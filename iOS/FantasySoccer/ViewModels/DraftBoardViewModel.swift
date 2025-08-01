import Foundation
import Combine

@MainActor
class DraftBoardViewModel: ObservableObject {
    @Published var draftPicks: [DraftPick] = []
    @Published var availablePlayers: [PlayerWithStats] = []
    @Published var currentPick: Int = 1
    @Published var totalPicks: Int = 0
    @Published var timeRemaining: TimeInterval = 90 // 90 seconds per pick
    @Published var currentTeam: Team?
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private var timer: Timer?
    private var cancellables = Set<AnyCancellable>()
    private let draftService = DraftService()
    private let playerService = PlayerService()
    
    init() {
        setupTimer()
    }
    
    deinit {
        timer?.invalidate()
    }
    
    func loadDraftData(for league: League) {
        isLoading = true
        errorMessage = nil
        
        Task {
            do {
                // Load draft picks
                let picks = try await draftService.getDraftPicks(for: league.id)
                self.draftPicks = picks
                
                // Load available players
                let players = try await playerService.getAvailablePlayers(for: league.id)
                self.availablePlayers = players
                
                // Calculate totals
                self.totalPicks = league.maxTeams * league.rosterSettings.totalRoster
                
                // Set current pick and team
                await updateCurrentPick()
                
                self.isLoading = false
            } catch {
                self.errorMessage = error.localizedDescription
                self.isLoading = false
            }
        }
    }
    
    func selectPlayer(_ player: Player) {
        guard let currentTeam = currentTeam else { return }
        
        Task {
            do {
                try await draftService.makePick(
                    playerId: player.id,
                    teamId: currentTeam.id,
                    round: getCurrentRound(),
                    pickNumber: currentPick
                )
                
                // Update local state
                await updateDraftPicks()
                await updateAvailablePlayers()
                await updateCurrentPick()
                
                // Reset timer
                resetTimer()
                
            } catch {
                self.errorMessage = error.localizedDescription
            }
        }
    }
    
    func autoPick() {
        guard let currentTeam = currentTeam else { return }
        
        // Find best available player for the team's needs
        let bestPlayer = findBestAvailablePlayer(for: currentTeam)
        
        if let player = bestPlayer {
            selectPlayer(player)
        }
    }
    
    private func setupTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            Task { @MainActor in
                self?.updateTimer()
            }
        }
    }
    
    private func updateTimer() {
        if timeRemaining > 0 {
            timeRemaining -= 1
        } else {
            // Time's up - auto pick
            autoPick()
        }
    }
    
    private func resetTimer() {
        timeRemaining = 90 // Reset to 90 seconds
    }
    
    private func updateCurrentPick() async {
        // Find the first unpicked slot
        let unpickedPicks = draftPicks.filter { $0.player == nil }
        
        if let firstUnpicked = unpickedPicks.first {
            currentPick = getPickNumber(round: firstUnpicked.round, pickNumber: firstUnpicked.pickNumber)
            
            // Find the team that should pick
            if let team = await getTeamForPick(round: firstUnpicked.round, pickNumber: firstUnpicked.pickNumber) {
                currentTeam = team
            }
        } else {
            // Draft is complete
            currentPick = totalPicks
            currentTeam = nil
        }
    }
    
    private func updateDraftPicks() async {
        do {
            let picks = try await draftService.getDraftPicks(for: currentTeam?.leagueId ?? UUID())
            self.draftPicks = picks
        } catch {
            self.errorMessage = error.localizedDescription
        }
    }
    
    private func updateAvailablePlayers() async {
        do {
            let players = try await playerService.getAvailablePlayers(for: currentTeam?.leagueId ?? UUID())
            self.availablePlayers = players
        } catch {
            self.errorMessage = error.localizedDescription
        }
    }
    
    private func getCurrentRound() -> Int {
        return ((currentPick - 1) / (currentTeam?.leagueId ?? UUID().uuidString.count)) + 1
    }
    
    private func getPickNumber(round: Int, pickNumber: Int) -> Int {
        // Calculate overall pick number from round and pick number
        return (round - 1) * 12 + pickNumber // Assuming 12 teams
    }
    
    private func getTeamForPick(round: Int, pickNumber: Int) async -> Team? {
        // This would need to be implemented based on your draft order logic
        // For now, return nil
        return nil
    }
    
    private func findBestAvailablePlayer(for team: Team) -> Player? {
        // Implement best player selection logic
        // This could be based on:
        // 1. Team needs (positions they still need)
        // 2. Player rankings
        // 3. Team strategy
        
        return availablePlayers.first?.player
    }
}

// MARK: - Draft Service
class DraftService {
    func getDraftPicks(for leagueId: UUID) async throws -> [DraftPick] {
        // This would make an API call to get draft picks
        // For now, return mock data
        return []
    }
    
    func makePick(playerId: UUID, teamId: UUID, round: Int, pickNumber: Int) async throws {
        // This would make an API call to record a draft pick
        // For now, just simulate success
    }
}

// MARK: - Player Service
class PlayerService {
    func getAvailablePlayers(for leagueId: UUID) async throws -> [PlayerWithStats] {
        // This would make an API call to get available players
        // For now, return mock data
        return []
    }
}

// MARK: - Mock Data for Preview
extension DraftBoardViewModel {
    static func mock() -> DraftBoardViewModel {
        let viewModel = DraftBoardViewModel()
        
        // Mock draft picks
        viewModel.draftPicks = (1...12).flatMap { round in
            (1...12).map { pick in
                DraftPick(
                    round: round,
                    pickNumber: pick,
                    teamId: UUID(),
                    player: pick <= 5 ? Player.mock() : nil,
                    isAutoPick: false,
                    pickedAt: pick <= 5 ? Date() : nil
                )
            }
        }
        
        // Mock available players
        viewModel.availablePlayers = (1...50).map { _ in
            PlayerWithStats(
                player: Player.mock(),
                stats: PlayerStats.mock()
            )
        }
        
        viewModel.currentPick = 6
        viewModel.totalPicks = 144
        viewModel.timeRemaining = 45
        viewModel.currentTeam = Team.mock()
        
        return viewModel
    }
}

// MARK: - Mock Extensions
extension Player {
    static func mock() -> Player {
        return Player(
            id: UUID(),
            externalId: "123",
            name: "Lionel Messi",
            position: .forward,
            team: "Inter Miami",
            league: "MLS",
            country: "Argentina",
            age: 36,
            height: 170,
            weight: 72,
            jerseyNumber: 10,
            photoUrl: nil,
            isActive: true,
            isInjured: false,
            injuryStatus: nil,
            createdAt: Date(),
            updatedAt: Date()
        )
    }
}

extension PlayerStats {
    static func mock() -> PlayerStats {
        return PlayerStats(
            id: UUID(),
            playerId: UUID(),
            season: "2024",
            league: "MLS",
            team: "Inter Miami",
            matchesPlayed: 15,
            minutesPlayed: 1350,
            goals: 12,
            assists: 8,
            passesCompleted: 450,
            keyPasses: 25,
            cleanSheets: 0,
            saves: 0,
            yellowCards: 2,
            redCards: 0,
            fantasyPoints: 156.5,
            createdAt: Date(),
            updatedAt: Date()
        )
    }
}

extension Team {
    static func mock() -> Team {
        return Team(
            id: UUID(),
            leagueId: UUID(),
            userId: UUID(),
            name: "Messi's Magic",
            logoUrl: nil,
            draftPosition: 1,
            waiverPriority: 1,
            totalPoints: 0,
            wins: 0,
            losses: 0,
            ties: 0,
            createdAt: Date(),
            updatedAt: Date()
        )
    }
} 