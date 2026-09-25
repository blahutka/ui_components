# The tooltip bubble: `side:` (:top by default), `align:`, offsets and an `arrow:`.
class UI::TooltipContent < UI::Base
  BUBBLE = "bg-background-inverse text-foreground-inverse rounded-xs px-3 py-1.5 text-xs shadow-md " \
    "motion-safe:origin-(--transform-origin) motion-safe:transition-[opacity,scale] motion-safe:duration-200 motion-safe:ease-[cubic-bezier(0.175,0.885,0.32,1.5)] " \
    "data-starting-style:motion-safe:scale-90 data-starting-style:motion-safe:opacity-0 " \
    "data-ending-style:motion-safe:scale-95 data-ending-style:motion-safe:opacity-0 data-ending-style:motion-safe:duration-100 data-ending-style:motion-safe:ease-out " \
    "data-instant:motion-safe:transition-none"
  POPUP = "fixed inset-auto m-0 hidden open:block overflow-visible border-0 pointer-events-none"
  ARROW = "bg-background-inverse absolute size-2.5 rotate-45 rounded-[2px] data-[side=top]:-bottom-1 data-[side=bottom]:-top-1 " \
    "data-[side=left]:-right-1 data-[side=right]:-left-1"

  prop :side,         one_of(%i[ top bottom left right inline_end inline_start ], :top), default: -> { :top }
  prop :align,        one_of(%i[ start center end ], :center), default: -> { :center }
  prop :side_offset,  default: -> { nil }
  prop :align_offset, default: -> { 0 }
  prop :arrow,        default: -> { true }

  def view_template(&)
    tooltip = consume(:ui_popover, component: "Tooltip")
    span(**mix({
      id: tooltip.popup_id, popover: "manual", role: "tooltip",
      data: {
        slot: "tooltip-content", side: @side, align: @align, side_offset: @side_offset || (@arrow ? 8 : 4), align_offset: @align_offset,
        "ui--popover-target": "popup"
      }
    }, @attributes.except(:class)), class: cn(POPUP, BUBBLE, override: @attributes[:class])) do
      yield
      span(aria_hidden: "true", data: { slot: "tooltip-arrow", "ui--popover-target": "arrow" }, class: ARROW) if @arrow
    end
  end
end
