class Address
  include ActiveModel::Model
  include ActiveModel::Attributes

  COUNTRIES = [ [ "Czechia", "cz" ], [ "Germany", "de" ], [ "United States", "us" ] ].freeze

  attribute :city, :string
  attribute :country, :string

  validates :city, presence: true
  validates :country, inclusion: { in: COUNTRIES.map(&:last) }
end
