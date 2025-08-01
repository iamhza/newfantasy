# Fantasy Soccer App - PPR Style

## Project Overview
A modern iOS fantasy soccer application similar to fantasy football PPR systems, featuring real-time scoring, live drafts, and comprehensive player management.

## Core Features

### 1. Scoring System (PPR Equivalent)
- **Points Per Pass (PPP)**: 1 point per completed pass
- **Key Passes**: 2 points per key pass
- **Assists**: 6 points per assist
- **Goals**: 10 points per goal
- **Clean Sheets**: 4 points (defenders/midfielders), 6 points (goalkeepers)
- **Saves**: 1 point per save (goalkeepers)
- **Minutes Played**: 0.1 points per minute
- **Cards**: -1 point (yellow), -3 points (red)

### 2. App Features
- **Live Draft Board**: Real-time draft interface similar to Sleeper/ESPN
- **Player Database**: Comprehensive soccer player stats and rankings
- **League Management**: Create, join, and manage fantasy leagues
- **Real-time Scoring**: Live updates during matches
- **Trade System**: Player trading between teams
- **Waiver Wire**: Add/drop players with waiver priority
- **Matchup Tracking**: Weekly head-to-head matchups
- **Playoffs**: Championship bracket system

### 3. Technical Stack
- **Frontend**: SwiftUI (iOS)
- **Backend**: Node.js with Express
- **Database**: PostgreSQL with Supabase
- **Real-time**: WebSocket connections
- **API**: RESTful API for soccer data
- **Authentication**: Supabase Auth

## Project Structure
```
FantasySoccerApp/
├── iOS/
│   ├── FantasySoccer/
│   │   ├── Views/
│   │   ├── Models/
│   │   ├── ViewModels/
│   │   ├── Services/
│   │   └── Utilities/
├── Backend/
│   ├── src/
│   ├── routes/
│   ├── models/
│   └── services/
├── Database/
│   ├── migrations/
│   └── schemas/
└── Documentation/
```

## Development Phases

### Phase 1: Core Infrastructure
- Database schema design
- Basic API endpoints
- User authentication
- Player database setup

### Phase 2: Core App Features
- User registration/login
- League creation and management
- Basic player browsing
- Simple scoring system

### Phase 3: Draft System
- Live draft board
- Player rankings
- Draft room functionality
- Auto-draft capabilities

### Phase 4: Game Management
- Team management
- Lineup setting
- Weekly matchups
- Real-time scoring

### Phase 5: Advanced Features
- Trade system
- Waiver wire
- Playoffs
- Push notifications

## Getting Started
1. Clone the repository
2. Set up iOS development environment
3. Configure Supabase project
4. Install dependencies
5. Run the application

## API Integration
- **Soccer Data**: Integration with soccer APIs for live stats
- **Player Rankings**: Weekly updated player rankings
- **Match Schedules**: Real-time match data
- **Injury Reports**: Player availability updates 