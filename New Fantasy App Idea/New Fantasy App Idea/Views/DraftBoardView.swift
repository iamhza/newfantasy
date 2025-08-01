import SwiftUI

struct DraftBoardView: View {
    @StateObject private var viewModel = DraftBoardViewModel()
    @State private var selectedPosition: Player.PlayerPosition?
    @State private var searchText = ""
    @State private var showingPlayerDetail = false
    @State private var selectedPlayer: Player?
    
    let league: League
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Header with draft info
                DraftHeaderView(
                    currentPick: viewModel.currentPick,
                    totalPicks: viewModel.totalPicks,
                    timeRemaining: viewModel.timeRemaining,
                    currentTeam: viewModel.currentTeam
                )
                
                // Draft board grid
                DraftBoardGridView(
                    picks: viewModel.draftPicks,
                    onPickSelected: { pick in
                        selectedPlayer = pick.player
                        showingPlayerDetail = true
                    }
                )
                
                // Player list
                PlayerListView(
                    players: filteredPlayers,
                    selectedPosition: $selectedPosition,
                    searchText: $searchText,
                    onPlayerSelected: { player in
                        viewModel.selectPlayer(player)
                    }
                )
            }
            .navigationTitle("Draft Board")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Settings") {
                        // Show draft settings
                    }
                }
            }
        }
        .sheet(isPresented: $showingPlayerDetail) {
            if let player = selectedPlayer {
                PlayerDetailView(player: player)
            }
        }
        .onAppear {
            viewModel.loadDraftData(for: league)
        }
    }
    
    private var filteredPlayers: [PlayerWithStats] {
        var players = viewModel.availablePlayers
        
        // Filter by position
        if let position = selectedPosition {
            players = players.filter { $0.player.position == position }
        }
        
        // Filter by search text
        if !searchText.isEmpty {
            players = players.filter { player in
                player.player.name.localizedCaseInsensitiveContains(searchText) ||
                player.player.team?.localizedCaseInsensitiveContains(searchText) == true
            }
        }
        
        return players
    }
}

// MARK: - Draft Header View
struct DraftHeaderView: View {
    let currentPick: Int
    let totalPicks: Int
    let timeRemaining: TimeInterval
    let currentTeam: Team?
    
    var body: some View {
        VStack(spacing: 12) {
            // Progress bar
            ProgressView(value: Double(currentPick), total: Double(totalPicks))
                .progressViewStyle(LinearProgressViewStyle(tint: .blue))
                .padding(.horizontal)
            
            HStack {
                VStack(alignment: .leading) {
                    Text("Pick \(currentPick) of \(totalPicks)")
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    if let team = currentTeam {
                        Text("\(team.name)'s turn")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
                
                VStack(alignment: .trailing) {
                    Text(timeString)
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(timeColor)
                    
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
    
    private var timeString: String {
        let minutes = Int(timeRemaining) / 60
        let seconds = Int(timeRemaining) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    private var timeColor: Color {
        if timeRemaining < 30 {
            return .red
        } else if timeRemaining < 60 {
            return .orange
        } else {
            return .primary
        }
    }
}

// MARK: - Draft Board Grid View
struct DraftBoardGridView: View {
    let picks: [DraftPick]
    let onPickSelected: (DraftPick) -> Void
    
    private let columns = Array(repeating: GridItem(.flexible(), spacing: 8), count: 6)
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 8) {
                ForEach(picks) { pick in
                    DraftPickCard(pick: pick) {
                        onPickSelected(pick)
                    }
                }
            }
            .padding()
        }
        .background(Color(.systemGroupedBackground))
    }
}

// MARK: - Draft Pick Card
struct DraftPickCard: View {
    let pick: DraftPick
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 4) {
                Text("\(pick.round).\(pick.pickNumber)")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(.secondary)
                
                if let player = pick.player {
                    AsyncImage(url: URL(string: player.photoUrl ?? "")) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    } placeholder: {
                        Circle()
                            .fill(Color.gray.opacity(0.3))
                    }
                    .frame(width: 40, height: 40)
                    .clipShape(Circle())
                    
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
        .buttonStyle(PlainButtonStyle())
    }
    
    private var positionColor: Color {
        guard let player = pick.player else { return .gray }
        
        switch player.position {
        case .goalkeeper: return .blue
        case .defender: return .green
        case .midfielder: return .orange
        case .forward: return .red
        }
    }
}

// MARK: - Player List View
struct PlayerListView: View {
    let players: [PlayerWithStats]
    @Binding var selectedPosition: Player.PlayerPosition?
    @Binding var searchText: String
    let onPlayerSelected: (Player) -> Void
    
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
                        selectedPosition = nil
                    }
                    
                    ForEach(Player.PlayerPosition.allCases, id: \.self) { position in
                        Button(position.displayName) {
                            selectedPosition = position
                        }
                    }
                } label: {
                    HStack {
                        Text(selectedPosition?.displayName ?? "All")
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
            List(players, id: \.player.id) { playerWithStats in
                PlayerRowView(playerWithStats: playerWithStats) {
                    onPlayerSelected(playerWithStats.player)
                }
            }
            .listStyle(PlainListStyle())
        }
    }
}

// MARK: - Player Row View
struct PlayerRowView: View {
    let playerWithStats: PlayerWithStats
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 12) {
                // Player photo
                AsyncImage(url: URL(string: playerWithStats.player.photoUrl ?? "")) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    Circle()
                        .fill(Color.gray.opacity(0.3))
                }
                .frame(width: 50, height: 50)
                .clipShape(Circle())
                
                // Player info
                VStack(alignment: .leading, spacing: 4) {
                    Text(playerWithStats.player.name)
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    HStack {
                        Text(playerWithStats.player.team ?? "Free Agent")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        Spacer()
                        
                        Text(playerWithStats.player.position.rawValue)
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
                    Text(String(format: "%.1f", playerWithStats.projectedPoints))
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
        switch playerWithStats.player.position {
        case .goalkeeper: return .blue
        case .defender: return .green
        case .midfielder: return .orange
        case .forward: return .red
        }
    }
}

// MARK: - Supporting Models
struct DraftPick: Identifiable {
    let id = UUID()
    let round: Int
    let pickNumber: Int
    let teamId: UUID
    let player: Player?
    let isAutoPick: Bool
    let pickedAt: Date?
}

// MARK: - Preview
struct DraftBoardView_Previews: PreviewProvider {
    static var previews: some View {
        DraftBoardView(league: League(
            id: UUID(),
            name: "Premier League Fantasy",
            description: "Test league",
            ownerId: UUID(),
            maxTeams: 12,
            currentTeams: 8,
            draftDate: Date(),
            draftOrder: nil,
            seasonStartDate: Date(),
            seasonEndDate: Date().addingTimeInterval(86400 * 365),
            isPublic: true,
            entryFee: 0,
            prizePool: nil,
            scoringSettings: .default,
            rosterSettings: .default,
            status: .drafting,
            createdAt: Date(),
            updatedAt: Date()
        ))
    }
} 