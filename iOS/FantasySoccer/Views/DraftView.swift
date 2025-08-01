import SwiftUI

struct DraftView: View {
    @State private var searchText = ""
    @State private var selectedPosition: PlayerPosition = .all
    @State private var showingPlayerDetail = false
    @State private var selectedPlayer: MockPlayer?
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Draft Header
                DraftHeaderView()
                
                // Draft Board
                DraftBoardView()
                
                // Player List
                PlayerListView(
                    searchText: $searchText,
                    selectedPosition: $selectedPosition,
                    onPlayerSelected: { player in
                        selectedPlayer = player
                        showingPlayerDetail = true
                    }
                )
            }
            .navigationTitle("Draft Board")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $showingPlayerDetail) {
                if let player = selectedPlayer {
                    PlayerDetailView(player: player)
                }
            }
        }
    }
}

struct DraftHeaderView: View {
    var body: some View {
        VStack(spacing: 12) {
            // Progress bar
            ProgressView(value: 45, total: 144)
                .progressViewStyle(LinearProgressViewStyle(tint: .green))
                .padding(.horizontal)
            
            HStack {
                VStack(alignment: .leading) {
                    Text("Pick 45 of 144")
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Text("Messi's Magic's turn")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                VStack(alignment: .trailing) {
                    Text("01:23")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.orange)
                    
                    Text("Time Remaining")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .padding(.horizontal)
        }
        .padding(.vertical, 8)
        .background(Color(.systemBackground))
        .shadow(color: .black.opacity(0.1), radius: 2, y: 1)
    }
}

struct DraftBoardView: View {
    let columns = Array(repeating: GridItem(.flexible(), spacing: 8), count: 6)
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 8) {
                ForEach(mockDraftPicks) { pick in
                    DraftPickCard(pick: pick)
                }
            }
            .padding()
        }
        .background(Color(.systemGroupedBackground))
        .frame(height: 200)
    }
}

struct DraftPickCard: View {
    let pick: MockDraftPick
    
    var body: some View {
        VStack(spacing: 4) {
            Text("\(pick.round).\(pick.pickNumber)")
                .font(.caption)
                .fontWeight(.bold)
                .foregroundColor(.secondary)
            
            if let player = pick.player {
                Circle()
                    .fill(positionColor.opacity(0.2))
                    .frame(width: 40, height: 40)
                    .overlay(
                        Text(player.name.prefix(2))
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundColor(positionColor)
                    )
                
                Text(player.name)
                    .font(.caption)
                    .fontWeight(.medium)
                    .lineLimit(2)
                    .multilineTextAlignment(.center)
                
                Text(player.position.rawValue)
                    .font(.caption2)
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(positionColor.opacity(0.2))
                    .cornerRadius(4)
            } else {
                Circle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 40, height: 40)
                
                Text("TBD")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(8)
        .background(Color(.systemBackground))
        .cornerRadius(8)
        .shadow(color: .black.opacity(0.1), radius: 2, y: 1)
    }
    
    private var positionColor: Color {
        guard let player = pick.player else { return .gray }
        
        switch player.position {
        case .goalkeeper: return .blue
        case .defender: return .green
        case .midfielder: return .orange
        case .forward: return .red
        case .all: return .gray
        }
    }
}

struct PlayerListView: View {
    @Binding var searchText: String
    @Binding var selectedPosition: PlayerPosition
    let onPlayerSelected: (MockPlayer) -> Void
    
    var filteredPlayers: [MockPlayer] {
        var players = mockPlayers
        
        if selectedPosition != .all {
            players = players.filter { $0.position == selectedPosition }
        }
        
        if !searchText.isEmpty {
            players = players.filter { player in
                player.name.localizedCaseInsensitiveContains(searchText) ||
                player.team.localizedCaseInsensitiveContains(searchText)
            }
        }
        
        return players
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Search and filter bar
            HStack {
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.secondary)
                    
                    TextField("Search players...", text: $searchText)
                        .textFieldStyle(PlainTextFieldStyle())
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(Color(.systemGray6))
                .cornerRadius(8)
                
                Menu {
                    Button("All Positions") {
                        selectedPosition = .all
                    }
                    
                    ForEach([PlayerPosition.goalkeeper, .defender, .midfielder, .forward], id: \.self) { position in
                        Button(position.displayName) {
                            selectedPosition = position
                        }
                    }
                } label: {
                    HStack {
                        Text(selectedPosition.displayName)
                        Image(systemName: "chevron.down")
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
                }
            }
            .padding()
            
            // Player list
            List(filteredPlayers, id: \.id) { player in
                PlayerRowView(player: player) {
                    onPlayerSelected(player)
                }
            }
            .listStyle(PlainListStyle())
        }
    }
}

