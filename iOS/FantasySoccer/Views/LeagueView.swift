import SwiftUI

struct LeagueView: View {
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // League Header
                    VStack(spacing: 8) {
                        Text("Premier League Fantasy")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(.green)
                        
                        Text("12 Teams • Week 5")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .padding()
                    
                    // Standings
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Standings")
                            .font(.title2)
                            .fontWeight(.bold)
                            .padding(.horizontal)
                        
                        VStack(spacing: 8) {
                            ForEach(Array(mockStandings.enumerated()), id: \.element.id) { index, team in
                                StandingRow(rank: index + 1, team: team)
                            }
                        }
                    }
                    
                    // This Week's Matchups
                    VStack(alignment: .leading, spacing: 12) {
                        Text("This Week's Matchups")
                            .font(.title2)
                            .fontWeight(.bold)
                            .padding(.horizontal)
                        
                        VStack(spacing: 8) {
                            ForEach(mockMatchups) { matchup in
                                MatchupRow(matchup: matchup)
                            }
                        }
                    }
                }
            }
            .navigationTitle("League")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct StandingRow: View {
    let rank: Int
    let team: MockStandingTeam
    
    var body: some View {
        HStack(spacing: 12) {
            Text("\(rank)")
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(.secondary)
                .frame(width: 30)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(team.name)
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Text("\(team.wins)-\(team.losses)-\(team.ties)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 2) {
                Text(String(format: "%.1f", team.points))
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
}

struct MatchupRow: View {
    let matchup: MockMatchup
    
    var body: some View {
        VStack(spacing: 8) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(matchup.team1Name)
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    Text(String(format: "%.1f", matchup.team1Score))
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.green)
                }
                
                Spacer()
                
                Text("VS")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text(matchup.team2Name)
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    Text(String(format: "%.1f", matchup.team2Score))
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.green)
                }
            }
            
            if matchup.status == .live {
                HStack {
                    Text("LIVE")
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.red)
                        .cornerRadius(8)
                    
                    Text("Q2 67'")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 2, y: 1)
        .padding(.horizontal)
    }
}

struct MockStandingTeam: Identifiable {
    let id = UUID()
    let name: String
    let wins: Int
    let losses: Int
    let ties: Int
    let points: Double
}

struct MockMatchup: Identifiable {
    let id = UUID()
    let team1Name: String
    let team2Name: String
    let team1Score: Double
    let team2Score: Double
    let status: MatchupStatus
}

enum MatchupStatus {
    case scheduled
    case live
    case completed
}

let mockStandings = [
    MockStandingTeam(name: "Messi's Magic", wins: 4, losses: 1, ties: 0, points: 156.5),
    MockStandingTeam(name: "Haaland's Heroes", wins: 3, losses: 1, ties: 1, points: 142.3),
    MockStandingTeam(name: "De Bruyne Dynasty", wins: 3, losses: 2, ties: 0, points: 138.7),
    MockStandingTeam(name: "Salah's Squad", wins: 2, losses: 2, ties: 1, points: 125.9),
    MockStandingTeam(name: "Van Dijk Vipers", wins: 2, losses: 3, ties: 0, points: 118.4),
    MockStandingTeam(name: "Alisson's Army", wins: 1, losses: 3, ties: 1, points: 105.2)
]

let mockMatchups = [
    MockMatchup(team1Name: "Messi's Magic", team2Name: "Haaland's Heroes", team1Score: 45.2, team2Score: 38.7, status: .live),
    MockMatchup(team1Name: "De Bruyne Dynasty", team2Name: "Salah's Squad", team1Score: 42.1, team2Score: 39.8, status: .live),
    MockMatchup(team1Name: "Van Dijk Vipers", team2Name: "Alisson's Army", team1Score: 0, team2Score: 0, status: .scheduled)
]

struct LeagueView_Previews: PreviewProvider {
    static var previews: some View {
        LeagueView()
    }
} 