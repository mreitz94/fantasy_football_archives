class League < ApplicationRecord
  belongs_to :user
  has_many :teams
  has_many :owners, through: :teams
  has_many :matchups

  enum :source, { espn: 0 }

  serialize :source_settings, Hash
  encrypts :source_settings

  serialized_attr_accessor :source_settings, :swid, :s2

  validates :name, presence: true
  validates :source, presence: true
  validates :start_year, presence: true

  # Conditional ESPN Source Config Validations
  validates :swid, presence: true, if: :espn?
  validates :s2, presence: true, if: :espn?
end
