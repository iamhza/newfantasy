-- Fantasy Soccer Database Schema
-- PPR-style scoring system for soccer

-- Users table
CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    email VARCHAR(255) UNIQUE NOT NULL,
    username VARCHAR(50) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    first_name VARCHAR(100),
    last_name VARCHAR(100),
    avatar_url TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Leagues table
CREATE TABLE leagues (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(100) NOT NULL,
    description TEXT,
    owner_id UUID REFERENCES users(id) ON DELETE CASCADE,
    max_teams INTEGER DEFAULT 12,
    current_teams INTEGER DEFAULT 0,
    draft_date TIMESTAMP WITH TIME ZONE,
    draft_order JSONB, -- Array of team IDs in draft order
    season_start_date DATE,
    season_end_date DATE,
    is_public BOOLEAN DEFAULT false,
    entry_fee DECIMAL(10,2) DEFAULT 0,
    prize_pool JSONB, -- Prize distribution structure
    scoring_settings JSONB NOT NULL DEFAULT '{
        "passes_completed": 1,
        "key_passes": 2,
        "assists": 6,
        "goals": 10,
        "clean_sheets_def": 4,
        "clean_sheets_mid": 4,
        "clean_sheets_gk": 6,
        "saves": 1,
        "minutes_played": 0.1,
        "yellow_cards": -1,
        "red_cards": -3
    }',
    roster_settings JSONB NOT NULL DEFAULT '{
        "gk": 1,
        "def": 4,
        "mid": 4,
        "fwd": 2,
        "bench": 6
    }',
    status VARCHAR(20) DEFAULT 'drafting', -- drafting, active, completed
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Teams table (user's team in a league)
CREATE TABLE teams (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    league_id UUID REFERENCES leagues(id) ON DELETE CASCADE,
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    name VARCHAR(100) NOT NULL,
    logo_url TEXT,
    draft_position INTEGER,
    waiver_priority INTEGER DEFAULT 1,
    total_points DECIMAL(10,2) DEFAULT 0,
    wins INTEGER DEFAULT 0,
    losses INTEGER DEFAULT 0,
    ties INTEGER DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(league_id, user_id)
);

-- Players table (soccer players)
CREATE TABLE players (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    external_id VARCHAR(100) UNIQUE, -- ID from soccer API
    name VARCHAR(100) NOT NULL,
    position VARCHAR(10) NOT NULL, -- GK, DEF, MID, FWD
    team VARCHAR(100), -- Club team
    league VARCHAR(100), -- League they play in
    country VARCHAR(100),
    age INTEGER,
    height INTEGER, -- in cm
    weight INTEGER, -- in kg
    jersey_number INTEGER,
    photo_url TEXT,
    is_active BOOLEAN DEFAULT true,
    is_injured BOOLEAN DEFAULT false,
    injury_status TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Player stats table (season stats)
CREATE TABLE player_stats (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    player_id UUID REFERENCES players(id) ON DELETE CASCADE,
    season VARCHAR(10) NOT NULL, -- e.g., "2024"
    league VARCHAR(100),
    team VARCHAR(100),
    matches_played INTEGER DEFAULT 0,
    minutes_played INTEGER DEFAULT 0,
    goals INTEGER DEFAULT 0,
    assists INTEGER DEFAULT 0,
    passes_completed INTEGER DEFAULT 0,
    key_passes INTEGER DEFAULT 0,
    clean_sheets INTEGER DEFAULT 0,
    saves INTEGER DEFAULT 0,
    yellow_cards INTEGER DEFAULT 0,
    red_cards INTEGER DEFAULT 0,
    fantasy_points DECIMAL(10,2) DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(player_id, season, league)
);

-- Roster spots table (players on teams)
CREATE TABLE roster_spots (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    team_id UUID REFERENCES teams(id) ON DELETE CASCADE,
    player_id UUID REFERENCES players(id) ON DELETE CASCADE,
    position VARCHAR(20) NOT NULL, -- GK, DEF, MID, FWD, BENCH
    is_starting BOOLEAN DEFAULT false,
    added_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(team_id, player_id)
);

-- Matchups table (weekly head-to-head)
CREATE TABLE matchups (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    league_id UUID REFERENCES leagues(id) ON DELETE CASCADE,
    week INTEGER NOT NULL,
    team1_id UUID REFERENCES teams(id) ON DELETE CASCADE,
    team2_id UUID REFERENCES teams(id) ON DELETE CASCADE,
    team1_score DECIMAL(10,2) DEFAULT 0,
    team2_score DECIMAL(10,2) DEFAULT 0,
    winner_id UUID REFERENCES teams(id),
    is_tie BOOLEAN DEFAULT false,
    status VARCHAR(20) DEFAULT 'scheduled', -- scheduled, active, completed
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Trades table
CREATE TABLE trades (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    league_id UUID REFERENCES leagues(id) ON DELETE CASCADE,
    team1_id UUID REFERENCES teams(id) ON DELETE CASCADE,
    team2_id UUID REFERENCES teams(id) ON DELETE CASCADE,
    team1_players JSONB, -- Array of player IDs
    team2_players JSONB, -- Array of player IDs
    status VARCHAR(20) DEFAULT 'pending', -- pending, accepted, rejected, cancelled
    expires_at TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Waiver claims table
CREATE TABLE waiver_claims (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    league_id UUID REFERENCES leagues(id) ON DELETE CASCADE,
    team_id UUID REFERENCES teams(id) ON DELETE CASCADE,
    add_player_id UUID REFERENCES players(id) ON DELETE CASCADE,
    drop_player_id UUID REFERENCES players(id) ON DELETE CASCADE,
    priority INTEGER NOT NULL,
    status VARCHAR(20) DEFAULT 'pending', -- pending, approved, rejected
    processed_at TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Draft picks table
CREATE TABLE draft_picks (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    league_id UUID REFERENCES leagues(id) ON DELETE CASCADE,
    team_id UUID REFERENCES teams(id) ON DELETE CASCADE,
    round INTEGER NOT NULL,
    pick_number INTEGER NOT NULL,
    player_id UUID REFERENCES players(id),
    is_auto_pick BOOLEAN DEFAULT false,
    picked_at TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(league_id, round, pick_number)
);

-- League invites table
CREATE TABLE league_invites (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    league_id UUID REFERENCES leagues(id) ON DELETE CASCADE,
    inviter_id UUID REFERENCES users(id) ON DELETE CASCADE,
    invitee_email VARCHAR(255) NOT NULL,
    invite_code VARCHAR(50) UNIQUE NOT NULL,
    status VARCHAR(20) DEFAULT 'pending', -- pending, accepted, declined
    expires_at TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Notifications table
CREATE TABLE notifications (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    title VARCHAR(255) NOT NULL,
    message TEXT NOT NULL,
    type VARCHAR(50) NOT NULL, -- trade, waiver, draft, matchup, etc.
    data JSONB, -- Additional data for the notification
    is_read BOOLEAN DEFAULT false,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create indexes for better performance
CREATE INDEX idx_teams_league_id ON teams(league_id);
CREATE INDEX idx_teams_user_id ON teams(user_id);
CREATE INDEX idx_roster_spots_team_id ON roster_spots(team_id);
CREATE INDEX idx_roster_spots_player_id ON roster_spots(player_id);
CREATE INDEX idx_matchups_league_week ON matchups(league_id, week);
CREATE INDEX idx_player_stats_player_season ON player_stats(player_id, season);
CREATE INDEX idx_players_position ON players(position);
CREATE INDEX idx_players_team ON players(team);
CREATE INDEX idx_notifications_user_read ON notifications(user_id, is_read);

-- Create updated_at triggers
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER update_users_updated_at BEFORE UPDATE ON users FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_leagues_updated_at BEFORE UPDATE ON leagues FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_teams_updated_at BEFORE UPDATE ON teams FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_players_updated_at BEFORE UPDATE ON players FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_player_stats_updated_at BEFORE UPDATE ON player_stats FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_matchups_updated_at BEFORE UPDATE ON matchups FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_trades_updated_at BEFORE UPDATE ON trades FOR EACH ROW EXECUTE FUNCTION update_updated_at_column(); 