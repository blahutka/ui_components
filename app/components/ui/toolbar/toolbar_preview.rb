# A strip of controls with one tab stop - the arrow keys move between items.
#
# @label Toolbar
# @logical_path Actions & Inputs
# @component UI::Toolbar
# @display width wide
# @display min_height 280px
class UI::ToolbarPreview < UI::BasePreview
  # @label Usage
  # A search Input, a Filter action and an Export link, all in one focus stop.
  def default
    phlex do
      Toolbar(aria_label: "Table actions") do
        ToolbarInput(class: "w-44") { |item| Input(**item, start_slot: :search, placeholder: "Search tasks…", aria_label: "Search tasks", size: :sm) }
        ToolbarGroup(aria_label: "Refine") do
          ToolbarButton { |item| Button(**item, variant: :ghost, size: :sm) { Icon(:filter, data: { icon: "start" }); plain "Filter" } }
        end
        ToolbarSeparator()
        ToolbarLink(href: "#export", class: cn(UI::Button::BASE, UI::Button::VARIANTS[:ghost], UI::Button::SIZES[:sm])) do
          Icon(:download, data: { icon: "start" })
          plain "Export"
        end
      end
    end
  end

  # @label With a toggle group
  # Undo / redo, a font Select and an alignment ToggleGroup - each item hands its attributes to
  # the control it wraps.
  def with_toggle_group
    phlex do
      Toolbar(aria_label: "Text formatting") do
        ToolbarGroup(aria_label: "History") do
          ToolbarButton { |item| Button(**item, variant: :ghost, icon: true, aria_label: "Undo") { Icon(:arrow_back_up) } }
          ToolbarButton { |item| Button(**item, variant: :ghost, icon: true, aria_label: "Redo") { Icon(:arrow_forward_up) } }
        end
        ToolbarSeparator()
        Select(default_value: "Inter", align_item_with_trigger: false, class: "w-36") do
          ToolbarButton { |item| SelectTrigger(**item, start_slot: :typography, aria_label: "Font") { SelectValue() } }
          SelectContent { %w[ Geist Inter Figtree Urbanist ].each { |font| SelectItem(value: font) { font } } }
        end
        ToolbarSeparator()
        ToggleGroup(default_value: [ "left" ], aria_label: "Alignment") do
          { left: "Align left", center: "Align center", right: "Align right" }.each do |value, text|
            ToolbarButton do |item|
              Toggle(**item, value:, aria_label: text) { |toggle| Button(**toggle, variant: :ghost, icon: true) { Icon(:"align_#{value}") } }
            end
          end
        end
      end
    end
  end

  # @label Vertical orientation
  # The separator turns horizontal and ↑/↓ move focus.
  def vertical
    phlex do
      Toolbar(aria_label: "Formatting", orientation: :vertical) do
        ToolbarGroup(aria_label: "Text style") do
          %i[ bold italic underline ].each { |icon| ToolbarButton { |item| Button(**item, variant: :ghost, icon: true, aria_label: icon.to_s.capitalize) { Icon(icon) } } }
        end
        ToolbarSeparator()
        ToolbarGroup(aria_label: "Clipboard") do
          ToolbarButton { |item| Button(**item, variant: :ghost, icon: true, aria_label: "Copy") { Icon(:copy) } }
          ToolbarButton { |item| Button(**item, variant: :ghost, icon: true, aria_label: "Cut") { Icon(:scissors) } }
        end
      end
    end
  end

  # @label RTL
  # ←/→ follow the reading direction.
  def rtl
    phlex do
      Toolbar(dir: "rtl", aria_label: "تنسيق") do
        %w[ عريض مائل مسطر ].each { |text| ToolbarButton { |item| Button(**item, variant: :ghost, size: :sm) { text } } }
        ToolbarSeparator()
        ToolbarLink(href: "#help", class: cn(UI::Button::BASE, UI::Button::VARIANTS[:ghost], UI::Button::SIZES[:sm])) { "مساعدة" }
      end
    end
  end
end
