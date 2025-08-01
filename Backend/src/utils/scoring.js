/**
 * Fantasy Soccer Scoring System
 * PPR-style scoring adapted for soccer
 */

/**
 * Calculate fantasy points for a player based on their stats and league scoring settings
 * @param {Object} stats - Player stats object
 * @param {Object} scoringSettings - League scoring settings
 * @returns {number} Total fantasy points
 */
function calculateFantasyPoints(stats, scoringSettings) {
  let totalPoints = 0;

  // Passes completed (PPR equivalent)
  totalPoints += (stats.passes_completed || 0) * scoringSettings.passes_completed;

  // Key passes (passes leading to shots)
  totalPoints += (stats.key_passes || 0) * scoringSettings.key_passes;

  // Assists
  totalPoints += (stats.assists || 0) * scoringSettings.assists;

  // Goals
  totalPoints += (stats.goals || 0) * scoringSettings.goals;

  // Clean sheets (based on position)
  const cleanSheetPoints = getCleanSheetPoints(stats, scoringSettings);
  totalPoints += cleanSheetPoints;

  // Saves (goalkeepers only)
  totalPoints += (stats.saves || 0) * scoringSettings.saves;

  // Minutes played
  totalPoints += (stats.minutes_played || 0) * scoringSettings.minutes_played;

  // Cards (penalties)
  totalPoints += (stats.yellow_cards || 0) * scoringSettings.yellow_cards;
  totalPoints += (stats.red_cards || 0) * scoringSettings.red_cards;

  return Math.round(totalPoints * 10) / 10; // Round to 1 decimal place
}

/**
 * Get clean sheet points based on player position
 * @param {Object} stats - Player stats
 * @param {Object} scoringSettings - League scoring settings
 * @returns {number} Clean sheet points
 */
function getCleanSheetPoints(stats, scoringSettings) {
  // This would need to be calculated based on team performance
  // For now, we'll use a simplified approach
  const cleanSheets = stats.clean_sheets || 0;
  
  // Determine position-based clean sheet points
  // This is a simplified version - in reality, you'd need to check
  // if the player's team kept a clean sheet in each match
  let cleanSheetPoints = 0;
  
  // This would be determined by the player's position
  // For now, we'll use a default value
  cleanSheetPoints = cleanSheets * scoringSettings.clean_sheets_def;
  
  return cleanSheetPoints;
}

/**
 * Calculate weekly fantasy points for a player
 * @param {Object} weeklyStats - Player's weekly stats
 * @param {Object} scoringSettings - League scoring settings
 * @returns {number} Weekly fantasy points
 */
function calculateWeeklyPoints(weeklyStats, scoringSettings) {
  return calculateFantasyPoints(weeklyStats, scoringSettings);
}

/**
 * Calculate season total fantasy points
 * @param {Array} weeklyStats - Array of weekly stats
 * @param {Object} scoringSettings - League scoring settings
 * @returns {number} Season total fantasy points
 */
function calculateSeasonPoints(weeklyStats, scoringSettings) {
  return weeklyStats.reduce((total, weekStats) => {
    return total + calculateWeeklyPoints(weekStats, scoringSettings);
  }, 0);
}

/**
 * Get player's average fantasy points per game
 * @param {Object} stats - Player stats
 * @param {Object} scoringSettings - League scoring settings
 * @returns {number} Average points per game
 */
function getAveragePointsPerGame(stats, scoringSettings) {
  const totalPoints = calculateFantasyPoints(stats, scoringSettings);
  const gamesPlayed = stats.matches_played || 1;
  
  return Math.round((totalPoints / gamesPlayed) * 10) / 10;
}

/**
 * Calculate projected fantasy points for upcoming matches
 * @param {Object} historicalStats - Player's historical stats
 * @param {number} upcomingMatches - Number of upcoming matches
 * @param {Object} scoringSettings - League scoring settings
 * @returns {number} Projected fantasy points
 */
