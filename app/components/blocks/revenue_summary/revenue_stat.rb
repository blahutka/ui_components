# One figure: a muted label over a bold value.
class Blocks::RevenueStat < Blocks::Base
  prop :label

  def view_template(&)
    div(**mix({ data: { slot: "revenue-stat" } }, @attributes.except(:class)), class: @attributes[:class]) do
      div(class: "text-foreground-muted text-xs") { @label }
      div(class: "text-foreground-intense text-sm font-semibold tabular-nums", &)
    end
  end
end
