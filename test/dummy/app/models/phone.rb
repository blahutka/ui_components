class Phone
  include ActiveModel::Model
  include ActiveModel::Attributes

  KINDS = %w[ mobile home work ].freeze

  attribute :number, :string
  attribute :kind, :string

  validates :number, format: { with: /\A\+?[\d ]{6,}\z/, message: "should look like +420 123 456 789" }
  validates :kind, inclusion: { in: KINDS }
end
