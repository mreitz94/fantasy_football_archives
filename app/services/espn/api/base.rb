module Espn
  module Api
    class Base
      attr_reader :league
      attr_reader :json

      BASE_URL = "https://fantasy.espn.com/apis/v3/games/ffl".freeze

      def initialize(league)
        @league = league
      end

      def get(season)
        response = RestClient.get(url(season), cookies: cookies)
        @json = JSON.parse(response)
        @json = json.first if json.is_a?(Array)
        format_json
      end

      private

      def url(season)
        path = if historical?(season)
          "leagueHistory/#{league.source_id}"
        else
          "seasons/#{season}/segments/0/leagues/#{league.source_id}"
        end

        "#{BASE_URL}/#{path}?#{query_params(season)}"
      end

      def query_params(season)
        season.to_i >= 2018 ? "" : "seasonId=#{season}&"
      end

      def historical?(season)
        season.to_i < 2018
      end

      def cookies
        {
          swid: league.swid,
          espn_s2: league.s2
        }
      end

      def format_json
        @json
      end
    end
  end
end
