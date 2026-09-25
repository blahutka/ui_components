# Root of the compound component: holds the edge (`side:`) and the drawer options
# and shares them with its parts. Renders a `display: contents` wrapper for the
# Stimulus controller, so it doesn't affect layout.
#
#   Drawer(side: :right) do
#     DrawerTrigger { |trigger| Button(**trigger, variant: :outline) { "Open drawer" } }
#     DrawerContent do
#       DrawerHeader do
#         DrawerTitle { "Notifications" }
#         DrawerDescription { "Choose what you want to be notified about." }
#       end
#       DrawerBody { ... }
#       DrawerFooter do
#         DrawerClose { |close| Button(**close) { "Save" } }
#         DrawerClose { |close| Button(**close, variant: :outline) { "Cancel" } }
#       end
#     end
#   end
class UI::Drawer < UI::Base
  SIDES = %i[ top right bottom left ].freeze

  prop :side,                      one_of(SIDES, :bottom), default: -> { :bottom }
  prop :default_open,              default: -> { false }
  prop :modal,                     default: -> { true }
  prop :disable_pointer_dismissal, default: -> { false }
  prop :snap_points,               default: -> { nil }
  prop :id,                        default: -> { "drawer-#{SecureRandom.hex(4)}" }

  attr_reader :id, :side

  def view_template(&)
    @parent = context[:ui_drawer]

    provide(:ui_drawer, self) do
      div(**mix(root_attributes, @attributes.except(:class)), class: cn("contents", override: @attributes[:class]), &)
    end
  end

  def nested? = @parent.present?
  def modal? = @modal
  def vertical? = side.in?(%i[ top bottom ])

  def dialog_id = "#{id}-dialog"
  def title_id = "#{id}-title"
  def description_id = "#{id}-description"

  private
    def root_attributes
      {
        id: id,
        data: {
          slot: "drawer",
          controller: "ui--drawer",
          "ui--drawer-side-value": side,
          "ui--drawer-modal-value": modal?.to_s,
          "ui--drawer-open-value": @default_open.to_s,
          "ui--drawer-dismissible-value": (!@disable_pointer_dismissal).to_s,
          "ui--drawer-snap-points-value": (@snap_points.to_json if @snap_points && vertical?)
        }
      }
    end
end
