class Matchup < ApplicationRecord
  # Matchup Statuses
  HOME_WINNER = 'HOME'.freeze
  AWAY_WINNER = 'AWAY'.freeze
  TIE = 'TIE'.freeze
  UNDECIDED = 'UNDECIDED'.freeze

  # Playoff Tiers
  REGULAR_SEASON = 'NONE'.freeze
  WINNERS_BRACKET = 'WINNERS_BRACKET'.freeze
  WINNERS_CONSOLATION = 'WINNERS_CONSOLATION_LADDER'.freeze
  LOSERS_CONSOLATION = 'LOSERS_CONSOLATION_LADDER'.freeze

  belongs_to :league
  belongs_to :home_team, class_name: 'Team'
  belongs_to :away_team, class_name: 'Team'
  belongs_to :winning_team, class_name: 'Team', foreign_key: 'winner_id', optional: true
  belongs_to :losing_team, class_name: 'Team', foreign_key: 'loser_id', optional: true

  before_save :update_winner_loser

  scope :decided, -> { where.not(status: UNDECIDED) }
  scope :regular_season, -> { where(playoff_tier: REGULAR_SEASON) }
  scope :postseason, -> { where.not(playoff_tier: REGULAR_SEASON) }
  scope :playoffs, -> { where(playoff_tier: WINNERS_BRACKET) }
  scope :by_team, -> (team) { where('home_team_id = ? OR away_team_id = ?', team.id, team.id) }
  scope :by_league, -> (league) { where(league_id: league.id) }
  scope :in_order, -> { order(:season, :period) }
  scope :by_season, -> (season) { where(season: season) }
  scope :by_period, -> (period) { where(period: period) }

  def self.championship_games(league)
    championship_weeks = select('MAX(period) AS period', 'season')
      .playoffs
      .decided
      .by_league(league)
      .group(:season)
      .as_json

    result = []
    championship_weeks.each_with_index do |championship_week, i|
      relation = by_season(championship_week['season'])
        .by_period(championship_week['period'])
        .playoffs

      result = i.zero? ? relation : result.or(relation)
    end

    result
  end

  def team_won?(team)
    (team.id == home_team_id && home_winner?) || (team.id == away_team_id && away_winner?)
  end

  def team_lost?(team)
    (team.id == home_team_id && away_winner?) || (team.id == away_team_id && home_winner?)
  end

  def tie?
    status == TIE
  end

  def winner_decided?
    status.in?([HOME_WINNER, AWAY_WINNER])
  end

  def home_winner?
    status == HOME_WINNER
  end

  def away_winner?
    status == AWAY_WINNER
  end

  def update_winner_loser
    return unless winner_decided?
    self.winner_id = home_winner? ? home_team_id : away_team_id
    self.loser_id = home_winner? ? away_team_id : home_team_id
  end
end
