class AddPrimaryToOwners < ActiveRecord::Migration[7.0]
  def change
    add_column :owners, :primary, :boolean, after: :last_name
  end
end
