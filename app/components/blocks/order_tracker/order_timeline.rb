# The list of shipment steps, joined by a line.
class Blocks::OrderTimeline < Blocks::Base
  def view_template(&)
    ol(**mix({ aria_label: t(".timeline"), data: { slot: "order-timeline" } }, @attributes.except(:class)), class: cn("mt-5 flex-1", override: @attributes[:class]), &)
  end
end
