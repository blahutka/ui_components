# The Select's popup: a listbox of SelectItems (and SelectGroups / SelectSeparators). Opened by
# the controller in the top layer, over the trigger or `side: :top` / `:bottom` of it.
class AppicaUI::SelectContent < AppicaUI::Base
  BASE = "bg-background border-border-overlay text-foreground fixed inset-auto m-0 hidden open:flex flex-col overflow-visible border p-0 shadow-2xl outline-none min-w-36 " \
    "motion-safe:transition-[opacity,scale] motion-safe:duration-200 motion-safe:ease-[cubic-bezier(0.175,0.885,0.32,1.5)] " \
    "data-starting-style:motion-safe:scale-90 data-starting-style:motion-safe:opacity-0 " \
    "data-ending-style:motion-safe:scale-95 data-ending-style:motion-safe:opacity-0 data-ending-style:motion-safe:duration-100 data-ending-style:motion-safe:ease-out"
  SIZES = { sm: "rounded-md", md: "rounded-lg", lg: "rounded-xl" }.freeze

  prop :side,        one_of(%i[ bottom top ], :bottom), default: -> { :bottom }
  prop :side_offset, default: -> { 6 }

  def view_template(&)
    div(**mix({
      popover: "manual", tabindex: "-1", role: "presentation",
      data: { slot: "select-content", side: @side, "side-offset": @side_offset, "appica-ui--select-target": "content", action: "mousedown->appica-ui--select#keepFocus" }
    }, @attributes.except(:class)), class: cn(BASE, SIZES[select.size], override: @attributes[:class])) do
      div(id: select.list_id, role: "listbox", aria_multiselectable: ("true" if select.multiple?), tabindex: "-1",
        data: { slot: "select-list", "appica-ui--select-target": "list" },
        class: "flex max-h-(--available-height) flex-col gap-0.5 overflow-y-auto p-2", &)
    end
  end

  private
    def select
      consume(:ui_select, component: "Select")
    end
end
