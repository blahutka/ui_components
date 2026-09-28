# A product-reviews card: the average score with stars and a review count, the breakdown by
# stars and a social-proof footer - composed from Rating, Meter, Separator and AvatarGroup.
#
#   ReviewSummary(rating: 4.8, reviews: 1_284) do
#     ReviewBreakdown(counts: product.reviews.group(:stars).count)
#     ReviewHighlight(avatars: recent_reviewers) { "Loved by 12,000+ shoppers" }
#   end
#
# Localized (review_summary.locales.yml): the review count is pluralized and every number uses
# the current locale's format.
class AppicaUI::Blocks::ReviewSummary < AppicaUI::Blocks::Base
  prop :rating
  prop :reviews,  default: -> { nil }
  prop :max,      default: -> { 5 }
  prop :verified, default: -> { true }
  prop :label,    default: -> { @reviews && t(@verified ? ".verified_reviews" : ".reviews", count: @reviews, formatted: format_count(@reviews)) }

  attr_reader :max

  def view_template(&)
    provide(:review_summary, self) do
      div(**mix(defaults(data: { slot: "review-summary" }), @attributes.except(:class)), class: cn(
        "bg-background border-border-muted flex flex-col rounded-xl border p-6 shadow-lg dark:shadow-[0_8px_16px_-4px_rgba(0,0,0,0.8)]",
        override: @attributes[:class]
      )) do
        div(class: "flex items-center gap-3") do
          span(class: "text-foreground-intense text-3xl font-semibold tabular-nums", data: { slot: "review-score" }) { score }
          div do
            Rating(value: @rating, count: @max, step: 0.1, size: 14, read_only: true, class: "text-warning-emphasis")
            div(class: "text-foreground-muted mt-1 text-xs") { @label } if @label
          end
        end
        yield if block_given?
      end
    end
  end

  private
    def score
      ActiveSupport::NumberHelper.number_to_rounded(@rating, precision: 1, locale: I18n.locale)
    end
end
