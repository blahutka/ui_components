# Overlaps a row (or column) of avatars and rings each one with the background
# color. `size:` / `shape:` are defaults for child avatars that don't set their own.
class AppicaUI::AvatarGroup < AppicaUI::Base
  ORIENTATIONS = {
    horizontal: "flex space-x-[-0.2em]",
    vertical: "flex flex-col space-y-[-0.2em]"
  }.freeze

  attr_reader :size, :shape

  prop :size,        default: -> { nil }
  prop :shape,       default: -> { nil }
  prop :orientation, one_of(ORIENTATIONS, :horizontal), default: -> { :horizontal }

  def view_template(&)
    provide(:ui_avatar_group, self) do
      div(**mix({ data: { slot: "avatar-group", orientation: @orientation } }, @attributes.except(:class)),
          class: cn("isolate", ORIENTATIONS[@orientation], "*:data-[slot=avatar]:ring-background *:data-[slot=avatar]:ring-[calc(1em/12)]", override: @attributes[:class]), &)
    end
  end
end
