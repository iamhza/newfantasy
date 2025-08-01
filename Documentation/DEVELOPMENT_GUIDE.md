# Fantasy Soccer App - Development Guide

## Project Overview

This is a comprehensive fantasy soccer application that adapts the popular PPR (Points Per Reception) fantasy football scoring system to soccer. The app features real-time drafting, live scoring, team management, and all the features you'd expect from modern fantasy sports platforms like Sleeper, ESPN, or Underdog.

## Architecture

### Tech Stack
- **Frontend**: SwiftUI (iOS)
- **Backend**: Node.js with Express
- **Database**: PostgreSQL with Supabase
- **Real-time**: Socket.IO
- **Authentication**: Supabase Auth
- **API**: RESTful API with WebSocket support

### Project Structure
```
FantasySoccerApp/
├── iOS/                          # iOS SwiftUI App
│   └── FantasySoccer/
│       ├── Views/                # SwiftUI Views
│       ├── Models/               # Data Models
│       ├── ViewModels/           # MVVM ViewModels
│       ├── Services/             # API Services
│       └── Utilities/            # Helper Functions
├── Backend/                      # Node.js API Server
│   ├── src/
│   │   ├── routes/               # API Routes
│   │   ├── middleware/           # Express Middleware
│   │   ├── utils/                # Utility Functions
│   │   └── config/               # Configuration
│   └── package.json
├── Database/                     # Database Schema & Migrations
│   ├── schemas/                  # SQL Schema Files
│   └── migrations/               # Database Migrations
└── Documentation/                # Project Documentation
```

## Scoring System (PPR Equivalent)

### Core Scoring Rules
- **Passes Completed**: 1 point per completed pass
- **Key Passes**: 2 points per key pass (pass leading to shot)
- **Assists**: 6 points per assist
- **Goals**: 10 points per goal
- **Clean Sheets**: 4 points (defenders/midfielders), 6 points (goalkeepers)
- **Saves**: 1 point per save (goalkeepers)
- **Minutes Played**: 0.1 points per minute
- **Yellow Cards**: -1 point
- **Red Cards**: -3 points

### Roster Settings
- **Goalkeeper**: 1 starter
- **Defenders**: 4 starters
- **Midfielders**: 4 starters
- **Forwards**: 2 starters
- **Bench**: 6 players

## Setup Instructions

### Prerequisites
- Node.js 18+ 
- Xcode 15+ (for iOS development)
- PostgreSQL database
- Supabase account

### Backend Setup

1. **Install Dependencies**
   ```bash
   cd Backend
   npm install
   ```

2. **Environment Configuration**
   Create a `.env` file in the Backend directory:
   ```env
   NODE_ENV=development
   PORT=3001
   FRONTEND_URL=http://localhost:3000
   
   # Supabase Configuration
   SUPABASE_URL=your_supabase_url
   SUPABASE_ANON_KEY=your_supabase_anon_key
   SUPABASE_SERVICE_ROLE_KEY=your_supabase_service_role_key
   
   # JWT Secret
   JWT_SECRET=your_jwt_secret
   
   # Soccer API Keys (for player data)
   SOCCER_API_KEY=your_soccer_api_key
   ```

3. **Database Setup**
   ```bash
   # Run database migrations
   npm run migrate
   ```

4. **Start Development Server**
   ```bash
   npm run dev
   ```

### iOS Setup

1. **Open Project in Xcode**
   ```bash
   cd iOS/FantasySoccer
   open FantasySoccer.xcodeproj
   ```

2. **Configure API Endpoints**
   Update the API base URL in `Services/APIService.swift`:
   ```swift
   static let baseURL = "http://localhost:3001/api"
   ```

3. **Build and Run**
   - Select your target device/simulator
   - Press Cmd+R to build and run

## API Endpoints

### Authentication
- `POST /api/auth/register` - User registration
- `POST /api/auth/login` - User login
- `POST /api/auth/refresh` - Refresh token

### Leagues
- `GET /api/leagues` - Get user's leagues
- `POST /api/leagues` - Create new league
- `GET /api/leagues/:id` - Get league details
- `PUT /api/leagues/:id` - Update league settings

### Draft
- `GET /api/draft/picks/:leagueId` - Get draft picks
- `POST /api/draft/pick` - Make draft pick
- `GET /api/draft/available/:leagueId` - Get available players
- `GET /api/draft/order/:leagueId` - Get draft order

