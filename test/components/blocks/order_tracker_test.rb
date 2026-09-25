require "test_helper"

class Blocks::OrderTrackerTest < ComponentTestCase
  def tracker(today: Time.current.beginning_of_day)
    render_ui do
      OrderTracker(number: "10482", items: 2, total: 148, status: :in_transit, progress: 75) do
        OrderTimeline do
          OrderStep(title: :confirmed, at: today - 3.days + 9.hours + 41.minutes)
          OrderStep(title: :shipped, at: today - 1.day + 18.hours + 12.minutes)
          OrderStep(title: :out_for_delivery, at: today + 11.hours + 5.minutes, state: :current)
          OrderStep(title: "Delivered to locker", at: today + 14.hours + 15.minutes, state: :upcoming)
        end
        OrderCourier(name: "Marcus", avatar: "/avatars/02.png", stops: 3, href: "/map")
      end
    end
  end

  test "renders the header, status and progress" do
    html = tracker

    assert_equal "Order #10482", html.at_css("h3").text
    assert_equal "2 items · $148.00", html.at_css("h3 + p").text
    badge = html.at_css("[data-slot=badge]")
    assert_equal "In transit", badge.text
    assert_includes badge.at_css("span")["class"], "bg-info-emphasis"
    progress = html.at_css("[data-slot=progress]")
    assert_equal "75", progress["aria-valuenow"]
    assert_equal "Delivery progress", progress["aria-label"]
  end

  test "steps show their state, translated titles and relative times" do
    steps = tracker.css("[data-slot=order-step]")

    assert_equal %w[ done done current upcoming ], steps.map { |step| step["data-state"] }
    assert_equal [ "Order confirmed", "Packed & shipped", "Out for delivery", "Delivered to locker" ], steps.map { |step| step.at_css("div > span").text }
    assert_equal "circle-check-filled", steps.first.at_css("svg")["data-name"]
    assert_equal "step", steps[2]["aria-current"]
    times = steps.map { |step| step.at_css("time").text }
    assert_match(/\A[A-Z][a-z]{2} \d+, 9:41 AM\z/, times[0])
    assert_equal [ "Yesterday, 6:12 PM", "Today, 11:05 AM", "ETA 2:15 PM" ], times[1..]
  end

  test "the courier row links to the map" do
    courier = tracker.at_css("[data-slot=order-courier]")

    assert_includes courier.text, "Marcus is on the way"
    assert_includes courier.text, "3 stops away"
    assert_equal "/map", courier.at_css("a")["href"]
    assert_equal "Track on map", courier.at_css("a")["aria-label"]
    assert tracker.at_css("[data-slot=separator]")
  end

  test "localized: statuses, counts, money and times" do
    html = I18n.with_locale(:cs) { tracker }

    assert_equal "Objednávka č. 10482", html.at_css("h3").text
    assert_equal "2 položky · 148,00 $", html.at_css("h3 + p").text
    assert_equal "Na cestě", html.at_css("[data-slot=badge]").text
    assert_equal [ "Včera, 18:12", "Dnes, 11:05", "Odhad 14:15" ], html.css("[data-slot=order-step] time")[1..].map(&:text)
    assert_includes html.at_css("[data-slot=order-courier]").text, "3 zastávky před vámi"
  end

  test "optional parts: no totals, no progress; unknown status falls back" do
    html = render_ui { OrderTracker(number: "7", status: :lost) }

    assert_nil html.at_css("h3 + p")
    assert_nil html.at_css("[data-slot=progress]")
    assert_equal "processing", html.at_css("[data-slot=order-tracker]")["data-status"]
  end
end
