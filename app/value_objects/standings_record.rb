class StandingsRecord
  attr_reader :team, :games, :wins, :losses, :ties, :points_for, :points_against

  def initialize(team:, games: 0, wins: 0, losses: 0, ties: 0, points_for: 0, points_against: 0)
    @team = team
    @games = games
    @wins = wins
    @losses = losses
    @ties = ties
    @points_for = points_for
    @points_against = points_against
  end

  def win_percentage
    (wins.to_f + (0.5 * ties.to_f)) / games.to_f
  end

  def pf_average
    points_for.to_f / games.to_f
  end

  def pa_average
    points_against.to_f / games.to_f
  end
end
