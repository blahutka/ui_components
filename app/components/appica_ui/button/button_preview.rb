# Appica's Button: the trigger and action element used by Drawer, Dialog, …
# Renders an <a> when given `href:`.
#
# @label Button
# @logical_path Actions & Inputs
# @component AppicaUI::Button
# @display width wide
class AppicaUI::ButtonPreview < AppicaUI::BasePreview
  # Props not in the Usage form (data, render blocks, generated ids): see ui_components:preview_params
  UNLISTED_PROPS = %i[ icon ].freeze

  # @label Usage
  # @param variant [Symbol] select "Visual style" {{ choices_for AppicaUI::Button, :variant }}
  # @param size [Symbol] select "Height, padding and text size" {{ choices_for AppicaUI::Button, :size }}
  # @param label text "Button text"
  def default(variant: :primary, size: :md, label: "Button")
    phlex do
      Button(variant:, size:) { label }
    end
  end

  def variants
    phlex do
      div(class: "flex flex-wrap gap-3") do
        (AppicaUI::Button::VARIANTS.keys - [ :light ]).each do |variant|
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
            Icon(:bookmark)
          end
        end
      end
    end
  end
  # @!endgroup
end
