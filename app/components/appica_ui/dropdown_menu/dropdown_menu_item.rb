# One action. Selecting it (click, Enter, Space) emits `select` and closes the menu;
# `close_on_click: false` keeps it open. Tag a leading icon `data: { icon: "start" }` and push a
# trailing Kbd or badge to the edge with `class: "ms-auto"`. `label:` is what typeahead matches.
class AppicaUI::DropdownMenuItem < AppicaUI::Base
  prop :disabled,       default: -> { false }
  prop :close_on_click, default: -> { true }
  prop :label,          default: -> { nil }

  def view_template(&)
    div(**mix(item_attributes("item"), @attributes.except(:class)), class: cn(menu.item_classes, override: @attributes[:class]), &)
  end

  private
    def menu
      consume(:ui_dropdown_menu, component: "DropdownMenu")
    end

    def item_attributes(kind, role: "menuitem")
      {
        role:, tabindex: "-1", aria_disabled: ("true" if @disabled),
        data: { slot: "#{menu.slot}-#{kind}", orientation: "vertical", disabled: ("" if @disabled), label: @label, close: @close_on_click.to_s }
      }
    end

    # The animated check of checkbox and radio items
    def indicator(kind, checked)
      span(aria_hidden: "true", class: "group/check text-foreground-intense shrink-0",
        data: { slot: "#{menu.slot}-#{kind}-indicator", checked: ("" if checked), unchecked: ("" unless checked) }) do
        svg(xmlns: "http://www.w3.org/2000/svg", viewBox: "0 0 24 24", fill: "none", stroke: "currentColor", stroke_linecap: "round", stroke_linejoin: "round",
          aria_hidden: "true", data: { icon: "end" }, class: "stroke-2 me-0.5 size-[1.125em]") do |s|
          s.path(d: "M4.3 12.55 L9.25 17.5 L19.7 6.5", pathLength: "1", stroke_dasharray: "1 2", class: AppicaUI::MenubarCheckIndicator::PATH)
        end
      end
    end
end
