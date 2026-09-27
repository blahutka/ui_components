# A short, non-interactive hint for a control, shown on hover or focus.
#
# @label Tooltip
# @logical_path Overlays
# @component UI::Tooltip
# @display width wide
# @display min_height 200px
class UI::TooltipPreview < UI::BasePreview
  # Props not in the Usage form (data, render blocks, generated ids): see ui_components:preview_params
  UNLISTED_PROPS = %i[ id delay close_delay ].freeze

  # @label Usage
  # @param side [Symbol] select { choices: [top, bottom, left, right] }
  # @param arrow [Boolean] toggle
  # @param default_open [Boolean] toggle
  # @param track_cursor_axis [Symbol] select {{ choices_for UI::Tooltip, :track_cursor_axis }}
  # @param disabled [Boolean] toggle
  def default(side: :top, arrow: true, default_open: false, track_cursor_axis: :none, disabled: false)
    phlex do
      TooltipProvider do
        Tooltip(default_open:, track_cursor_axis:, disabled:) do
          TooltipTrigger { |trigger| Button(**trigger, variant: :outline, icon: true, aria_label: "Add to favorites") { Icon(:heart) } }
          TooltipContent(side:, arrow:) { "Add to favorites" }
        end
      end
    end
  end

  # @label Side & alignment
  def sides
    phlex do
      TooltipProvider do
        div(class: "flex flex-wrap items-center justify-center gap-3") do
          %i[ top right bottom left ].each do |side|
            Tooltip do
              TooltipTrigger { |trigger| Button(**trigger, variant: :outline) { side.to_s } }
              TooltipContent(side:) { "Opens on the #{side}" }
            end
          end
        end
      end
    end
  end

  # @label Shared provider
  # The first tooltip waits out the delay; sweeping to a neighbour shows it at once.
  def provider
    actions = { bold: "Bold", italic: "Italic", underline: "Underline", strikethrough: "Strikethrough", link: "Link" }
    phlex do
      TooltipProvider(delay: 400) do
        Toolbar(aria_label: "Text formatting") do
          actions.each_with_index do |(icon, label), index|
            ToolbarSeparator() if index == actions.size - 1
            Tooltip do
              TooltipTrigger do |trigger|
                ToolbarButton(**trigger) { |item| Button(**item, variant: :ghost, icon: true, aria_label: label) { Icon(icon) } }
              end
              TooltipContent { label }
            end
          end
        end
      end
    end
  end

  # @label Rich content
  def rich
    phlex do
      TooltipProvider do
        Tooltip do
          TooltipTrigger { |trigger| Button(**trigger, variant: :outline, icon: true, aria_label: "Save") { Icon(:bookmark) } }
          TooltipContent(class: "flex items-center gap-2") { plain "Save"; Kbd(size: :sm) { "⌘ S" } }
        end
      end
    end
  end

  # @label Follow the cursor
  # `track_cursor_axis: :x` keeps the bubble over the pointer.
  def follow
    phlex do
      TooltipProvider do
        Tooltip(track_cursor_axis: :x) do
          TooltipTrigger(class: "bg-background-subtle border-border-strong flex h-32 w-72 items-center justify-center rounded-xl border border-dashed text-sm select-none") { "Hover and move across" }
          TooltipContent { "Following the cursor" }
        end
      end
    end
  end

  # @label RTL
  def rtl
    phlex do
      div(dir: "rtl") do
        TooltipProvider do
          Tooltip do
            TooltipTrigger { |trigger| Button(**trigger, variant: :outline) { "حفظ" } }
            TooltipContent(side: :inline_end) { "احفظ التغييرات" }
          end
        end
      end
    end
  end
end
