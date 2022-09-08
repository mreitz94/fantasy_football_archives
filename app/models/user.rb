class User < ApplicationRecord
  has_many :leagues

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable, :validatable

  def own_resource?(resource)
    id == resource.try(:user_id)
  end
end
