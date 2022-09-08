class AddImportedFieldsToLeagues < ActiveRecord::Migration[7.0]
  def change
    add_column :leagues, :nickname, :string, after: :shareable
    add_column :leagues, :importable, :boolean, after: :nickname
    add_column :leagues, :last_imported_at, :datetime, after: :importable
  end
end
