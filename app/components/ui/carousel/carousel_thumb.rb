# One thumbnail: a button around a square, clipped media frame. 72px by default;
# size it with a width class (the height follows the square aspect).
#
#   CarouselThumb(class: "w-16 sm:w-22") { img(src: slide.url, alt: "", class: "size-full object-cover") }
class UI::CarouselThumb < UI::Base
  BASE = "block w-18 shrink-0 grow-0 transform-gpu cursor-pointer rounded-lg border p-1 focus-visible:outline-2 " \
    "transition-[opacity,translate,scale] motion-reduce:transition-none duration-[300ms,250ms,250ms] ease-[ease-out,cubic-bezier(0.175,0.885,0.32,1.5),cubic-bezier(0.175,0.885,0.32,1.5)] " \
    "active:duration-[300ms,100ms,100ms] active:ease-[ease-out,ease-in-out,ease-in-out] active:translate-y-px active:scale-[0.97] " \
    "not-data-active:opacity-65 not-data-active:hover:opacity-100"

  TONES = {
    default: "bg-background outline-ring",
    light: "outline-ring-light border-white/25 bg-white/10 backdrop-blur-md"
  }.freeze

  MEDIA = {
    default: "relative block aspect-square w-full overflow-hidden rounded-md bg-background-muted",
    light: "relative block aspect-square w-full overflow-hidden rounded-md bg-white/10"
  }.freeze

  def initialize(index: nil, **attributes)
    @index = index
    @attributes = attributes
  end

  def view_template(&)
    tone = thumbs.light? ? :light : :default

    button(**mix({
      type: "button",
      data: { slot: "carousel-thumb", index: @index, "ui--carousel-target": "thumb", action: "ui--carousel#selectThumb" }
    }, @attributes.except(:class)), class: cn(BASE, TONES[tone], override: @attributes[:class])) do
      span(class: MEDIA[tone], data: { slot: "carousel-thumb-media" }, &)
    end
  end

  private
    def thumbs = consume(:ui_carousel_thumbs, component: "CarouselThumbs")
end