function calculateProjectedPoints(historicalStats, upcomingMatches, scoringSettings) {
  const avgPointsPerGame = getAveragePointsPerGame(historicalStats, scoringSettings);
  return Math.round(avgPointsPerGame * upcomingMatches * 10) / 10;
}

/**
 * Get player's fantasy value rating (1-100)
 * @param {Object} stats - Player stats
 * @param {Object} scoringSettings - League scoring settings
 * @param {string} position - Player position
 * @returns {number} Fantasy value rating (1-100)
 */
function getFantasyValueRating(stats, scoringSettings, position) {
  const totalPoints = calculateFantasyPoints(stats, scoringSettings);
  const gamesPlayed = stats.matches_played || 1;
  const avgPoints = totalPoints / gamesPlayed;
  
  // Position-based value adjustments
  let positionMultiplier = 1.0;
  
  switch (position) {
    case 'GK':
      positionMultiplier = 0.8; // Goalkeepers typically score fewer points
      break;
    case 'DEF':
      positionMultiplier = 0.9; // Defenders score moderately
      break;
    case 'MID':
      positionMultiplier = 1.1; // Midfielders score well
      break;
    case 'FWD':
      positionMultiplier = 1.2; // Forwards score the most
      break;
  }
  
  const adjustedPoints = avgPoints * positionMultiplier;
  
  // Convert to 1-100 scale (this is arbitrary and can be adjusted)
  const rating = Math.min(100, Math.max(1, Math.round(adjustedPoints * 5)));
  
  return rating;
}

/**
 * Get player's consistency rating based on performance variance
 * @param {Array} weeklyStats - Array of weekly performance stats
 * @param {Object} scoringSettings - League scoring settings
 * @returns {number} Consistency rating (1-100)
 */
function getConsistencyRating(weeklyStats, scoringSettings) {
  if (weeklyStats.length < 2) return 50; // Default for insufficient data
  
  const weeklyPoints = weeklyStats.map(week => 
    calculateWeeklyPoints(week, scoringSettings)
  );
  
  const avgPoints = weeklyPoints.reduce((sum, points) => sum + points, 0) / weeklyPoints.length;
  
  // Calculate variance
  const variance = weeklyPoints.reduce((sum, points) => {
    return sum + Math.pow(points - avgPoints, 2);
  }, 0) / weeklyPoints.length;
  
  const standardDeviation = Math.sqrt(variance);
  const coefficientOfVariation = standardDeviation / avgPoints;
  
  // Convert to consistency rating (lower CV = higher consistency)
  const consistencyRating = Math.max(1, Math.min(100, 
    Math.round(100 - (coefficientOfVariation * 100))
  ));
  
  return consistencyRating;
}

/**
 * Get player's injury risk rating
 * @param {Object} player - Player object
 * @param {Array} injuryHistory - Player's injury history
 * @returns {number} Injury risk rating (1-100)
 */
function getInjuryRiskRating(player, injuryHistory = []) {
  let riskScore = 50; // Base risk score
  
  // Age factor
  if (player.age) {
    if (player.age > 30) riskScore += 10;
    if (player.age > 35) riskScore += 15;
  }
  
  // Current injury status
  if (player.is_injured) {
    riskScore += 30;
  }
  
  // Injury history
  if (injuryHistory.length > 0) {
    const recentInjuries = injuryHistory.filter(injury => 
      new Date(injury.date) > new Date(Date.now() - 365 * 24 * 60 * 60 * 1000)
    );
    riskScore += recentInjuries.length * 10;
  }
  
  return Math.min(100, Math.max(1, riskScore));
}

/**
 * Get player's form rating based on recent performance
 * @param {Array} recentStats - Recent match stats (last 5-10 matches)
 * @param {Object} scoringSettings - League scoring settings
 * @returns {number} Form rating (1-100)
 */
function getFormRating(recentStats, scoringSettings) {
  if (recentStats.length === 0) return 50;
  
  const recentPoints = recentStats.map(stats => 
    calculateFantasyPoints(stats, scoringSettings)
  );
  
  const avgRecentPoints = recentPoints.reduce((sum, points) => sum + points, 0) / recentPoints.length;
  
  // Compare to league average (this would need to be calculated from all players)
  // For now, we'll use a simple scale
  const formRating = Math.min(100, Math.max(1, Math.round(avgRecentPoints * 10)));
  
  return formRating;
}

