# One option of a Combobox, with a check while selected. `value:` is what it submits.
class UI::ComboboxItem < UI::AutocompleteItem
  def view_template(&)
    selected = root.selected?(@value.is_a?(String) ? @value : root.string_value_for(@value))

    div(**mix(item_attributes.deep_merge(aria: { selected: selected.to_s }, data: { selected: ("" if selected) }), @attributes.except(:class)),
      class: cn(BASE, "justify-between", SIZES[root.size], override: @attributes[:class])) do
      span(class: "flex items-center text-start gap-1.5", &)
      span(aria_hidden: "true", data: { slot: "combobox-item-indicator" }, class: "group/check text-foreground-intense shrink-0 in-data-selected:[&_path]:opacity-100 in-data-selected:[&_path]:[stroke-dashoffset:0]") do
        svg(xmlns: "http://www.w3.org/2000/svg", viewBox: "0 0 24 24", fill: "none", stroke: "currentColor", stroke_linecap: "round", stroke_linejoin: "round",
          aria_hidden: "true", data: { icon: "end" }, class: "stroke-2 me-0.5 size-[1.125em]") do |s|
          s.path(d: "M4.3 12.55 L9.25 17.5 L19.7 6.5", pathLength: "1", stroke_dasharray: "1 2",
            class: "opacity-0 [stroke-dashoffset:1.02] motion-safe:transition-[opacity,stroke-dashoffset] motion-safe:duration-300 motion-safe:ease-out")
        end
      end
    end
  end
end
