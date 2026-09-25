# One of the ~5,000 Appica icons (https://appica.dev/ui/icons), by its canonical name.
#
#   Icon(:star)                                              # outline, 24px, 1.5 stroke
#   Icon(:star_filled, size: 20, class: "text-warning-emphasis")
#   Icon("arrow-back-up", stroke_width: 2, aria_label: "Undo")   # labelled => role="img"
#   Button { Icon(:download, data: { icon: "start" }); plain "Export" }
#
# Names are the catalog's kebab-case names; symbols with underscores and the React PascalCase
# names work too (:arrow_back_up, "ArrowBackUp"). Filled icons end in -filled. Icons are
# decorative (aria-hidden) unless given an aria_label.
class UI::Icon < UI::Base
  param :name
  prop :size,         default: -> { 24 }
  prop :stroke_width, default: -> { nil }
  prop :color,        default: -> { nil }

  def view_template
    content = icon[:content]

    svg(**mix(defaults(**svg_attributes), @attributes.except(:class)), class: cn("appica-icon", override: @attributes[:class])) do |s|
      s.raw(s.safe(content))
    end
  end

  private
    def icon
      @icon ||= UI::IconLibrary.fetch(@name)
    end

    def svg_attributes
      labelled = @attributes.key?(:aria_label)
      attrs = icon[:attrs]

      {
        xmlns: "http://www.w3.org/2000/svg", viewBox: icon[:view_box], width: @size, height: @size,
        **attrs, stroke_width: (@stroke_width || attrs[:stroke_width] if attrs[:stroke]),
        color: @color, aria_hidden: ("true" unless labelled), role: ("img" if labelled),
        data: { slot: "icon", name: icon[:name] }
      }
    end
end
