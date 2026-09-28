# A shipment card: the order number and total, a status badge, the delivery progress, a timeline
# of steps and the courier - composed from Badge, Progress, Icon, Separator, Avatar and Button.
#
#   OrderTracker(number: "10482", items: 2, total: 148, status: :in_transit, progress: 75) do
#     OrderTimeline do
#       OrderStep(title: :confirmed, at: order.confirmed_at, state: :done)
#       OrderStep(title: :out_for_delivery, at: Time.current, state: :current)
#       OrderStep(title: :delivered, at: order.eta, state: :upcoming)
#     end
#     OrderCourier(name: "Marcus", avatar: courier.avatar_url, stops: 3, href: tracking_url)
#   end
#
# Localized (order_tracker.locales.yml): statuses, step titles given as symbols, item and stop
# counts (pluralized), money and times ("Today, 11:05 AM", "ETA 2:15 PM").
class AppicaUI::Blocks::OrderTracker < AppicaUI::Blocks::Base
  STATUS_COLORS = {
    processing: "bg-warning-emphasis", shipped: "bg-info-emphasis", in_transit: "bg-info-emphasis",
    out_for_delivery: "bg-info-emphasis", delivered: "bg-success-emphasis", delayed: "bg-error-emphasis"
  }.freeze

  prop :number
  prop :items,    default: -> { nil }
  prop :total,    default: -> { nil }
  prop :currency, default: -> { "USD" }
  prop :status,   one_of(STATUS_COLORS, :processing), default: -> { :processing }
  prop :progress, default: -> { nil }

  def view_template(&)
    div(**mix(defaults(data: { slot: "order-tracker", status: @status }), @attributes.except(:class)), class: cn(
      "bg-background border-border-muted flex flex-col rounded-xl border p-6 shadow-lg dark:shadow-[0_8px_16px_-4px_rgba(0,0,0,0.8)]",
      override: @attributes[:class]
    )) do
      div(class: "flex items-start justify-between gap-2") do
        div do
          h3(class: "text-foreground-intense text-sm font-semibold") { t(".title", number: @number) }
          p(class: "text-foreground-muted text-xs") { summary } if @items || @total
        end
        Badge(variant: :outline, data: { status: @status }) do
          span(class: cn("size-2 shrink-0 rounded-full", STATUS_COLORS[@status]))
          plain t(".statuses.#{@status}")
        end
      end
      Progress(value: @progress, aria_label: t(".progress"), class: "mt-4") if @progress
      yield if block_given?
    end
  end

  private
    def summary
      total = @total && format_money(@total, currency: @currency, precision: 2)
      if @items
        t(".summary", count: @items, formatted: format_count(@items), total: total.to_s).delete_suffix(" · ")
      else
        total
      end
    end
end
