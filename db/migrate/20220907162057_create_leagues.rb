class CreateLeagues < ActiveRecord::Migration[7.0]
  def change
    create_table :leagues do |t|
      t.references :user, null: false, foreign_key: true
      t.string :name
      t.integer :source
      t.text :source_settings
      t.integer :start_year
      t.boolean :shareable

      t.timestamps
    end
  end
end
