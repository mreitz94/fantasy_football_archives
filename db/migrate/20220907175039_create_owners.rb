class CreateOwners < ActiveRecord::Migration[7.0]
  def change
    create_table :owners do |t|
      t.references :team, null: false, foreign_key: true
      t.string :source_id
      t.string :display_name
      t.string :first_name
      t.string :last_name

      t.timestamps
    end
  end
end
