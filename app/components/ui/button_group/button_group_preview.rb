# Buttons joined into one control, sharing variant, size and disabled state.
#
# @label Button Group
# @logical_path Actions & Inputs
# @component UI::ButtonGroup
# @display width wide
class UI::ButtonGroupPreview < UI::BasePreview
  # @label Usage
  # @param variant [Symbol] select { choices: [primary, primary_outline, secondary, soft, outline, ghost, destructive] }
  # @param size [Symbol] select { choices: [sm, md, lg] }
  # @param orientation [Symbol] select { choices: [horizontal, vertical] }
  # @param disabled [Boolean] toggle
  def default(variant: :outline, size: :md, orientation: :horizontal, disabled: false)
    phlex do
      ButtonGroup(variant:, size:, orientation:, disabled:, aria_label: "Range") do
        Button { "Years" }
        Button { "Months" }
        Button { "Days" }
      end
    end
  end

  # Outlined variants overlap their borders into one hairline; filled ones keep a hairline gap.
  def variants
    phlex do
      div(class: "flex flex-col items-center gap-4") do
        %i[ primary primary_outline secondary soft outline destructive ].each do |variant|
          ButtonGroup(variant:) do
            Button { "Years" }
            Button { "Months" }
            Button { "Days" }
          end
        end
      end
    end
  end

  def sizes
    phlex do
      div(class: "flex flex-col items-center gap-4") do
        %i[ sm md lg ].each do |size|
          ButtonGroup(size:, variant: :outline) do
            Button { "Left" }
            Button { "Center" }
            Button { "Right" }
          end
        end
      end
    end
  end

  # @label Vertical orientation
  def vertical
    phlex do
      ButtonGroup(orientation: :vertical, variant: :outline) do
        Button { "Profile" }
        Button { "Billing" }
        Button { "Settings" }
      end
    end
  end

  # @label Icon buttons
  # `icon: true` on the group makes every button square; label each one.
  def icon_buttons
    phlex do
      ButtonGroup(variant: :outline, icon: true, aria_label: "Text formatting") do
        Button(aria_label: "Bold") { Icon(:bold) }
        Button(aria_label: "Italic") { Icon(:italic) }
        Button(aria_label: "Underline") { Icon(:underline) }
      end
    end
  end

  # @label Split button
  # A primary action joined to a secondary one (a menu trigger once DropdownMenu lands).
  def split
    phlex do
      ButtonGroup(variant: :outline) do
        Button { "Save" }
        Button(icon: true, aria_label: "More save options") { Icon(:chevron_down) }
      end
    end
  end

  # @label RTL
  # The squared corners follow the reading direction.
  def rtl
    phlex do
      ButtonGroup(dir: "rtl", variant: :outline) do
        Button { "سنوات" }
        Button { "أشهر" }
        Button { "أيام" }
      end
    end
  end
end
