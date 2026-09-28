# One option. `value:` is what selection writes into the input; for object items
# it is read through the root's item_to_string_value.
class AppicaUI::AutocompleteItem < AppicaUI::Base
  BASE = "text-foreground relative isolate flex w-full cursor-default items-center outline-hidden select-none [&_svg]:pointer-events-none [&_svg]:shrink-0 " \
    "before:bg-background-muted before:absolute before:inset-0 before:-z-10 before:rounded-[inherit] before:opacity-0 " \
    "active:translate-y-px active:scale-[0.98] data-highlighted:not-data-disabled:text-foreground-intense data-highlighted:not-data-disabled:before:opacity-100 " \
    "motion-safe:transition motion-safe:duration-250 motion-safe:ease-[cubic-bezier(0.175,0.885,0.32,1.5)] motion-safe:active:duration-100 motion-safe:active:ease-in-out " \
    "motion-safe:before:transition-opacity motion-safe:before:duration-200 motion-safe:before:ease-out data-disabled:opacity-disabled data-disabled:pointer-events-none"

  SIZES = {
    sm: "gap-1.5 rounded-xs py-1.5 px-2.5 text-xs has-data-[icon=end]:pe-1.5 has-data-[icon=start]:ps-1.5 [&_svg:not([class*='size-'])]:size-4 [&_svg:not([class*='stroke-'])]:stroke-[1.75]",
    md: "gap-1.5 rounded-sm py-2 px-3 text-sm has-data-[icon=end]:pe-2 has-data-[icon=start]:ps-2 [&_svg:not([class*='size-'])]:size-4.5 [&_svg:not([class*='stroke-'])]:stroke-[1.65]",
    lg: "gap-1.5 rounded-md py-2.5 px-3.5 text-base has-data-[icon=end]:pe-2.5 has-data-[icon=start]:ps-2.5 [&_svg:not([class*='size-'])]:size-5 [&_svg:not([class*='stroke-'])]:stroke-[1.65]"
  }.freeze

  prop :value
  prop :disabled, default: -> { false }

  def view_template(&)
    div(**mix(item_attributes, @attributes.except(:class)), class: cn(BASE, SIZES[root.size], override: @attributes[:class])) do
      span(class: "flex items-center text-start gap-1.5", &)
    end
  end

  private
    def root = consume(:ui_autocomplete, component: "Autocomplete")

    def item_attributes
      {
        role: "option",
        aria: { selected: "false", disabled: (@disabled ? "true" : nil) },
        data: {
          slot: "#{root.slot}-item",
          value: @value.is_a?(String) ? @value : root.string_value_for(@value),
          disabled: (@disabled ? "" : nil),
          "#{root.identifier}-target": "item",
          action: "click->#{root.identifier}#select mousemove->#{root.identifier}#hover"
        }
      }
    end
end
