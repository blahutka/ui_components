# One step: :done (a check), :current (a ringed dot) or :upcoming (a hollow dot, its time shown
# as an ETA). `title:` may be a translation key (:confirmed, :shipped, :sorting_hub,
# :local_facility, :out_for_delivery, :delivered) or any string; `at:` a Time.
class AppicaUI::Blocks::OrderStep < AppicaUI::Blocks::Base
  STATES = %i[ done current upcoming ].freeze

  prop :title, translated(".steps")
  prop :at,    default: -> { nil }
  prop :state, one_of(STATES, :done), default: -> { :done }

  def view_template
    li(**mix({ aria_current: ("step" if @state == :current), data: { slot: "order-step", state: @state } }, @attributes.except(:class)),
      class: cn("relative ps-7 pb-5 last:pb-0 before:bg-border before:absolute before:inset-s-2 before:top-5.5 before:bottom-0.5 before:w-px last:before:hidden", override: @attributes[:class])) do
      marker
      div(class: "flex items-baseline justify-between gap-2") do
        span(class: (@state == :upcoming ? "text-foreground-muted text-sm" : "text-foreground-intense text-sm font-medium")) { @title }
        time(datetime: @at.iso8601, class: "text-foreground-muted text-xs whitespace-nowrap") { moment } if @at
      end
    end
  end

  private
    def marker
      case @state
      when :done then Icon(:circle_check_filled, class: "text-primary absolute inset-s-0 top-0.5 size-4")
      when :current then span(class: "bg-primary ring-primary/25 absolute inset-s-0.75 top-1 size-2.5 rounded-full ring-3")
      else span(class: "border-border-strong absolute inset-s-0.75 top-1 size-2.5 rounded-full border-2")
      end
    end

    # "Today, 11:05 AM", "Jul 4, 6:12 PM" - or "ETA 2:15 PM" for what's still to come
    def moment
      time = I18n.l(@at, format: t(".formats.time"))
      return t(".eta", time:) if @state == :upcoming

      case @at.to_date
      when Date.current then t(".when.today", time:)
      when Date.yesterday then t(".when.yesterday", time:)
      else t(".when.date", date: I18n.l(@at, format: t(".formats.date")), time:)
      end
    end
end
