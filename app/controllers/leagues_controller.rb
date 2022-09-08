class LeaguesController < ApplicationController
  before_action :authenticate_user!, only: %i(index new create)
  before_action :set_league, only: %i(edit update destroy standings)
  before_action :authenticate_resource_access!, only: %i(standings), unless: :league_shareable?
  before_action :authenticate_resource_access!, only: %i(edit update destroy)

  # GET /leagues
  def index
    @leagues = current_user.leagues
  end

  # GET /leagues/new
  def new
    @league = current_user.leagues.new
  end

  # GET /leagues/1/edit
  def edit
  end

  # POST /leagues
  def create
    @league = current_user.leagues.new(league_params)

    if @league.save
      redirect_to @league, notice: "League was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /leagues/1
  def update
    if @league.update(league_params)
      redirect_to @league, notice: "League was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  # DELETE /leagues/1
  def destroy
    @league.destroy
    redirect_to leagues_url, notice: "League was successfully destroyed."
  end

  # GET /leagues/1/standings
  def standings
    @standings = StandingsGenerator.new(@league).run
  end

  private
    def resource
      @league
    end

    # Use callbacks to share common setup or constraints between actions.
    def set_league
      @league = League.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def league_params
      params.require(:league).permit(:user_id, :nickname, :source, :source_id, :swid, :s2, :shareable)
    end
end
