class StandingsGenerator
  attr_reader :league

  def initialize(league, include_postseason: false)
    @league = league
  end

  def run
    standings = generate_standings
    standings.sort_by! { |record| record.win_percentage }.reverse
  end

  private

  def teams
    @teams ||= league.teams.index_by(&:id)
  end

  def generate_standings
    standings = ApplicationRecord.connection.execute(db_standings_sql)

    standings.map do |team_record|
      StandingsRecord.new(
        team:           teams[team_record[0]],
        games:          team_record[1],
        wins:           team_record[2],
        losses:         team_record[3],
        ties:           team_record[4],
        points_for:     team_record[5],
        points_against: team_record[6],
      )
    end
  end

  def db_standings_sql
    <<-SQL.squish
      SELECT
        team_id,
        COUNT(*) AS games,
        SUM(CASE status WHEN 'WIN' THEN 1 ELSE 0 END) AS wins,
        SUM(CASE status WHEN 'LOSS' THEN 1 ELSE 0 END) AS losses,
        SUM(CASE status WHEN 'TIE' THEN 1 ELSE 0 END) AS ties,
        SUM(score) AS points_for,
        SUM(opponent_score) AS points_against
      FROM (
        SELECT
          id, league_id, season, period, away_team_id AS team_id, away_team_score AS score,
          home_team_id AS opponent_id, home_team_score AS opponent_score,
          (CASE status WHEN 'AWAY' THEN 'WIN' WHEN 'HOME' THEN 'LOSS' ELSE 'TIE' END) AS status
        FROM matchups
        WHERE status != 'UNDECIDED'
        UNION
        SELECT
          id, league_id, season, period, home_team_id AS team_id, home_team_score AS score,
          away_team_id AS opponent_id, away_team_score AS opponent_score,
          (CASE status WHEN 'HOME' THEN 'WIN' WHEN 'AWAY' THEN 'LOSS' ELSE 'TIE' END) AS status
        FROM matchups
        WHERE status != 'UNDECIDED'
      ) matchups
      WHERE league_id = #{league.id}
      GROUP BY team_id;
    SQL
  end
end
