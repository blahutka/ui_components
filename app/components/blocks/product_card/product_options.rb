# The ProductCard's option row: a size picker (a ToggleGroup of outline toggles) and a quantity
# NumberField. In a card with `action:` they submit `size` and `quantity`.
#
#   ProductOptions(sizes: %w[ 40 41 42 43 ], selected: "42", max: 9)
class Blocks::ProductOptions < Blocks::Base
  prop :sizes,      default: -> { [] }
  prop :selected,   default: -> { nil }
  prop :size_label, default: -> { t("ui_components.blocks.product_card.size") }
  prop :quantity,   default: -> { 1 }
  prop :max,        default: -> { 9 }
  # Sizes past this many are hidden on small screens
  prop :compact,    default: -> { 3 }

  def view_template
    div(**mix({ data: { slot: "product-options" } }, @attributes.except(:class)), class: cn("mt-3 flex items-center justify-between gap-3", override: @attributes[:class])) do
      if @sizes.any?
        ToggleGroup(default_value: Array(@selected), name: "size", aria_label: @size_label) do
          @sizes.each_with_index do |size, index|
            Toggle(value: size.to_s) do |toggle|
              Button(**toggle, variant: :outline, size: :sm, icon: true, class: [ "text-xs", ("hidden sm:inline-flex" if index >= @compact) ].compact.join(" ")) { size.to_s }
            end
          end
        end
      end
      NumberField(default_value: @quantity, min: 1, max: @max, step: 1, name: "quantity", size: :sm,
        aria_label: t("ui_components.blocks.product_card.quantity"), class: "h-auto w-24 shrink-0 p-px")
    end
  end
end
