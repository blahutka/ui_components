# A wrapping row of Chips sharing a variant and size.
#
#   ChipGroup(variant: :outline) do
#     tags.each { |tag| Chip(dismissible: true) { tag } }
#   end
#
# Dispatch `ui--chip-group:clear` on it (or call the controller's clearAll) to dismiss every
# dismissible chip at once; each animates out and emits its own `ui--chip:dismiss`.
class UI::ChipGroup < UI::Base
  prop :variant, one_of(UI::Chip::VARIANTS, :soft), default: -> { nil }
  prop :size,    one_of(UI::Chip::SIZES, :md), default: -> { nil }

  attr_reader :variant, :size

  def view_template(&)
    provide(:ui_chip_group, self) do
      div(**mix(defaults(data: { slot: "chip-group", controller: "ui--chip-group", action: "ui--chip-group:clear->ui--chip-group#clearAll" }),
        @attributes.except(:class)), class: cn("flex flex-wrap items-center gap-2", override: @attributes[:class]), &)
    end
  end
end
