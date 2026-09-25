# One Newsletter perk: an outline icon tile and a line of text.
#
#   NewsletterPerk(icon: :template) { "Premium templates" }
class Blocks::NewsletterPerk < Blocks::Base
  prop :icon, default: -> { :check }

  def view_template(&)
    li(**mix({ data: { slot: "newsletter-perk" } }, @attributes.except(:class)), class: cn("flex items-center gap-3", override: @attributes[:class])) do
      Thumbnail(variant: :icon_outline, size: :sm) { Icon(@icon) }
      span(class: "text-foreground-emphasis", &)
    end
  end
end
