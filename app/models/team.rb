class Team < ApplicationRecord
  belongs_to :league
  has_many :owners
  has_one :primary_owner, -> { where(primary: true) }, class_name: 'Owner'

  def matchups
    @matchups ||= Matchup.by_team(self).decided
  end

  def name
    "#{location} #{nickname}"
  end

  def playoff_seasons
    matchups.playoffs.group(:season).count.keys.sort
  end

  def championship_games
    Matchup.championship_games(league).by_team(self)
  end

  def championship_seasons
    championship_games.to_a.filter { |game| game.team_won?(self) }.map(&:season).sort
  end

  def longest_win_streak(include_postseason: true)
    longest, current = 0, 0
    matchups_for_stats(include_postseason: include_postseason).each do |matchup|
      current = matchup.team_won?(self) ? current + 1 : 0
      longest = current if current > longest
    end
    "#{longest}W"
  end

  def longest_losing_streak(include_postseason: true)
    longest, current = 0, 0
    matchups_for_stats(include_postseason: include_postseason).each do |matchup|
      current = matchup.team_lost?(self) ? current + 1 : 0
      longest = current if current > longest
    end
    "#{longest}L"
  end

  def current_streak(include_postseason: true)
    case
    when current_winning_streak(include_postseason: include_postseason) > 0 then "#{current_winning_streak}W"
    when current_losing_streak(include_postseason: include_postseason) > 0 then "#{current_losing_streak}L"
    else '-'
    end
  end

  private

  def current_winning_streak(include_postseason: true)
    current = 0
    matchups_for_stats(include_postseason: include_postseason).reverse.each do |matchup|
      if matchup.team_won?(self)
        current += 1
      else
        return current
      end
    end
    current
  end

  def current_losing_streak(include_postseason: true)
    current = 0
    matchups_for_stats(include_postseason: include_postseason).reverse.each do |matchup|
      if matchup.team_lost?(self)
        current += 1
      else
        return current
      end
    end
    current
  end

  def matchups_for_stats(include_postseason: true)
    if include_postseason
      matchups
    else
      @regular_season_matchups ||= matchups.regular_season
    end
  end
end
