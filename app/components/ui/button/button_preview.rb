# Appica's Button: the trigger and action element used by Drawer, Dialog, …
# Renders an <a> when given `href:`.
#
# @label Button
# @logical_path Actions & Inputs
# @component UI::Button
# @display width wide
class UI::ButtonPreview < UI::BasePreview
  # @label Usage
  # @param variant [Symbol] select "Visual style" { choices: [primary, primary_outline, secondary, soft, outline, ghost, destructive, light] }
  # @param size [Symbol] select "Height, padding and text size" { choices: [sm, md, lg] }
  # @param label text "Button text"
  def default(variant: :primary, size: :md, label: "Button")
    phlex do
      Button(variant:, size:) { label }
    end
  end

  def variants
    phlex do
      div(class: "flex flex-wrap gap-3") do
        (UI::Button::VARIANTS.keys - [ :light ]).each do |variant|
          Button(variant:) { variant.to_s.humanize }
        end
      end
    end
  end

  # @!group Sizes
  #
  # `size:` scales height, padding, radius and icon size.
  def sizes
    phlex do
      div(class: "flex flex-wrap items-center gap-3") do
        [ :sm, :md, :lg ].each { |size| Button(size:) { size.to_s.upcase } }
      end
    end
  end

  # `icon: true` makes a square button; give it an `aria_label:`.
  #
  # @label Icon buttons
  def icon
    phlex do
      div(class: "flex flex-wrap items-center gap-3") do
        [ :sm, :md, :lg ].each do |size|
          Button(variant: :soft, size:, icon: true, aria_label: "Bookmark") do
            svg(viewBox: "0 0 24 24", fill: "none", stroke: "currentColor", stroke_width: "1.5", stroke_linecap: "round", stroke_linejoin: "round", aria_hidden: "true") do |s|
              s.path(d: "M6 4h12v16l-6-4-6 4z")
            end
          end
        end
      end
    end
  end
  # @!endgroup
end
