class TeamsController < ApplicationController
  before_action :set_league, only: %i(index)
  before_action :authenticate_resource_access!, only: %i(index), unless: :league_shareable?

  # GET /leagues/:id/teams
  def index
    @teams = @league.teams
  end

  private
    def resource
      @league
    end

    # Use callbacks to share common setup or constraints between actions.
    def set_league
      @league = League.find(params[:league_id])
    end
end
