module Espn
  module Api
    class Team < Base

      private

      def query_params(season)
        "#{super(season)}view=mTeam"
      end

      def format_json
        json['teams'].map do |json_team|
          team_owners = json_team['owners'].map do |owner_id|
            owners_map[owner_id].merge({ primary: json_team['primaryOwner'] == owner_id })
          end

          {
            source_id: json_team['id'],
            location: json_team['location'],
            nickname: json_team['nickname'],
            abbr: json_team['abbrev'],
            owners: team_owners,
          }
        end
      end

      def owners_map
        return @owners_map if @owners_map.present?

        @owners_map = json['members'].reduce({}) do |hash, member|
          hash[member['id']] = {
            source_id: member['id'],
            first_name: member['firstName'],
            last_name: member['lastName'],
            display_name: member['displayName'],
          }

          hash
        end
      end
    end
  end
end
