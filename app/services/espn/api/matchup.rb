module Espn
  module Api
    class Matchup < Base

      private

      def query_params(season)
        "#{super(season)}view=mMatchup&view=mBoxscore&view=mMatchupScore"
      end

      def format_json
        json['schedule'].map do |matchup|
          next nil if matchup['away'].nil? || matchup['home'].nil?
          {
            period: matchup['matchupPeriodId'],
            away_team_source_id: matchup['away']['teamId'],
            home_team_source_id: matchup['home']['teamId'],
            away_team_score: matchup['away']['totalPoints'],
            home_team_score: matchup['home']['totalPoints'],
            status: matchup['winner'],
            playoff_tier: matchup['playoffTierType'],
          }
        end.compact
      end
    end
  end
end
