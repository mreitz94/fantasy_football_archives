module Espn
  class Importer
    attr_reader :league, :seasons

    def initialize(league)
      @league = league
    end

    def run(from_season: nil)
      set_seasons(start: from_season.to_i)
      sync_league!
      sync_teams!
      sync_matchups!
    end

    private

    def set_seasons(start: nil)
      return [] if espn_league[:previous_seasons].empty?
      seasons_list = espn_league[:previous_seasons].map(&:to_i)
      seasons_list << seasons_list.last + 1
      seasons_list.filter { |season| season >= start }
      @seasons = start.present? ? seasons_list.filter { |season| season >= start } : seasons_list
    end

    def sync_league!
      if espn_league.present?
        update_league(espn_league)
      else
        league.update!(importable: false)
      end
    end

    def sync_teams!
      return unless seasons.any?

      seasons.each_with_index do |season, i|
        espn_teams = fetch_espn_teams(season)
        team_ids = espn_teams.map do |espn_team|
          team = upsert_team(espn_team)
          upsert_team_owners(team, espn_team)
          team.id
        end

        if seasons.length - 1 == i
          league.teams.where(id: team_ids).update_all(active: true)
          league.teams.where.not(id: team_ids).update_all(active: true)
        end
      end
    end

    def sync_matchups!
      return unless seasons.any?
      teams_map = league.teams.index_by(&:source_id)

      seasons.each do |season|
        espn_matchups = fetch_espn_matchups(season)
        espn_matchups.each do |espn_matchup|
          upsert_matchup(espn_matchup, teams_map, season)
        end
      end
    end

    def espn_league
      return @espn_league if @espn_league.present?
      @espn_league = fetch_espn_league(Time.current.year)
      @espn_league ||= fetch_espn_league(Time.current.year - 1)
    end

    def fetch_espn_league(season)
      make_api_call { Espn::Api::League.new(league).get(season) }
    end

    def fetch_espn_teams(season)
      make_api_call { Espn::Api::Team.new(league).get(season) }
    end

    def fetch_espn_matchups(season)
      make_api_call { Espn::Api::Matchup.new(league).get(season) }
    end

    def make_api_call(&block)
      begin
        block.call
      rescue RestClient::NotFound, RestClient::Unauthorized => e
        nil
      end
    end

    def update_league(espn_league)
      league.update!({
        name: espn_league[:name],
        start_year: espn_league[:previous_seasons].first,
        importable: true,
        last_imported_at: Time.current,
      })
    end

    def upsert_team(espn_team)
      team = league.teams.find_or_initialize_by(source_id: espn_team[:source_id])
      team.update!({
        source_id: espn_team[:source_id],
        location: espn_team[:location],
        nickname: espn_team[:nickname],
        abbr: espn_team[:abbr],
      })
      team
    end

    def upsert_team_owners(team, espn_team)
      espn_team[:owners].each do |espn_owner|
        owner = team.owners.find_or_initialize_by(source_id: espn_owner[:source_id])
        owner.update!({
          source_id: espn_owner[:source_id],
          first_name: espn_owner[:first_name],
          last_name: espn_owner[:last_name],
          display_name: espn_owner[:display_name],
          primary: espn_owner[:primary],
        })
      end
    end

    def upsert_matchup(espn_matchup, teams_map, season)
      away_team = teams_map[espn_matchup[:away_team_source_id].to_s]
      home_team = teams_map[espn_matchup[:home_team_source_id].to_s]

      matchup = league.matchups.find_or_initialize_by({
        season: season,
        period: espn_matchup[:period],
        home_team_id: home_team.id,
      })

      matchup.update!({
        away_team_id: away_team.id,
        home_team_score: espn_matchup[:home_team_score],
        away_team_score: espn_matchup[:away_team_score],
        status: espn_matchup[:status],
        playoff_tier: espn_matchup[:playoff_tier],
      })
    end
  end
end
