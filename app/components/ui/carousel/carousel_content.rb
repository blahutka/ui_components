# The scroll viewport plus the flex track that holds the slides. `class:` lands on the
# track (e.g. a fixed height like "h-100" for vertical carousels); `viewport:` reaches
# the clipping element.
class UI::CarouselContent < UI::Base
  TRACK = {
    horizontal: "flex -ms-4 touch-pan-y touch-pinch-zoom items-start",
    vertical: "flex -mt-4 touch-pan-x touch-pinch-zoom flex-col"
  }.freeze

  def initialize(viewport: {}, **attributes)
    @viewport = viewport
    @attributes = attributes
  end

  def view_template(&)
    div(**mix({
      tabindex: "0",
      data: {
        slot: "carousel-viewport",
        orientation: carousel.orientation,
        "ui--carousel-target": "viewport",
        action: "keydown->ui--carousel#navigate"
      }
    }, @viewport.except(:class)), class: cn("overflow-hidden outline-none", override: @viewport[:class])) do
      div(**mix({ data: { slot: "carousel-content", orientation: carousel.orientation, "ui--carousel-target": "container" } }, @attributes.except(:class)),
          class: cn(TRACK[carousel.orientation], override: @attributes[:class]), &)
    end
  end

  private
    def carousel = consume(:ui_carousel, component: "Carousel")
end
