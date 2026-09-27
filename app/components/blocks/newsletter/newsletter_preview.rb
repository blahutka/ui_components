# A newsletter signup: heading, pitch, perks, an email form with a honeypot and social links -
# composed from Field, Input, Button, Thumbnail and Icon.
#
# @label Newsletter
# @logical_path Blocks
# @component Blocks::Newsletter
# @display width wide
class Blocks::NewsletterPreview < UI::BasePreview
  # Props not in the Usage form (data, render blocks, generated ids): see ui_components:preview_params
  UNLISTED_PROPS = %i[ action socials ].freeze

  SOCIALS = [
    { href: "https://x.com/Appica_dev", icon: :brand_x, label: "X" },
    { href: "https://github.com/appica-dev/appica-ui", icon: :brand_github, label: "GitHub" }
  ].freeze

  # @label Usage
  # The Appica homepage section, on its dark panel. Without `action:` it's a demo: submit a
  # valid address to see the thank-you; an empty or invalid one shows the field's error.
  # @param dark [Boolean] toggle "Dark panel"
  # @param title text
  # @param note text
  # @param method text
  # @param honeypot text
  # @param description text
  def default(dark: true, title: nil, note: nil, method: "post", honeypot: "website", description: "Subscribe for occasional updates, product insights, and early news from our team - or follow along on X and GitHub.")
    phlex do
      div(class: [ ("dark" if dark), "bg-background w-full max-w-2xl rounded-2xl p-8 md:p-12" ].compact.join(" ")) do
        Newsletter(method:, honeypot:, **given(title:, note:), description:, socials: SOCIALS) do
          NewsletterPerk(icon: :sparkles) { "Major library updates" }
          NewsletterPerk(icon: :template) { "Premium templates" }
          NewsletterPerk(icon: :components) { "New component releases" }
        end
      end
    end
  end

  # @label Form only
  # No perks or social links - just the pitch and the form.
  def minimal
    phlex do
      Newsletter(title: "Get the changelog", description: "One email a month with everything we shipped.", class: "w-full max-w-md")
    end
  end

  # @label RTL
  # Rendered in Arabic whatever the toolbar says; the arrow mirrors.
  def rtl
    phlex do
      I18n.with_locale(:ar) do
        div(dir: "rtl", class: "w-full max-w-2xl") do
          Newsletter(socials: SOCIALS) do
            NewsletterPerk(icon: :sparkles) { "تحديثات رئيسية للمكتبة" }
            NewsletterPerk(icon: :template) { "قوالب مميزة" }
          end
        end
      end
    end
  end
end
