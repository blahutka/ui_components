# A clipped box for an image or video, above the header or below the footer. Direct
# <img> / <video> children fill it (size-full, object-cover), so a height is all it needs.
# Inset cards round all four corners at ×3/4 of the card radius; flush cards
# (`inset: false`) let the content wrapper clip it edge to edge.
class UI::CardMedia < UI::Base
  BASE = "relative shrink-0 overflow-hidden group-data-inset/card:rounded-[calc(var(--card-radius)*3/4)] " \
    "[&>img]:size-full [&>img]:object-cover [&>video]:size-full [&>video]:object-cover"

  def initialize(**attributes)
    @attributes = attributes
  end

  def view_template(&)
    div(**mix({ data: { slot: "card-media" } }, @attributes.except(:class)), class: cn(BASE, override: @attributes[:class]), &)
  end
end
