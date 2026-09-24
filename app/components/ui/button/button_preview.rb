# Appica's Button: the trigger and action element used by Drawer, Dialog, …
class UI::ButtonPreview < UI::BasePreview
  # @param variant select { choices: [primary, primary_outline, secondary, soft, outline, ghost, destructive] }
  # @param size select { choices: [sm, md, lg] }
  # @param label text
  def default(variant: :primary, size: :md, label: "Button")
    phlex do
      Button(variant:, size:) { label }
    end
  end

  def variants
    phlex do
      div(class: "flex flex-wrap gap-3") do
        UI::Button::VARIANTS.each_key do |variant|
          Button(variant:) { variant.to_s.humanize }
        end
      end
    end
  end

  def sizes
    phlex do
      div(class: "flex flex-wrap items-center gap-3") do
        [ :sm, :md, :lg ].each { |size| Button(size:) { size.to_s.upcase } }
      end
    end
  end

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
end
