# The form builder demo's model (app/views/users): plain ActiveModel with nested children.
class User
  include ActiveModel::Model
  include ActiveModel::Attributes
  include NestedAttributes

  LOCATIONS = [ [ "Prague", "prg" ], [ "Berlin", "ber" ], [ "Vienna", "vie" ], [ "New York", "nyc" ] ].freeze

  attribute :name, :string
  attribute :age, :integer
  attribute :locations, default: -> { [] }

  nested_one :address, Address
  nested_many :phones, Phone

  validates :name, presence: true, length: { maximum: 40 }
  validates :age, numericality: { only_integer: true, in: 18..120 }
  validates :locations, presence: true

  # ActiveModel::Attributes casts integers but does not expose this Rails form API.
  # Numericality also uses it, so "18.5" is not silently validated as integer 18.
  def age_before_type_cast
    @attributes["age"].value_before_type_cast
  end

  # A multiple select submits an empty entry first (so clearing it still sends the key)
  def locations=(values)
    super(Array(values).compact_blank)
  end
end