struct PlayerRowView: View {
    let player: MockPlayer
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 12) {
                // Player photo
                Circle()
                    .fill(positionColor.opacity(0.2))
                    .frame(width: 50, height: 50)
                    .overlay(
                        Text(player.name.prefix(2))
                            .font(.headline)
                            .fontWeight(.bold)
                            .foregroundColor(positionColor)
                    )
                
                // Player info
                VStack(alignment: .leading, spacing: 4) {
                    Text(player.name)
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    HStack {
                        Text(player.team)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        Spacer()
                        
                        Text(player.position.rawValue)
                            .font(.caption)
                            .fontWeight(.medium)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 2)
                            .background(positionColor.opacity(0.2))
                            .foregroundColor(positionColor)
                            .cornerRadius(4)
                    }
                }
                
                Spacer()
                
                // Fantasy points
                VStack(alignment: .trailing, spacing: 2) {
                    Text(String(format: "%.1f", player.projectedPoints))
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                    
                    Text("PTS")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .padding(.vertical, 4)
        }
        .buttonStyle(PlainButtonStyle())
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

struct PlayerDetailView: View {
    let player: MockPlayer
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Player header
                    VStack(spacing: 12) {
                        Circle()
                            .fill(positionColor.opacity(0.2))
                            .frame(width: 100, height: 100)
                            .overlay(
                                Text(player.name.prefix(2))
                                    .font(.largeTitle)
                                    .fontWeight(.bold)
                                    .foregroundColor(positionColor)
                            )
                        
                        Text(player.name)
                            .font(.title)
                            .fontWeight(.bold)
                        
                        Text(player.team)
                            .font(.title3)
                            .foregroundColor(.secondary)
                        
                        Text(player.position.displayName)
                            .font(.subheadline)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 6)
                            .background(positionColor.opacity(0.2))
                            .foregroundColor(positionColor)
                            .cornerRadius(20)
                    }
                    
                    // Stats
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Season Stats")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 12) {
                            StatCard(title: "Goals", value: "\(player.stats.goals)")
                            StatCard(title: "Assists", value: "\(player.stats.assists)")
                            StatCard(title: "Passes", value: "\(player.stats.passesCompleted)")
                            StatCard(title: "Key Passes", value: "\(player.stats.keyPasses)")
                        }
                    }
                    
                    // Projected points
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Fantasy Projection")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        HStack {
                            Text("Next Week")
                                .font(.subheadline)
                            Spacer()
                            Text(String(format: "%.1f pts", player.projectedPoints))
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.green)
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                    }
                }
                .padding()
            }
            .navigationTitle("Player Details")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(trailing: Button("Done") {
                presentationMode.wrappedValue.dismiss()
            })
        }
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

struct StatCard: View {
    let title: String
    let value: String
    
    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.green)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(8)
    }
}

// Mock Data
enum PlayerPosition: String, CaseIterable {
    case goalkeeper = "GK"
    case defender = "DEF"
    case midfielder = "MID"
    case forward = "FWD"
    case all = "ALL"
    
    var displayName: String {
        switch self {
        case .goalkeeper: return "Goalkeeper"
        case .defender: return "Defender"
        case .midfielder: return "Midfielder"
        case .forward: return "Forward"
        case .all: return "All"
        }
    }
}

struct MockPlayer: Identifiable {
    let id = UUID()
    let name: String
    let team: String
    let position: PlayerPosition
    let projectedPoints: Double
    let stats: PlayerStats
}

struct PlayerStats {
    let goals: Int
    let assists: Int
    let passesCompleted: Int
    let keyPasses: Int
}

struct MockDraftPick: Identifiable {
    let id = UUID()
    let round: Int
    let pickNumber: Int
    let player: MockPlayer?
}

let mockPlayers = [
    MockPlayer(name: "Lionel Messi", team: "Inter Miami", position: .forward, projectedPoints: 18.5, stats: PlayerStats(goals: 12, assists: 8, passesCompleted: 450, keyPasses: 25)),
    MockPlayer(name: "Erling Haaland", team: "Manchester City", position: .forward, projectedPoints: 16.2, stats: PlayerStats(goals: 15, assists: 3, passesCompleted: 120, keyPasses: 8)),
    MockPlayer(name: "Kevin De Bruyne", team: "Manchester City", position: .midfielder, projectedPoints: 15.8, stats: PlayerStats(goals: 5, assists: 12, passesCompleted: 600, keyPasses: 35)),
    MockPlayer(name: "Virgil van Dijk", team: "Liverpool", position: .defender, projectedPoints: 12.3, stats: PlayerStats(goals: 2, assists: 1, passesCompleted: 800, keyPasses: 5)),
    MockPlayer(name: "Alisson", team: "Liverpool", position: .goalkeeper, projectedPoints: 10.1, stats: PlayerStats(goals: 0, assists: 0, passesCompleted: 200, keyPasses: 0))
]

let mockDraftPicks = (1...12).flatMap { round in
    (1...12).map { pick in
        MockDraftPick(
            round: round,
            pickNumber: pick,
            player: pick <= 5 ? mockPlayers.first : nil
        )
    }
}

struct DraftView_Previews: PreviewProvider {
    static var previews: some View {
        DraftView()
    }
} 