### Players
- `GET /api/players` - Get all players
- `GET /api/players/:id` - Get player details
- `GET /api/players/:id/stats` - Get player stats

### Teams
- `GET /api/teams/:id` - Get team details
- `PUT /api/teams/:id/roster` - Update team roster
- `GET /api/teams/:id/matchups` - Get team matchups

## Database Schema

### Core Tables
- **users** - User accounts
- **leagues** - Fantasy leagues
- **teams** - User teams within leagues
- **players** - Soccer players
- **player_stats** - Player statistics
- **roster_spots** - Players on teams
- **draft_picks** - Draft selections
- **matchups** - Weekly matchups
- **trades** - Player trades
- **waiver_claims** - Waiver wire claims

### Key Relationships
- Users can have multiple teams (one per league)
- Teams belong to one league
- Players can be on multiple teams (in different leagues)
- Draft picks are linked to leagues and teams
- Matchups are between teams in the same league

## Development Workflow

### Feature Development
1. **Database Changes**
   - Create migration files in `Database/migrations/`
   - Update schema documentation
   - Test migrations locally

2. **Backend Development**
   - Add new routes in `Backend/src/routes/`
   - Create/update models as needed
   - Add validation with Joi
   - Write tests for new endpoints

3. **iOS Development**
   - Create SwiftUI views in `iOS/FantasySoccer/Views/`
   - Add ViewModels for business logic
   - Update models to match API responses
   - Test on simulator and device

### Testing Strategy
- **Backend**: Jest for unit tests, Supertest for integration tests
- **iOS**: XCTest for unit tests, UI tests for critical flows
- **Database**: Manual testing with sample data

### Deployment
- **Backend**: Deploy to cloud platform (Heroku, AWS, etc.)
- **iOS**: Submit to App Store
- **Database**: Use Supabase production instance

## Key Features Implementation

### Real-time Draft Board
- Socket.IO for real-time updates
- Draft timer with auto-pick functionality
- Snake draft order management
- Player search and filtering

### Live Scoring
- Real-time score updates during matches
- Automatic point calculation based on live stats
- Push notifications for score changes

### Team Management
- Roster management with position limits
- Lineup setting for weekly matchups
- Player add/drop with waiver priority
- Trade system with approval workflow

### League Management
- League creation and settings
- Invite system with unique codes
- Commissioner tools for league management
- Playoff bracket system

## Performance Considerations

### Database Optimization
- Indexes on frequently queried columns
- Efficient joins for complex queries
- Connection pooling for high concurrency

### API Performance
- Response caching for static data
- Pagination for large datasets
- Rate limiting to prevent abuse
- Compression for large responses

### iOS Performance
- Lazy loading for large lists
- Image caching for player photos
- Background refresh for live data
- Memory management for real-time updates

## Security Considerations

### Authentication
- JWT tokens with refresh mechanism
- Secure password hashing with bcrypt
- Rate limiting on auth endpoints

### Data Protection
- Input validation on all endpoints
- SQL injection prevention
- XSS protection with helmet
- CORS configuration

### API Security
- API key management for external services
- Request signing for sensitive operations
- Audit logging for admin actions

## Monitoring and Logging

### Backend Monitoring
- Winston for structured logging
- Error tracking and alerting
- Performance monitoring
- Health check endpoints

### iOS Monitoring
- Crash reporting with Crashlytics
- Analytics for user behavior
- Performance monitoring
- Error tracking

## Future Enhancements

### Planned Features
- Mobile push notifications
- Advanced analytics and insights
- Social features (chat, forums)
- Multi-language support
- Dark mode support
- Widget support for iOS

### Technical Improvements
- GraphQL API for more efficient data fetching
- Offline support for iOS app
- Advanced caching strategies
- Machine learning for player projections

## Contributing

### Code Standards
- ESLint for JavaScript/Node.js
- SwiftLint for Swift code
- Prettier for code formatting
- Conventional commits for version control

### Pull Request Process
1. Create feature branch from main
2. Implement changes with tests
3. Update documentation
4. Submit PR with detailed description
5. Code review and approval
6. Merge to main branch

## Support and Resources

### Documentation
- API documentation with Swagger
- iOS app user guide
- Database schema documentation
- Deployment guides

### Community
- GitHub issues for bug reports
- Discord server for community discussion
- Wiki for detailed guides
- FAQ for common questions

---

This development guide provides a comprehensive overview of the Fantasy Soccer App project. For specific implementation details, refer to the individual component documentation and code comments. 