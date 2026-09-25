# A product-reviews card: the average with stars and a review count, the breakdown per star and
# a social-proof footer - composed from Rating, Meter, Separator and AvatarGroup.
#
# Localized - try the toolbar's **Locale** option: the review count is pluralized per language
# and every number uses the locale's format.
#
# @label Review summary
# @logical_path Blocks
# @component Blocks::ReviewSummary
# @display width wide
class Blocks::ReviewSummaryPreview < UI::BasePreview
  COUNTS = { 5 => 1_002, 4 => 180, 3 => 64, 2 => 26, 1 => 12 }.freeze
  REVIEWERS = [
    { src: "/avatars/02.png", alt: "Liam Hudson" },
    { src: "/avatars/04.png", alt: "Ava Thompson" },
    { src: "/avatars/09.png", alt: "Emma Garcia" }
  ].freeze

  # @label Usage
  # The Appica homepage card. The stars show the exact average (4.8 fills four and four-fifths).
  # @param rating number
  def default(rating: 4.8)
    phlex do
      ReviewSummary(rating: rating.to_f, reviews: COUNTS.values.sum, class: "w-100 max-w-full") do
        ReviewBreakdown(counts: COUNTS)
        ReviewHighlight(avatars: REVIEWERS) { "Loved by 12,000+ shoppers" }
      end
    end
  end

  # @label Linked rows
  # With `href:` each row links to the reviews filtered by that star.
  def linked
    phlex do
      ReviewSummary(rating: 4.8, reviews: COUNTS.values.sum, class: "w-100 max-w-full") do
        ReviewBreakdown(counts: COUNTS, href: ->(stars) { "#reviews-#{stars}-stars" })
      end
    end
  end

  # @label Few reviews
  # The count is pluralized per language ("1 verified review", "3 ověřené recenze").
  def few
    phlex do
      div(class: "flex flex-col gap-4") do
        ReviewSummary(rating: 5, reviews: 1, class: "w-100 max-w-full") { ReviewBreakdown(counts: { 5 => 1 }) }
        ReviewSummary(rating: 3.7, reviews: 3, verified: false, class: "w-100 max-w-full") { ReviewBreakdown(counts: { 5 => 1, 4 => 1, 2 => 1 }) }
      end
    end
  end

  # @label RTL
  # Rendered in Arabic whatever the toolbar says: stars and meters fill from the right.
  def rtl
    phlex do
      I18n.with_locale(:ar) do
        div(dir: "rtl") do
          ReviewSummary(rating: 4.8, reviews: COUNTS.values.sum, class: "w-100 max-w-full") do
            ReviewBreakdown(counts: COUNTS)
            ReviewHighlight(avatars: REVIEWERS) { "أحبه أكثر من 12,000 متسوق" }
          end
        end
      end
    end
  end
end
