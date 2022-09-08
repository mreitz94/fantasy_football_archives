class AddSourceIdToLeagues < ActiveRecord::Migration[7.0]
  def change
    add_column :leagues, :source_id, :string, after: :source
  end
end
