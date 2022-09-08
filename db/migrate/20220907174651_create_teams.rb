class CreateTeams < ActiveRecord::Migration[7.0]
  def change
    create_table :teams do |t|
      t.references :league, null: false, foreign_key: true
      t.string :source_id
      t.string :location
      t.string :nickname
      t.string :abbr
      t.boolean :active

      t.timestamps
    end
  end
end
