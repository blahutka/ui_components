# One figure: a muted label over a bold value. `label:` may be a translation key (:orders,
# :average_order, :refunds, :conversion); `value:` is formatted as a number, or money with
# `money: true` - or pass the value as a block.
class Blocks::RevenueStat < Blocks::Base
  prop :label, translated(".stats")
  prop :value, default: -> { nil }
  prop :money, default: -> { false }

  def view_template(&block)
    summary = consume(:revenue_summary, component: "Blocks::RevenueSummary")

    div(**mix({ data: { slot: "revenue-stat" } }, @attributes.except(:class)), class: @attributes[:class]) do
      div(class: "text-foreground-muted text-xs") { @label }
      div(class: "text-foreground-intense text-sm font-semibold tabular-nums") do
        if block
          yield
        elsif @money
          summary.money(@value)
        else
          format_count(@value)
        end
      end
    end
  end
end
