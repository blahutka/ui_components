# A thin horizontal or vertical line between sections of related content.
#
#   Separator()
#   Separator(orientation: :vertical)
#   Separator(variant: :wave, class: "text-primary my-4")
#
# Drawn with currentColor (text-border by default) - recolor it with any text-* class.
# solid, dashed, double and gradient are CSS; dotted, wave and zigzag are a repeating SVG pattern.
class UI::Separator < UI::Base
  BASE = "shrink-0 data-[orientation=horizontal]:w-full data-[orientation=vertical]:self-stretch"

  VARIANTS = {
    solid: "text-border border-current border-solid data-[orientation=horizontal]:border-t data-[orientation=vertical]:border-l",
    dashed: "text-border-strong border-current border-dashed data-[orientation=horizontal]:border-t data-[orientation=vertical]:border-l",
    double: "text-border border-current border-double data-[orientation=horizontal]:border-t-[calc(var(--border-width)*3)] data-[orientation=vertical]:border-l-[calc(var(--border-width)*3)]",
    gradient: "text-border data-[orientation=horizontal]:h-(--border-width) data-[orientation=horizontal]:bg-[linear-gradient(to_right,transparent,currentColor_26%,currentColor_74%,transparent)] " \
      "data-[orientation=vertical]:w-(--border-width) data-[orientation=vertical]:bg-[linear-gradient(to_bottom,transparent,currentColor_26%,currentColor_74%,transparent)]",
    dotted: "text-border-strong",
    wave: "text-border",
    zigzag: "text-border"
  }.freeze

  # The repeating tile of the SVG variants: [ width, path, stroke-width multiplier ]
  PATTERNS = {
    dotted: [ 6, "M3 4 L3 4", 1.75 ],
    wave: [ 16, "M0 4 Q4 1 8 4 T16 4", 1.5 ],
    zigzag: [ 16, "M0 6 L4 2 L8 6 L12 2 L16 6", 1.5 ]
  }.freeze

  prop :orientation, one_of(%i[ horizontal vertical ], :horizontal), default: -> { :horizontal }
  prop :variant,     one_of(VARIANTS, :solid), default: -> { :solid }

  def view_template
    div(**mix(defaults(role: "separator", aria_orientation: @orientation, data: { slot: "separator", orientation: @orientation, variant: @variant }), @attributes.except(:class)),
      class: cn(BASE, VARIANTS[@variant], override: @attributes[:class])) do
      pattern if PATTERNS.key?(@variant)
    end
  end

  private
    def pattern
      width, path, stroke = PATTERNS[@variant]
      id = "separator-#{SecureRandom.hex(4)}"
      vertical = @orientation == :vertical

      svg(aria_hidden: "true", focusable: "false", class: "block", width: (vertical ? "8" : "100%"), height: (vertical ? "100%" : "8")) do |s|
        # A vertical line turns the horizontal tile a quarter (and shifts it back into view)
        s.pattern(id:, width:, height: 8, patternUnits: "userSpaceOnUse", patternTransform: ("rotate(90) translate(0 -8)" if vertical)) do
          s.path(d: path, fill: "none", stroke: "currentColor", stroke_linecap: "round", stroke_linejoin: "round", style: "stroke-width: calc(var(--border-width) * #{stroke})")
        end
        s.rect(width: "100%", height: "100%", fill: "url(##{id})")
      end
    end
end
