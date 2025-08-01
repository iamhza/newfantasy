# Fantasy Soccer iOS Mock App

A quick mock version of the Fantasy Soccer app to test the concept on your iPhone!

## 🚀 Quick Start

### Option 1: Simulator (Fastest)
1. Open the project in Xcode:
   ```bash
   open FantasySoccer.xcodeproj
   ```

2. Select a simulator (iPhone 15 Pro recommended)
3. Press `Cmd + R` to build and run

### Option 2: Your iPhone
1. Connect your iPhone to your Mac
2. Open the project in Xcode
3. Select your iPhone as the target device
4. You may need to:
   - Sign in with your Apple ID in Xcode
   - Trust the developer certificate on your iPhone
5. Press `Cmd + R` to build and run

## 📱 What You'll See

### Home Tab
- App overview with PPR scoring rules
- Mock leagues (Premier League Fantasy, Champions League Elite, World Cup 2024)
- Quick actions to create/join leagues

### Draft Tab
- **Live Draft Board**: Grid showing all picks (similar to Sleeper/ESPN)
- **Draft Header**: Progress bar, current pick, timer, team turn
- **Player List**: Searchable list of available players
- **Player Details**: Tap any player to see stats and projections

### My Team Tab
- Your fantasy team roster
- Starting lineup vs bench
- Weekly points for each player
- Team record and total points

### League Tab
- League standings
- Live matchups
- Team records and points

## ⚽ PPR Scoring System

**Points Per Pass (PPP) - Soccer's version of PPR:**
- **Passes Completed**: 1 point each
- **Key Passes**: 2 points each (passes leading to shots)
- **Assists**: 6 points each
- **Goals**: 10 points each
- **Clean Sheets**: 4-6 points (position-based)
- **Saves**: 1 point each (goalkeepers)
- **Minutes Played**: 0.1 points per minute
- **Yellow Cards**: -1 point
- **Red Cards**: -3 points

## 🎯 Features Demonstrated

- **Real-time Draft Interface**: Similar to top fantasy platforms
- **Player Search & Filtering**: By position, team, name
- **Position-based Scoring**: Different rules for GK, DEF, MID, FWD
- **Team Management**: Roster view with starters/bench
- **League Standings**: Win/loss records and points
- **Live Matchups**: Real-time scoring display

## 🔧 Technical Details

- **Framework**: SwiftUI
- **Architecture**: MVVM
- **iOS Target**: 17.2+
- **Mock Data**: Real soccer players (Messi, Haaland, De Bruyne, etc.)

## 🎨 Design Features

- **Soccer-themed**: Green color palette
- **Position Colors**: Blue (GK), Green (DEF), Orange (MID), Red (FWD)
- **Modern UI**: Cards, shadows, rounded corners
- **Responsive**: Works on all iPhone sizes

## 🚀 Next Steps

This mock demonstrates the core concept. The full app would include:
- Real backend API integration
- Live data from soccer APIs
- Real-time WebSocket updates
- User authentication
- League creation and management
- Actual draft functionality
- Push notifications

---

**Ready to test the future of fantasy soccer! ⚽🏆** 