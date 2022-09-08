class CreateMatchups < ActiveRecord::Migration[7.0]
  def change
    create_table :matchups do |t|
      t.references :league, null: false, foreign_key: true
      t.integer :season
      t.integer :period
      t.bigint :away_team_id
      t.bigint :home_team_id
      t.float :away_team_score
      t.float :home_team_score
      t.string :status
      t.bigint :winner_id
      t.bigint :loser_id
      t.string :playoff_tier

      t.timestamps
    end
  end
end
