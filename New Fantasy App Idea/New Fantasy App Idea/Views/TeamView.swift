import SwiftUI

struct TeamView: View {
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Team Header
                    VStack(spacing: 8) {
                        Text("Messi's Magic")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(.green)
                        
                        Text("Premier League Fantasy")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        HStack(spacing: 20) {
                            VStack {
                                Text("3")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                Text("Wins")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            
                            VStack {
                                Text("2")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                Text("Losses")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            
                            VStack {
                                Text("156.5")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                Text("Points")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                    }
                    .padding()
                    
                    // Starting Lineup
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Starting Lineup")
                            .font(.title2)
                            .fontWeight(.bold)
                            .padding(.horizontal)
                        
                        VStack(spacing: 8) {
                            RosterSection(title: "Goalkeeper", players: mockTeam.filter { $0.position == .goalkeeper && $0.isStarting })
                            RosterSection(title: "Defenders", players: mockTeam.filter { $0.position == .defender && $0.isStarting })
                            RosterSection(title: "Midfielders", players: mockTeam.filter { $0.position == .midfielder && $0.isStarting })
                            RosterSection(title: "Forwards", players: mockTeam.filter { $0.position == .forward && $0.isStarting })
                        }
                    }
                    
                    // Bench
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Bench")
                            .font(.title2)
                            .fontWeight(.bold)
                            .padding(.horizontal)
                        
                        VStack(spacing: 8) {
                            ForEach(mockTeam.filter { !$0.isStarting }) { player in
                                PlayerRow(player: player)
                            }
                        }
                    }
                }
            }
            .navigationTitle("My Team")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct RosterSection: View {
    let title: String
    let players: [MockTeamPlayer]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.headline)
                .foregroundColor(.secondary)
                .padding(.horizontal)
            
            ForEach(players) { player in
                PlayerRow(player: player)
            }
        }
    }
}

struct PlayerRow: View {
    let player: MockTeamPlayer
    
    var body: some View {
        HStack(spacing: 12) {
            Circle()
                .fill(positionColor.opacity(0.2))
                .frame(width: 40, height: 40)
                .overlay(
                    Text(player.name.prefix(2))
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(positionColor)
                )
            
            VStack(alignment: .leading, spacing: 2) {
                Text(player.name)
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Text(player.team)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 2) {
                Text(String(format: "%.1f", player.weekPoints))
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(.green)
                
                Text("PTS")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 2, y: 1)
        .padding(.horizontal)
    }
    
    private var positionColor: Color {
        switch player.position {
        case .goalkeeper: return .blue
        case .defender: return .green
        case .midfielder: return .orange
        case .forward: return .red
        case .all: return .gray
        }
    }
}

struct MockTeamPlayer: Identifiable {
    let id = UUID()
    let name: String
    let team: String
    let position: PlayerPosition
    let isStarting: Bool
    let weekPoints: Double
}

let mockTeam = [
    MockTeamPlayer(name: "Alisson", team: "Liverpool", position: .goalkeeper, isStarting: true, weekPoints: 12.5),
    MockTeamPlayer(name: "Virgil van Dijk", team: "Liverpool", position: .defender, isStarting: true, weekPoints: 8.2),
    MockTeamPlayer(name: "Trent Alexander-Arnold", team: "Liverpool", position: .defender, isStarting: true, weekPoints: 9.1),
    MockTeamPlayer(name: "Kevin De Bruyne", team: "Manchester City", position: .midfielder, isStarting: true, weekPoints: 15.8),
    MockTeamPlayer(name: "Lionel Messi", team: "Inter Miami", position: .forward, isStarting: true, weekPoints: 18.5),
    MockTeamPlayer(name: "Erling Haaland", team: "Manchester City", position: .forward, isStarting: true, weekPoints: 16.2),
    MockTeamPlayer(name: "Mo Salah", team: "Liverpool", position: .forward, isStarting: false, weekPoints: 14.3),
    MockTeamPlayer(name: "Bruno Fernandes", team: "Manchester United", position: .midfielder, isStarting: false, weekPoints: 11.7)
]

struct TeamView_Previews: PreviewProvider {
    static var previews: some View {
        TeamView()
    }
} 