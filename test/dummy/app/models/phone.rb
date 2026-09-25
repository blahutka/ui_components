class Phone < ApplicationRecord
  KINDS = %w[ mobile home work ].freeze

  belongs_to :user

  validates :number, format: { with: /\A\+?[\d ]{6,}\z/, message: "should look like +420 123 456 789" }
  validates :kind, inclusion: { in: KINDS }
end
