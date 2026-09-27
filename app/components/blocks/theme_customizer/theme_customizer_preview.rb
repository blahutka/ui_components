# Appica's theme settings: mode, base / primary / secondary colors, font and radius, with the CSS
# overrides to paste into your app. Changes repaint the page and every other Lookbook preview.
#
# @label Theme customizer
# @logical_path Blocks
# @component Blocks::ThemeCustomizer
# @display width full
class Blocks::ThemeCustomizerPreview < UI::BasePreview
  # Props not in the Usage form (data, render blocks, generated ids): see ui_components:preview_params
  UNLISTED_PROPS = %i[ id ].freeze

  # @label Usage
  # Pick colors, a font and a radius - the components on the right (and every other preview,
  # even in other tabs) follow. "Get CSS Code" shows the overrides for your stylesheet.
  # @param title text
  def default(title: nil)
    phlex do
      div(class: "grid w-full items-start gap-8 lg:grid-cols-[22rem_minmax(0,1fr)]") do
        ThemeCustomizer(**given(title:))
        div(class: "flex min-w-0 flex-col gap-6", data: { slot: "theme-sample" }) do
          div(class: "flex flex-wrap items-center gap-2") do
            %i[ primary secondary outline soft ghost primary_outline destructive ].each do |variant|
              Button(variant:) { variant.to_s.humanize }
            end
          end
          div(class: "flex flex-wrap items-center gap-2") do
            %i[ primary secondary outline soft success warning error info ].each { |variant| Badge(variant:) { variant.to_s.humanize } }
          end
          div(class: "grid gap-4 sm:grid-cols-2") do
            Input(placeholder: "Your email", start_slot: :mail)
            Select(default_value: "pro") do
              SelectTrigger(aria_label: "Plan") { SelectValue() }
              SelectContent do
                SelectItem(value: "free") { "Free" }
                SelectItem(value: "pro") { "Pro" }
              end
            end
          end
          div(class: "flex flex-wrap items-center gap-6 text-sm") do
            label(class: "flex items-center gap-2") { Checkbox(checked: true); plain "Checkbox" }
            label(class: "flex items-center gap-2") { Switch(checked: true); plain "Switch" }
            RadioGroup(default_value: "a", orientation: :horizontal, aria_label: "Radio") do
              label(class: "flex items-center gap-2") { Radio(value: "a"); plain "Radio" }
            end
            Slider(default_value: 60, thumb_aria_label: "Slider", class: "w-40")
          end
          Transactions(class: "max-w-100") do
            Transaction(title: "Stripe payout", category: "Income", date: Date.new(2026, 7, 3), amount: 860.40, icon: :brand_stripe)
            Transaction(title: "Spotify Premium", category: "Subscription", date: Date.new(2026, 7, 2), amount: -11.99, icon: :brand_spotify)
          end
        end
      end
    end
  end

  # @label Panel only
  def panel
    phlex { ThemeCustomizer(class: "w-88 max-w-full") }
  end
end
