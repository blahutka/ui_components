# The popup wrapping AutocompleteEmpty + AutocompleteList. Hidden until the
# Stimulus controller opens it; flips above the input when there is no room below.
class UI::AutocompleteContent < UI::Base
  BASE = "group/autocomplete-content bg-background border-border-overlay flex flex-col border py-2 shadow-2xl outline-none has-data-empty:py-0 data-empty:py-0 " \
    "absolute inset-x-0 top-full z-50 min-w-36 max-h-80 overflow-hidden " \
    "data-[side=top]:top-auto data-[side=top]:bottom-full data-[side=top]:origin-bottom origin-top " \
    "motion-safe:transition-[opacity,scale] motion-safe:duration-200 motion-safe:ease-[cubic-bezier(0.175,0.885,0.32,1.5)] " \
    "data-starting-style:motion-safe:scale-90 data-starting-style:motion-safe:opacity-0 " \
    "data-ending-style:motion-safe:scale-95 data-ending-style:motion-safe:opacity-0 data-ending-style:motion-safe:duration-100 data-ending-style:motion-safe:ease-out"

  SIZES = { sm: "rounded-md", md: "rounded-lg", lg: "rounded-xl" }.freeze

  prop :side,        default: -> { :bottom }
  prop :side_offset, default: -> { 6 }

  def view_template(&)
    div(**mix({
      hidden: true,
      role: "presentation",
      tabindex: "-1",
      style: "margin-block: #{@side_offset}px",
      data: {
        slot: "#{root.slot}-content",
        side: @side,
        "#{root.identifier}-target": "content",
        action: "mousedown->#{root.identifier}#keepFocus"
      }
    }, @attributes.except(:class)), class: cn(BASE, SIZES[root.size], override: @attributes[:class]), &)
  end

  private
    def root = consume(:ui_autocomplete, component: "Autocomplete")
end
