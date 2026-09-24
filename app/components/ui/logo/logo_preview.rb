# A brand logo: a circular mark drawn with Phlex's SVG builder, plus a wordmark in three
# parts - a bold prefix, a light name and an accent-coloured suffix.
#
# @label Logo
# @logical_path Brand
# @component UI::Logo
# @display width wide
class UI::LogoPreview < UI::BasePreview
  # @label Usage
  # @param prefix text "Bold text before the name"
  # @param name text "Light part of the wordmark"
  # @param suffix text "Accent-coloured text after the name"
  # @param size [Symbol] select "Scales the mark and the text together" { choices: [sm, md, lg, xl] }
  # @param accent [Symbol] select "Colour of the disc and the suffix" { choices: [blue, green, violet, orange] }
  # @param variant [Symbol] select "Mark and wordmark, or just one of them" { choices: [full, mark, wordmark] }
  def default(prefix: "Be", name: "humble", suffix: ".com", size: :lg, accent: :blue, variant: :full)
    phlex do
      div(class: "flex justify-center py-6") do
        Logo(prefix:, name:, suffix:, size:, accent:, variant:)
      end
    end
  end

  # `size:` sets the font size; the mark is 1.6em, so it scales with the text.
  def sizes
    phlex do
      div(class: "flex flex-col items-start gap-6") do
        UI::Logo::SIZES.each_key { |size| Logo(size:) }
      end
    end
  end

  # `variant: :mark` for favicons, avatars and tight spots (it gets an accessible name),
  # `variant: :wordmark` for text-only placements.
  def variants
    phlex do
      div(class: "flex flex-wrap items-center gap-10") do
        Logo(size: :lg)
        Logo(size: :lg, variant: :mark)
        Logo(size: :lg, variant: :wordmark)
      end
    end
  end

  # The disc and the suffix share one accent colour.
  def accents
    phlex do
      div(class: "grid gap-6 sm:grid-cols-2") do
        { blue: [ "Be", "humble", ".com" ], green: [ "Grow", "kind", ".org" ], violet: [ "", "Sproutly", ".app" ], orange: [ "My", "garden", ".io" ] }.each do |accent, (prefix, name, suffix)|
          Logo(prefix:, name:, suffix:, accent:, size: :md)
        end
      end
    end
  end

  # @label In components
  # A linked logo in a header bar, and the mark leading a sign-in Card.
  def in_components
    phlex do
      div(class: "flex flex-col gap-8") do
        header(class: "border-border flex items-center justify-between rounded-xl border px-4 py-3") do
          Logo(size: :sm, href: "#home", aria_label: "Behumble.com home")
          nav(class: "flex items-center gap-2") do
            Button(variant: :ghost, size: :sm) { "Pricing" }
            Button(size: :sm) { "Sign up" }
          end
        end

        Card(frame: :solid, as: :form, action: "#", class: "mx-auto w-full max-w-90") do
          CardHeader do
            Logo(variant: :mark, size: :md)
            CardTitle(class: "mt-2 text-xl") { "Sign in to Behumble" }
            CardDescription { "Grow a little every day - pick up where you left off." }
          end
          CardFooter { Button(type: "submit", class: "w-full") { "Continue" } }
        end
      end
    end
  end

  # @label Dark background
  # The ring follows the foreground colour and the ring fill follows the background,
  # so the mark works in both themes.
  def dark
    phlex do
      div(class: "dark bg-background flex justify-center rounded-xl p-8") do
        Logo(size: :lg)
      end
    end
  end
end
