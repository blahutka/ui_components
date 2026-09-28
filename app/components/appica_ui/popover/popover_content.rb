# The popover's card, floating beside the trigger: `side:` (:bottom, :top, :left, :right,
# :inline_end, :inline_start), `align:` (:start, :center, :end), offsets, and an `arrow:` with a
# thicker border on its edge (on by default).
class AppicaUI::PopoverContent < AppicaUI::Base
  # Reset what the page around it would pass down (it isn't portalled): color, alignment, size
  POPUP = "group/popup fixed inset-auto m-0 hidden open:block overflow-visible border-0 bg-transparent p-0 text-foreground text-start text-base font-normal whitespace-normal outline-none"
  CARD = "bg-background border-border-overlay flex max-w-80 min-w-50 flex-col gap-2 rounded-xl border p-4 shadow-2xl"
  ARROW_BORDERS = "group-data-[side=top]/popup:border-b-2 group-data-[side=bottom]/popup:border-t-2 group-data-[side=left]/popup:border-r-2 group-data-[side=right]/popup:border-l-2"
  MOTION = "motion-safe:origin-(--transform-origin) motion-safe:transition-[opacity,scale] motion-safe:duration-200 motion-safe:ease-[cubic-bezier(0.175,0.885,0.32,1.5)] " \
    "group-data-starting-style/popup:motion-safe:scale-90 group-data-starting-style/popup:motion-safe:opacity-0 " \
    "group-data-ending-style/popup:motion-safe:scale-95 group-data-ending-style/popup:motion-safe:opacity-0 group-data-ending-style/popup:motion-safe:duration-100 group-data-ending-style/popup:motion-safe:ease-out"
  ARROW = "absolute flex data-[side=top]:-bottom-2.25 data-[side=top]:rotate-180 data-[side=bottom]:-top-2.25 " \
    "data-[side=left]:-right-3.25 data-[side=left]:rotate-90 data-[side=right]:-left-3.25 data-[side=right]:-rotate-90"

  prop :side,         one_of(%i[ bottom top left right inline_end inline_start ], :bottom), default: -> { :bottom }
  prop :align,        one_of(%i[ start center end ], :center), default: -> { :center }
  prop :side_offset,  default: -> { nil }
  prop :align_offset, default: -> { 0 }
  prop :arrow,        default: -> { true }

  def view_template(&)
    wrap { popup(&) }
  end

  private
    # PreviewCard wraps it in a <template>, so it can sit inside a paragraph
    def wrap
      yield
    end

    def popup(&)
      root = root_component
      div(id: root.popup_id, popover: "manual", tabindex: "-1", role: popup_role,
        aria_labelledby: (root.title_id if labelled?), aria_describedby: (root.description_id if labelled?),
        data: {
          slot: "#{root.slot}-popup", side: @side, align: @align, side_offset: @side_offset || (@arrow ? 10 : 6), align_offset: @align_offset,
          "appica-ui--popover-target": "popup", action: "pointerenter->appica-ui--popover#pointerEnter pointerleave->appica-ui--popover#pointerLeave focusout->appica-ui--popover#focusOut"
        },
        class: POPUP) do
        div(**mix({ data: { slot: "#{root.slot}-content" } }, @attributes.except(:class)),
          class: cn(CARD, (ARROW_BORDERS if @arrow), MOTION, override: @attributes[:class]), &)
        arrow(root) if @arrow
      end
    end

    def root_component = consume(:ui_popover, component: "Popover")
    def popup_role = "dialog"
    def labelled? = true

    def arrow(root)
      span(aria_hidden: "true", data: { slot: "#{root.slot}-arrow", "appica-ui--popover-target": "arrow" },
        class: "#{ARROW} group-data-starting-style/popup:opacity-0 group-data-ending-style/popup:opacity-0 motion-safe:transition-opacity") do
        svg(width: "26", height: "18", viewBox: "0 0 26 18", fill: "none", aria_hidden: "true") do |s|
          s.path(class: "text-border-overlay", d: "M21 9L15.9819 3.36153C14.3897 1.57244 11.5927 1.57413 10.0026 3.36516L5 9", stroke: "currentColor", stroke_width: "2")
          s.path(class: "text-background", d: "M9.82943 4.57564C11.4308 2.51078 14.5497 2.51076 16.1511 4.5756L20.9774 10.7986C23.0157 13.4269 21.1426 17.25 17.8166 17.25L8.16409 17.25C4.83808 17.25 2.96496 13.4269 5.00325 10.7987L9.82943 4.57564Z", fill: "currentColor")
        end
      end
    end
end
