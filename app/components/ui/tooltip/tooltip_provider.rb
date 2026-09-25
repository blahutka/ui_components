# Wraps a group of tooltips: they share the hover `delay:` (200 ms) and, once one has shown, a
# neighbour opens instantly within `timeout:` (400 ms) of it closing. Put one high in your layout.
class UI::TooltipProvider < UI::Base
  prop :delay,       default: -> { 200 }
  prop :close_delay, default: -> { 0 }
  prop :timeout,     default: -> { 400 }

  def view_template(&)
    div(**mix({ data: { slot: "tooltip-provider", delay: @delay, close_delay: @close_delay, timeout: @timeout } }, @attributes.except(:class)),
      class: cn("contents", override: @attributes[:class]), &)
  end
end