/**
 * Get comprehensive player analysis
 * @param {Object} player - Player object
 * @param {Object} stats - Player stats
 * @param {Array} weeklyStats - Weekly performance data
 * @param {Object} scoringSettings - League scoring settings
 * @returns {Object} Comprehensive player analysis
 */
function getPlayerAnalysis(player, stats, weeklyStats, scoringSettings) {
  const totalPoints = calculateFantasyPoints(stats, scoringSettings);
  const avgPointsPerGame = getAveragePointsPerGame(stats, scoringSettings);
  const fantasyValue = getFantasyValueRating(stats, scoringSettings, player.position);
  const consistency = getConsistencyRating(weeklyStats, scoringSettings);
  const form = getFormRating(weeklyStats.slice(-5), scoringSettings); // Last 5 matches
  const injuryRisk = getInjuryRiskRating(player);
  
  return {
    totalPoints,
    avgPointsPerGame,
    fantasyValue,
    consistency,
    form,
    injuryRisk,
    analysis: {
      strengths: getPlayerStrengths(stats, scoringSettings),
      weaknesses: getPlayerWeaknesses(stats, scoringSettings),
      recommendations: getPlayerRecommendations(player, stats, scoringSettings)
    }
  };
}

/**
 * Get player's strengths based on stats
 * @param {Object} stats - Player stats
 * @param {Object} scoringSettings - League scoring settings
 * @returns {Array} Array of strengths
 */
function getPlayerStrengths(stats, scoringSettings) {
  const strengths = [];
  
  if (stats.goals > 0) strengths.push('Goal scoring');
  if (stats.assists > 0) strengths.push('Playmaking');
  if (stats.passes_completed > 50) strengths.push('Passing accuracy');
  if (stats.key_passes > 5) strengths.push('Chance creation');
  if (stats.clean_sheets > 0) strengths.push('Defensive solidity');
  if (stats.saves > 0) strengths.push('Shot stopping');
  if (stats.minutes_played > 1000) strengths.push('Playing time');
  
  return strengths;
}

/**
 * Get player's weaknesses based on stats
 * @param {Object} stats - Player stats
 * @param {Object} scoringSettings - League scoring settings
 * @returns {Array} Array of weaknesses
 */
function getPlayerWeaknesses(stats, scoringSettings) {
  const weaknesses = [];
  
  if (stats.yellow_cards > 3) weaknesses.push('Disciplinary issues');
  if (stats.red_cards > 0) weaknesses.push('Red card risk');
  if (stats.minutes_played < 500) weaknesses.push('Limited playing time');
  if (stats.passes_completed < 20) weaknesses.push('Low involvement');
  
  return weaknesses;
}

/**
 * Get player recommendations
 * @param {Object} player - Player object
 * @param {Object} stats - Player stats
 * @param {Object} scoringSettings - League scoring settings
 * @returns {Array} Array of recommendations
 */
function getPlayerRecommendations(player, stats, scoringSettings) {
  const recommendations = [];
  
  const avgPoints = getAveragePointsPerGame(stats, scoringSettings);
  
  if (avgPoints > 15) {
    recommendations.push('High-value starter');
  } else if (avgPoints > 10) {
    recommendations.push('Solid starter');
  } else if (avgPoints > 5) {
    recommendations.push('Bench option');
  } else {
    recommendations.push('Avoid');
  }
  
  if (player.is_injured) {
    recommendations.push('Monitor injury status');
  }
  
  return recommendations;
}

module.exports = {
  calculateFantasyPoints,
  calculateWeeklyPoints,
  calculateSeasonPoints,
  getAveragePointsPerGame,
  calculateProjectedPoints,
  getFantasyValueRating,
  getConsistencyRating,
  getInjuryRiskRating,
  getFormRating,
  getPlayerAnalysis
}; 