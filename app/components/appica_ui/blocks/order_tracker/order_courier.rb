# The courier row under a separator: avatar, "Marcus is on the way", stops left and a button to
# the live map.
class AppicaUI::Blocks::OrderCourier < AppicaUI::Blocks::Base
  prop :name
  prop :avatar, default: -> { nil }
  prop :stops,  default: -> { nil }
  prop :href,   default: -> { nil }

  def view_template
    Separator(class: "my-4")
    div(**mix({ data: { slot: "order-courier" } }, @attributes.except(:class)), class: cn("flex items-center gap-3", override: @attributes[:class])) do
      Avatar(size: :sm) do
        AvatarImage(src: @avatar, alt: @name) if @avatar
        AvatarFallback { @name.to_s[0] }
      end
      div(class: "min-w-0 flex-1") do
        div(class: "text-foreground-intense truncate text-sm font-medium") { t(".courier.on_the_way", name: @name) }
        div(class: "text-foreground-muted text-xs") { t(".courier.stops", count: @stops, formatted: format_count(@stops)) } if @stops
      end
      Button(href: @href, variant: :outline, size: :sm, icon: true, aria_label: t(".courier.track")) { Icon(:route) } if @href
    end
  end
end
