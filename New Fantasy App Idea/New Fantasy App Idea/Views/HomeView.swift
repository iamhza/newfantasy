import SwiftUI

struct HomeView: View {
    @State private var selectedLeague: MockLeague?
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Header
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Fantasy Soccer")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(.green)
                        
                        Text("PPR Style - Points Per Pass")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                    
                    // Quick Actions
                    VStack(spacing: 12) {
                        Button(action: {
                            // Create new league
                        }) {
                            HStack {
                                Image(systemName: "plus.circle.fill")
                                    .foregroundColor(.green)
                                Text("Create New League")
                                    .fontWeight(.semibold)
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .foregroundColor(.secondary)
                            }
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(12)
                        }
                        
                        Button(action: {
                            // Join league
                        }) {
                            HStack {
                                Image(systemName: "person.badge.plus")
                                    .foregroundColor(.blue)
                                Text("Join League")
                                    .fontWeight(.semibold)
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .foregroundColor(.secondary)
                            }
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(12)
                        }
                    }
                    .padding(.horizontal)
                    
                    // My Leagues
                    VStack(alignment: .leading, spacing: 12) {
                        Text("My Leagues")
                            .font(.title2)
                            .fontWeight(.bold)
                            .padding(.horizontal)
                        
                        ForEach(mockLeagues) { league in
                            LeagueCard(league: league)
                        }
                    }
                    
                    // Scoring Rules
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Scoring Rules")
                            .font(.title2)
                            .fontWeight(.bold)
                            .padding(.horizontal)
                        
                        VStack(spacing: 8) {
                            ScoringRuleRow(stat: "Passes Completed", points: "1 pt")
                            ScoringRuleRow(stat: "Key Passes", points: "2 pts")
                            ScoringRuleRow(stat: "Assists", points: "6 pts")
                            ScoringRuleRow(stat: "Goals", points: "10 pts")
                            ScoringRuleRow(stat: "Clean Sheets", points: "4-6 pts")
                            ScoringRuleRow(stat: "Saves", points: "1 pt")
                            ScoringRuleRow(stat: "Yellow Cards", points: "-1 pt")
                            ScoringRuleRow(stat: "Red Cards", points: "-3 pts")
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                        .padding(.horizontal)
                    }
                }
            }
            .navigationBarHidden(true)
        }
    }
}

struct LeagueCard: View {
    let league: MockLeague
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                VStack(alignment: .leading) {
                    Text(league.name)
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    Text("\(league.currentTeams)/\(league.maxTeams) teams")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                VStack(alignment: .trailing) {
                    Text(league.status.rawValue)
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(statusColor.opacity(0.2))
                        .foregroundColor(statusColor)
                        .cornerRadius(8)
                    
                    Text("Pick \(league.currentPick)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            if league.status == .drafting {
                ProgressView(value: Double(league.currentPick), total: Double(league.totalPicks))
                    .progressViewStyle(LinearProgressViewStyle(tint: .green))
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 2, y: 1)
        .padding(.horizontal)
    }
    
    private var statusColor: Color {
        switch league.status {
        case .drafting: return .orange
        case .active: return .green
        case .completed: return .gray
        }
    }
}

struct ScoringRuleRow: View {
    let stat: String
    let points: String
    
    var body: some View {
        HStack {
            Text(stat)
                .font(.subheadline)
            Spacer()
            Text(points)
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(.green)
        }
    }
}

// Mock Data
struct MockLeague: Identifiable {
    let id = UUID()
    let name: String
    let currentTeams: Int
    let maxTeams: Int
    let status: LeagueStatus
    let currentPick: Int
    let totalPicks: Int
}

enum LeagueStatus: String {
    case drafting = "Drafting"
    case active = "Active"
    case completed = "Completed"
}

let mockLeagues = [
    MockLeague(name: "Premier League Fantasy", currentTeams: 8, maxTeams: 12, status: .drafting, currentPick: 45, totalPicks: 144),
    MockLeague(name: "Champions League Elite", currentTeams: 10, maxTeams: 10, status: .active, currentPick: 0, totalPicks: 100),
    MockLeague(name: "World Cup 2024", currentTeams: 12, maxTeams: 12, status: .completed, currentPick: 0, totalPicks: 144)
]

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
} 