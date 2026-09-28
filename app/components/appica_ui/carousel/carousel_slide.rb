# One slide / snap point. Full width by default; set a basis-* class to show several per view.
class AppicaUI::CarouselSlide < AppicaUI::Base
  GUTTER = { horizontal: "ps-4", vertical: "pt-4" }.freeze

  def view_template(&)
    div(**mix({
      role: "group",
      aria: { roledescription: "slide" },
      data: { slot: "carousel-slide", orientation: carousel.orientation, "appica-ui--carousel-target": "slide" }
    }, @attributes.except(:class)), class: cn("min-h-0 min-w-0 shrink-0 grow-0 basis-full", GUTTER[carousel.orientation], override: @attributes[:class]), &)
  end

  private
    def carousel = consume(:ui_carousel, component: "Carousel")
end
