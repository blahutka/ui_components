# A rail of thumbnails that drives the carousel it sits in. The rail is a small carousel
# of its own, so it scrolls when the thumbnails outgrow it; selection is one outline that
# slides to the current thumbnail. `orientation: :vertical` stands the rail beside the
# viewer (give its row a height).
class UI::CarouselThumbs < UI::Base
  TRACK = {
    horizontal: "flex touch-pan-y touch-pinch-zoom items-start gap-2",
    vertical: "flex touch-pan-x touch-pinch-zoom flex-col gap-2"
  }.freeze

  attr_reader :orientation

  prop :orientation, one_of(%i[ horizontal vertical ], :horizontal), default: -> { :horizontal }
  prop :light,       default: -> { nil }

  def view_template(&)
    provide(:ui_carousel_thumbs, self) do
      div(**mix({
        role: "group",
        aria: { label: "Choose slide to display" },
        data: { slot: "carousel-thumbs", orientation:, "ui--carousel-target": "thumbs" }
      }, @attributes.except(:class)), class: cn("relative", orientation == :vertical ? "h-full" : "w-full", override: @attributes[:class])) do
        div(class: cn("overflow-hidden -m-0.5 p-0.5", ("h-full" if orientation == :vertical)), data: { slot: "carousel-thumbs-viewport", "ui--carousel-target": "thumbsViewport" }) do
          div(class: TRACK[orientation], data: { slot: "carousel-thumbs-content" }, &)
        end
        span(aria_hidden: "true", class: cn("pointer-events-none absolute top-0 left-0 rounded-lg border motion-safe:transition-[translate,width,height] motion-safe:duration-250", light? ? "border-white" : "border-border-inverse"),
             data: { slot: "carousel-thumbs-indicator", "ui--carousel-target": "thumbsIndicator" })
      end
    end
  end

  def light?
    @light.nil? ? !!context[:ui_carousel]&.light? : @light
  end
end
