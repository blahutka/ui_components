# A thin horizontal or vertical line that separates content.
#
# Horizontal by default; `orientation: :vertical` stretches to its flex row. Seven line styles,
# drawn with currentColor - recolor with any text-* class.
#
# @label Separator
# @logical_path Data Display
# @component AppicaUI::Separator
# @display width wide
class AppicaUI::SeparatorPreview < AppicaUI::BasePreview
  # @label Usage
  # @param variant [Symbol] select {{ choices_for AppicaUI::Separator, :variant }}
  # @param orientation [Symbol] select {{ choices_for AppicaUI::Separator, :orientation }}
  def default(variant: :solid, orientation: :horizontal)
    phlex do
      if orientation.to_sym == :vertical
        div(class: "text-foreground flex h-12 items-center gap-4 text-sm") do
          span { "Left" }
          Separator(variant:, orientation:)
          span { "Right" }
        end
      else
        div(class: "text-foreground flex w-full max-w-xs flex-col gap-4 text-sm") do
          span { "Above the line" }
          Separator(variant:)
          span { "Below the line" }
        end
      end
    end
  end

  # solid, dashed, double and gradient are CSS borders; dotted, wave and zigzag a repeating SVG
  # pattern that scales with the width.
  def variants
    phlex do
      div(class: "flex w-full max-w-xs flex-col gap-5") do
        AppicaUI::Separator::VARIANTS.each_key do |variant|
          div(class: "flex flex-col gap-2") do
            span(class: "text-sm capitalize") { variant.to_s }
            Separator(variant:)
          end
        end
      end
    end
  end

  # The line uses currentColor: text-border by default, any text-* class to recolor it.
  def colors
    phlex do
      div(class: "flex w-full max-w-xs flex-col gap-5") do
        %w[ text-border text-border-strong text-border-intense text-primary text-secondary text-error text-success text-warning text-info ].each do |color|
          div(class: "flex flex-col gap-2") do
            span(class: "text-sm") { color }
            Separator(class: color)
          end
        end
      end
    end
  end

  # @label Vertical orientation
  # Vertical separators divide inline items and stretch to the row's height.
  def vertical
    phlex do
      div(class: "text-foreground flex h-5 items-center gap-4 text-sm") do
        span { "Profile" }
        Separator(orientation: :vertical)
        span { "Settings" }
        Separator(orientation: :vertical)
        span { "Sign out" }
      end
    end
  end

  # @label In context
  # A horizontal rule between stacked sections and vertical rules between inline stats.
  def in_context
    phlex do
      div(class: "border-border w-full max-w-sm rounded-xl border p-5") do
        div(class: "flex flex-col gap-1") do
          h3(class: "text-foreground-intense font-medium") { "Mia Carter" }
          p(class: "text-foreground-muted text-sm") { "Product designer based in Lisbon." }
        end
        Separator(class: "my-4")
        div(class: "flex justify-between text-sm") do
          [ %w[ 248 posts ], %w[ 12.4k followers ], %w[ 312 following ] ].each_with_index do |(count, label), index|
            Separator(orientation: :vertical, class: "mx-2.5") if index.positive?
            div do
              span(class: "font-semibold") { count }
              plain " #{label}"
            end
          end
        end
      end
    end
  end

  # @label RTL
  # The items around a vertical separator follow the reading direction.
  def rtl
    phlex do
      div(dir: "rtl", class: "text-foreground flex h-5 items-center gap-4 text-sm") do
        span { "الملف الشخصي" }
        Separator(orientation: :vertical)
        span { "الإعدادات" }
        Separator(orientation: :vertical)
        span { "تسجيل الخروج" }
      end
    end
  end
end
