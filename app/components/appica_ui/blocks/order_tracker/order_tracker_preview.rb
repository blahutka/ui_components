# A shipment card: order and total, a status badge, the delivery progress, a timeline of steps
# and the courier - composed from Badge, Progress, Icon, Separator, Avatar and Button.
#
# Localized - try the toolbar's **Locale** option: statuses, step titles, counts, money and
# times ("Today, 11:05 AM", "ETA 2:15 PM") follow it.
#
# @label Order tracker
# @logical_path Blocks
# @component AppicaUI::Blocks::OrderTracker
# @display width wide
class AppicaUI::Blocks::OrderTrackerPreview < AppicaUI::BasePreview
  # @label Usage
  # The Appica homepage card - the order is out for delivery today.
  # @param status [Symbol] select {{ choices_for AppicaUI::Blocks::OrderTracker, :status }}
  # @param progress number
  # @param currency text
  # @param number text
  # @param items number
  # @param total number
  def default(status: :in_transit, progress: 75, currency: "USD", number: "10482", items: 2, total: 148)
    today = Time.current.beginning_of_day

    phlex do
      OrderTracker(status:, currency:, number:, items:, total:, progress: progress.to_f, class: "w-100 max-w-full") do
        OrderTimeline do
          OrderStep(title: :confirmed, at: today - 2.days + 9.hours + 41.minutes)
          OrderStep(title: :shipped, at: today - 1.day + 18.hours + 12.minutes)
          OrderStep(title: :sorting_hub, at: today + 7.hours + 48.minutes)
          OrderStep(title: :local_facility, at: today + 8.hours + 30.minutes)
          OrderStep(title: :out_for_delivery, at: today + 11.hours + 5.minutes, state: :current)
          OrderStep(title: :delivered, at: today + 14.hours + 15.minutes, state: :upcoming)
        end
        OrderCourier(name: "Marcus", avatar: "/avatars/02.png", stops: 3, href: "#map")
      end
    end
  end

  # @label Delivered
  # All steps done, the courier row dropped.
  def delivered
    today = Time.current.beginning_of_day

    phlex do
      OrderTracker(number: "10377", items: 1, total: 59.9, currency: "EUR", status: :delivered, progress: 100, class: "w-100 max-w-full") do
        OrderTimeline do
          OrderStep(title: :confirmed, at: today - 5.days + 10.hours)
          OrderStep(title: :shipped, at: today - 4.days + 16.hours + 20.minutes)
          OrderStep(title: :out_for_delivery, at: today - 1.day + 8.hours + 45.minutes)
          OrderStep(title: :delivered, at: today - 1.day + 13.hours + 2.minutes)
        end
      end
    end
  end

  # @label Custom steps
  # Step titles take any string; a timeline works without the progress bar.
  def custom_steps
    phlex do
      OrderTracker(number: "A-2291", items: 5, status: :delayed, class: "w-100 max-w-full") do
        OrderTimeline do
          OrderStep(title: "Customs cleared", at: Time.current - 3.hours)
          OrderStep(title: "Held at border - weather", at: Time.current - 20.minutes, state: :current)
          OrderStep(title: "Next attempt", at: Time.current + 1.day, state: :upcoming)
        end
      end
    end
  end

  # @label RTL
  # Rendered in Arabic whatever the toolbar says: the timeline line and markers sit on the right.
  def rtl
    today = Time.current.beginning_of_day

    phlex do
      I18n.with_locale(:ar) do
        div(dir: "rtl") do
          OrderTracker(number: "10482", items: 2, total: 148, status: :in_transit, progress: 75, class: "w-100 max-w-full") do
            OrderTimeline do
              OrderStep(title: :confirmed, at: today - 2.days + 9.hours + 41.minutes)
              OrderStep(title: :out_for_delivery, at: today + 11.hours + 5.minutes, state: :current)
              OrderStep(title: :delivered, at: today + 14.hours + 15.minutes, state: :upcoming)
            end
            OrderCourier(name: "Marcus", avatar: "/avatars/02.png", stops: 3, href: "#map")
          end
        end
      end
    end
  end
end
