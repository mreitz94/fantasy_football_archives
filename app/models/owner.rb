class Owner < ApplicationRecord
  belongs_to :team
  has_one :league, through: :team

  def short_name
    "#{first_name} #{last_name[0]}".strip
  end

  def name
    "#{first_name} #{last_name}".strip
  end
end
