module Espn
  module Api
    class League < Base

      private

      def query_params(season)
        "#{super(season)}view=mSettings"
      end

      def format_json
        {
          id: json['id'],
          name: json['settings']['name'],
          previous_seasons: json['status']['previousSeasons'] || [],
        }
      end
    end
  end
end
