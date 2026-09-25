class Address < ApplicationRecord
  COUNTRIES = [ [ "Czechia", "cz" ], [ "Germany", "de" ], [ "United States", "us" ] ].freeze

  belongs_to :user

  validates :city, presence: true
  validates :country, inclusion: { in: COUNTRIES.map(&:last) }
end
