# A wrapping row of Chips sharing a variant and size.
#
#   ChipGroup(variant: :outline) do
#     tags.each { |tag| Chip(dismissible: true) { tag } }
#   end
#
# Dispatch `appica-ui--chip-group:clear` on it (or call the controller's clearAll) to dismiss every
# dismissible chip at once; each animates out and emits its own `appica-ui--chip:dismiss`.
class AppicaUI::ChipGroup < AppicaUI::Base
  prop :variant, one_of(AppicaUI::Chip::VARIANTS, :soft), default: -> { nil }
  prop :size,    one_of(AppicaUI::Chip::SIZES, :md), default: -> { nil }

  attr_reader :variant, :size

  def view_template(&)
    provide(:ui_chip_group, self) do
      div(**mix(defaults(data: { slot: "chip-group", controller: "appica-ui--chip-group", action: "appica-ui--chip-group:clear->appica-ui--chip-group#clearAll" }),
        @attributes.except(:class)), class: cn("flex flex-wrap items-center gap-2", override: @attributes[:class]), &)
    end
  end
end
