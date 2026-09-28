# The form builder demo's model (app/views/users): an Active Record with nested children and
# one attribute per `form.ux` helper.
class User < ApplicationRecord
  LOCATIONS = [ [ "Prague", "prg" ], [ "Berlin", "ber" ], [ "Vienna", "vie" ], [ "New York", "nyc" ] ].freeze
  PLANS = [ [ "Free", "free" ], [ "Pro", "pro" ], [ "Team", "team" ] ].freeze
  INTERESTS = [ [ "Design", "design" ], [ "Engineering", "engineering" ], [ "Marketing", "marketing" ], [ "Sales", "sales" ] ].freeze
  LANGUAGES = [ [ "Czech", "cs" ], [ "English", "en" ], [ "German", "de" ], [ "Arabic", "ar" ], [ "Spanish", "es" ], [ "Japanese", "ja" ] ].freeze
  SKILLS = %w[ Ruby Rails JavaScript Stimulus Turbo Tailwind SQL ].freeze
  TAGS = [ [ "Remote", "remote" ], [ "Full-time", "full_time" ], [ "Part-time", "part_time" ], [ "Contract", "contract" ], [ "Mentor", "mentor" ] ].freeze
  CITIES = [ "Prague", "Brno", "Berlin", "Munich", "Vienna", "New York", "San Francisco", "Tokyo" ].freeze
  ALIGNMENTS = [ [ "Left", "left" ], [ "Center", "center" ], [ "Right", "right" ] ].freeze
  FORMATS = [ [ "Bold", "bold" ], [ "Italic", "italic" ], [ "Underline", "underline" ] ].freeze

  # Everything the demo forms submit - for `params.require(:user).permit(*User::PERMITTED)`
  PERMITTED = [
    :name, :email, :website, :age, :bio, :plan, :language, :experience, :pin, :newsletter, :terms_of_service,
    :city, :score, :featured, :alignment,
    { locations: [], interests: [], skills: [], tags: [], formats: [],
      address_attributes: %i[ city country ], phones_attributes: %i[ number kind ] }
  ].freeze

  has_one :address, dependent: :destroy
  has_many :phones, dependent: :destroy
  accepts_nested_attributes_for :address, :phones

  validates :name, presence: true, length: { maximum: 40 }
  validates :email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :website, format: { with: %r{\Ahttps?://}, message: "must start with http:// or https://", allow_blank: true }
  validates :age, numericality: { only_integer: true, in: 18..120 }
  validates :bio, length: { maximum: 280 }
  validates :locations, :interests, presence: true
  validates :plan, presence: true, inclusion: { in: PLANS.map(&:last), allow_blank: true }
  validates :language, inclusion: { in: LANGUAGES.map(&:last) }
  validates :experience, numericality: { only_integer: true, in: 0..30 }
  validates :pin, format: { with: /\A\d{4}\z/, message: "must be 4 digits" }
  validates :terms_of_service, acceptance: true
  validates :tags, presence: true
  validates :city, presence: true
  validates :score, numericality: { only_integer: true, in: 1..5, message: "pick at least one star" }
  validates :alignment, inclusion: { in: ALIGNMENTS.map(&:last) }

  # The form's starting point: an empty address and a mobile and a work phone row
  def self.new_with_blank_children
    new(address: Address.new, phones: [ Phone.new(kind: "mobile"), Phone.new(kind: "work") ])
  end

  # Multiple selects, check box and chip groups, multiple comboboxes and toggle groups submit an
  # empty entry first
  # (so clearing them still sends the key)
  %i[ locations interests skills tags formats ].each do |attribute|
    define_method("#{attribute}=") { |values| super(Array(values).compact_blank) }
  end
end
