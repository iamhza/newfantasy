const express = require('express');
const router = express.Router();
const Joi = require('joi');
const { logger } = require('../utils/logger');
const { supabase } = require('../config/database');
const { calculateFantasyPoints } = require('../utils/scoring');

// Validation schemas
const makePickSchema = Joi.object({
  playerId: Joi.string().uuid().required(),
  round: Joi.number().integer().min(1).required(),
  pickNumber: Joi.number().integer().min(1).required(),
  isAutoPick: Joi.boolean().default(false)
});

const getDraftPicksSchema = Joi.object({
  leagueId: Joi.string().uuid().required()
});

// Get draft picks for a league
router.get('/picks/:leagueId', async (req, res) => {
  try {
    const { error, value } = getDraftPicksSchema.validate({
      leagueId: req.params.leagueId
    });

    if (error) {
      return res.status(400).json({ error: error.details[0].message });
    }

    const { leagueId } = value;

    // Get league info
    const { data: league, error: leagueError } = await supabase
      .from('leagues')
      .select('*')
      .eq('id', leagueId)
      .single();

    if (leagueError || !league) {
      return res.status(404).json({ error: 'League not found' });
    }

    // Get all draft picks for the league
    const { data: picks, error: picksError } = await supabase
      .from('draft_picks')
      .select(`
        *,
        player:players(*),
        team:teams(*)
      `)
      .eq('league_id', leagueId)
      .order('round', { ascending: true })
      .order('pick_number', { ascending: true });

    if (picksError) {
      logger.error('Error fetching draft picks:', picksError);
      return res.status(500).json({ error: 'Failed to fetch draft picks' });
    }

    // Format the response
    const formattedPicks = picks.map(pick => ({
      id: pick.id,
      round: pick.round,
      pickNumber: pick.pick_number,
      teamId: pick.team_id,
      team: pick.team,
      player: pick.player,
      isAutoPick: pick.is_auto_pick,
      pickedAt: pick.picked_at,
      createdAt: pick.created_at
    }));

    res.json({
      picks: formattedPicks,
      league: {
        id: league.id,
        name: league.name,
        maxTeams: league.max_teams,
        rosterSettings: league.roster_settings,
        status: league.status
      }
    });

  } catch (error) {
    logger.error('Error in getDraftPicks:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// Make a draft pick
router.post('/pick', async (req, res) => {
  try {
    const { error, value } = makePickSchema.validate(req.body);

    if (error) {
      return res.status(400).json({ error: error.details[0].message });
    }

    const { playerId, round, pickNumber, isAutoPick } = value;
    const userId = req.user.id;

    // Get the league ID from the request
    const leagueId = req.body.leagueId;
    if (!leagueId) {
      return res.status(400).json({ error: 'League ID is required' });
    }

    // Verify the league exists and is in drafting status
    const { data: league, error: leagueError } = await supabase
      .from('leagues')
      .select('*')
      .eq('id', leagueId)
      .single();

    if (leagueError || !league) {
      return res.status(404).json({ error: 'League not found' });
    }

    if (league.status !== 'drafting') {
      return res.status(400).json({ error: 'League is not in drafting status' });
    }

    // Get the team making the pick
    const { data: team, error: teamError } = await supabase
      .from('teams')
      .select('*')
      .eq('league_id', leagueId)
      .eq('user_id', userId)
      .single();

    if (teamError || !team) {
      return res.status(404).json({ error: 'Team not found' });
    }

    // Verify it's the team's turn to pick
    const expectedPick = await getExpectedPick(leagueId, team.id);
    if (expectedPick.round !== round || expectedPick.pickNumber !== pickNumber) {
      return res.status(400).json({ error: 'Not your turn to pick' });
    }

    // Verify the player is available
    const { data: player, error: playerError } = await supabase
      .from('players')
      .select('*')
      .eq('id', playerId)
      .single();

    if (playerError || !player) {
      return res.status(404).json({ error: 'Player not found' });
    }

    // Check if player is already drafted
    const { data: existingPick, error: existingError } = await supabase
      .from('draft_picks')
      .select('*')
      .eq('player_id', playerId)
      .eq('league_id', leagueId)
      .single();

    if (existingPick) {
      return res.status(400).json({ error: 'Player already drafted' });
    }

    // Create the draft pick
    const { data: draftPick, error: pickError } = await supabase
      .from('draft_picks')
      .insert({
        league_id: leagueId,
        team_id: team.id,
        round: round,
        pick_number: pickNumber,
        player_id: playerId,
        is_auto_pick: isAutoPick,
        picked_at: new Date().toISOString()
      })
      .select()
      .single();

    if (pickError) {
      logger.error('Error creating draft pick:', pickError);
      return res.status(500).json({ error: 'Failed to make draft pick' });
    }

    // Add player to team roster
    const { error: rosterError } = await supabase
      .from('roster_spots')
      .insert({
        team_id: team.id,
        player_id: playerId,
        position: 'BENCH', // Default to bench, can be moved later
        is_starting: false
      });

    if (rosterError) {
      logger.error('Error adding player to roster:', rosterError);
      // Don't fail the request, but log the error
    }

    // Check if draft is complete
    const totalPicks = league.max_teams * league.roster_settings.total_roster;
    const { count: picksMade } = await supabase
      .from('draft_picks')
      .select('*', { count: 'exact', head: true })
      .eq('league_id', leagueId);

    if (picksMade >= totalPicks) {
      // Draft is complete, update league status
      await supabase
        .from('leagues')
        .update({ status: 'active' })
        .eq('id', leagueId);
    }

    // Emit real-time update
    const io = req.app.get('io');
    io.to(`draft-${leagueId}`).emit('pick-made', {
      leagueId,
      pick: {
        id: draftPick.id,
        round: draftPick.round,
        pickNumber: draftPick.pick_number,
        teamId: draftPick.team_id,
        team: team,
        player: player,
        isAutoPick: draftPick.is_auto_pick,
        pickedAt: draftPick.picked_at
      },
      isDraftComplete: picksMade >= totalPicks
    });

    res.json({
      success: true,
      pick: {
        id: draftPick.id,
        round: draftPick.round,
        pickNumber: draftPick.pick_number,
        teamId: draftPick.team_id,
        team: team,
        player: player,
        isAutoPick: draftPick.is_auto_pick,
        pickedAt: draftPick.picked_at
      },
      isDraftComplete: picksMade >= totalPicks
    });

  } catch (error) {
    logger.error('Error in makePick:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// Get available players for drafting
router.get('/available/:leagueId', async (req, res) => {
  try {
    const { leagueId } = req.params;

    // Get league info
    const { data: league, error: leagueError } = await supabase
      .from('leagues')
      .select('*')
      .eq('id', leagueId)
      .single();

    if (leagueError || !league) {
      return res.status(404).json({ error: 'League not found' });
    }

    // Get all players
    const { data: players, error: playersError } = await supabase
      .from('players')
      .select('*')
      .eq('is_active', true)
      .order('name');

    if (playersError) {
      logger.error('Error fetching players:', playersError);
      return res.status(500).json({ error: 'Failed to fetch players' });
    }

    // Get drafted players for this league
    const { data: draftedPlayers, error: draftedError } = await supabase
      .from('draft_picks')
      .select('player_id')
      .eq('league_id', leagueId);

    if (draftedError) {
      logger.error('Error fetching drafted players:', draftedError);
      return res.status(500).json({ error: 'Failed to fetch drafted players' });
    }

    const draftedPlayerIds = draftedPlayers.map(dp => dp.player_id);

    // Filter out drafted players
    const availablePlayers = players.filter(player => 
      !draftedPlayerIds.includes(player.id)
    );

    // Get player stats for the current season
    const { data: playerStats, error: statsError } = await supabase
      .from('player_stats')
      .select('*')
      .eq('season', '2024');

    if (statsError) {
      logger.error('Error fetching player stats:', statsError);
    }

    // Combine players with their stats
    const playersWithStats = availablePlayers.map(player => {
      const stats = playerStats?.find(ps => ps.player_id === player.id);
      return {
        player,
        stats,
        projectedPoints: stats ? calculateFantasyPoints(stats, league.scoring_settings) : 0
      };
    });

    // Sort by projected points
    playersWithStats.sort((a, b) => b.projectedPoints - a.projectedPoints);

    res.json({
      players: playersWithStats,
      total: playersWithStats.length
    });

  } catch (error) {
    logger.error('Error in getAvailablePlayers:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// Get draft order for a league
router.get('/order/:leagueId', async (req, res) => {
  try {
    const { leagueId } = req.params;

    // Get league info
    const { data: league, error: leagueError } = await supabase
      .from('leagues')
      .select('*')
      .eq('id', leagueId)
      .single();

    if (leagueError || !league) {
      return res.status(404).json({ error: 'League not found' });
    }

    // Get teams in draft order
    const { data: teams, error: teamsError } = await supabase
      .from('teams')
      .select('*')
      .eq('league_id', leagueId)
      .order('draft_position');

    if (teamsError) {
      logger.error('Error fetching teams:', teamsError);
      return res.status(500).json({ error: 'Failed to fetch teams' });
    }

    res.json({
      draftOrder: teams.map(team => ({
        id: team.id,
        name: team.name,
        draftPosition: team.draft_position,
        userId: team.user_id
      }))
    });

  } catch (error) {
    logger.error('Error in getDraftOrder:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// Helper function to get expected pick for a team
async function getExpectedPick(leagueId, teamId) {
  const { data: team } = await supabase
    .from('teams')
    .select('draft_position')
    .eq('id', teamId)
    .single();

  const { count: picksMade } = await supabase
    .from('draft_picks')
    .select('*', { count: 'exact', head: true })
    .eq('league_id', leagueId);

  const totalTeams = 12; // This should come from league settings
  const round = Math.floor(picksMade / totalTeams) + 1;
  const pickInRound = (picksMade % totalTeams) + 1;

  // Snake draft logic
  const isReverseRound = round % 2 === 0;
  const pickNumber = isReverseRound ? 
    totalTeams - pickInRound + 1 : 
    pickInRound;

  return { round, pickNumber };
}

module.exports = router; 