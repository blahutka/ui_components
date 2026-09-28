# One option of a Select. `value:` is what it submits; `label:` is what the trigger shows and
# typeahead matches (the item's text by default). Mark a leading element `data: { icon: "start" }`.
class AppicaUI::SelectItem < AppicaUI::Base
  SIZES = {
    sm: "gap-1 rounded-xs py-1.5 px-2.5 text-xs has-data-[icon=end]:pe-1.5 has-data-[icon=start]:ps-1.5 [&_svg:not([class*='size-'])]:size-4 [&_svg:not([class*='stroke-'])]:stroke-[1.75]",
    md: "gap-1.5 rounded-sm py-2 px-3 text-sm has-data-[icon=end]:pe-2 has-data-[icon=start]:ps-2 [&_svg:not([class*='size-'])]:size-4.5 [&_svg:not([class*='stroke-'])]:stroke-[1.65]",
    lg: "gap-1.5 rounded-md py-2.5 px-3.5 text-base has-data-[icon=end]:pe-2.5 has-data-[icon=start]:ps-2.5 [&_svg:not([class*='size-'])]:size-5 [&_svg:not([class*='stroke-'])]:stroke-[1.65]"
  }.freeze
  TEXT_GAPS = { sm: "gap-1", md: "gap-1.5", lg: "gap-1.5" }.freeze
  CHECK = "opacity-0 [stroke-dashoffset:1.02] group-data-selected/check:opacity-100 group-data-selected/check:[stroke-dashoffset:0] " \
    "motion-safe:transition-[opacity,stroke-dashoffset] motion-safe:ease-out motion-safe:delay-[0ms,150ms] motion-safe:duration-[150ms,0ms] " \
    "motion-safe:group-data-selected/check:delay-[0ms] motion-safe:group-data-selected/check:duration-[0ms,300ms]"

  prop :value
  prop :label,    default: -> { nil }
  prop :disabled, default: -> { false }

  def view_template(&)
    selected = select.selected?(@value)

    div(**mix({
      id: "#{select.id}-option-#{@value.to_s.parameterize.presence || SecureRandom.hex(2)}",
      role: "option", aria_selected: selected.to_s, aria_disabled: ("true" if @disabled),
      data: {
        slot: "select-item", value: @value.to_s, label: @label, selected: ("" if selected), disabled: ("" if @disabled),
        "appica-ui--select-target": "item", action: "click->appica-ui--select#pick pointermove->appica-ui--select#hover"
      }
    }, @attributes.except(:class)), class: cn(AppicaUI::AutocompleteItem::BASE, "justify-between", SIZES[select.size], override: @attributes[:class])) do
      div(data: { slot: "select-item-text" }, class: "flex items-center text-start #{TEXT_GAPS[select.size]}", &)
      span(aria_hidden: "true", data: { slot: "select-item-indicator", selected: ("" if selected) }, class: "group/check text-foreground-intense shrink-0") do
        svg(xmlns: "http://www.w3.org/2000/svg", viewBox: "0 0 24 24", fill: "none", stroke: "currentColor", stroke_linecap: "round", stroke_linejoin: "round",
          aria_hidden: "true", data: { icon: "end" }, class: "stroke-2 me-0.5 size-[1.125em]") do |s|
          s.path(d: "M4.3 12.55 L9.25 17.5 L19.7 6.5", pathLength: "1", stroke_dasharray: "1 2", class: CHECK)
        end
      end
    end
  end

  private
    def select
      consume(:ui_select, component: "Select")
    end
end
