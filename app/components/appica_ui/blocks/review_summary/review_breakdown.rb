# The share of reviews per star, highest first, as meters. `counts:` maps stars to review
# counts (e.g. `reviews.group(:stars).count`); pass `href:` (a proc of the star) to link each row
# to the filtered reviews.
class AppicaUI::Blocks::ReviewBreakdown < AppicaUI::Blocks::Base
  prop :counts, ->(counts) { counts.to_h.transform_keys(&:to_i) }
  prop :href,   default: -> { nil }

  def view_template
    summary = consume(:review_summary, component: "AppicaUI::Blocks::ReviewSummary")
    total = @counts.values.sum

    div(**mix({ data: { slot: "review-breakdown" } }, @attributes.except(:class)), class: cn("mt-4 flex flex-1 flex-col justify-center gap-2", override: @attributes[:class])) do
      summary.max.downto(1) { |stars| row(stars, total.zero? ? 0 : @counts.fetch(stars, 0) * 100.0 / total) }
    end
  end

  private
    def row(stars, percent)
      content = proc do
        span(class: "text-foreground-muted w-2 text-xs tabular-nums") { stars.to_s }
        Meter(value: percent.round(1), aria_label: t(".stars", count: stars), class: "flex-1") { MeterProgress() }
        span(class: "text-foreground-muted w-8 text-end text-xs tabular-nums") { format_percent(percent.round) }
      end

      if @href
        a(href: @href.call(stars), data: { slot: "review-breakdown-row", stars: }, class: "hover:bg-background-muted -mx-1.5 flex items-center gap-2.5 rounded-sm px-1.5 outline-ring", &content)
      else
        div(data: { slot: "review-breakdown-row", stars: }, class: "flex items-center gap-2.5", &content)
      end
    end
end
