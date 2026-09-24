# A small spinning indicator for compact, in-place waits (a button, an icon button, an overlay).
#
#   Spinner()
#   Spinner(variant: :dots, current_color: true, class: "text-[1.2em]")
#
# Sized by font-size - set a text-* class, or inherit 1em. `current_color: true` takes the
# surrounding text color instead of the primary accent. The shapes animate with SVG SMIL (no
# JavaScript); under prefers-reduced-motion a static frame is shown instead.
class UI::Spinner < UI::Base
  include UI::Smil

  VARIANTS = %i[ circular dots sparkle ].freeze

  COLORS = {
    accent: { indicator: "text-primary", track: "text-primary-soft" },
    current: { indicator: "text-current", track: "text-current/20" }
  }.freeze

  # Appica's four-point star, and the rounded octagon it morphs through (same command
  # structure, so SMIL can interpolate between them)
  STAR = "M12.846 3.581C12.711 3.231 12.375 3 12 3C11.625 3 11.278 3.263 11.154 3.581C10.604 5.011 10.054 6.442 9.504 7.872C8.752 8.16 8.159 8.752 7.871 9.504C6.441 10.054 5.011 10.604 3.581 11.154C3.41 11.22 3.263 11.336 3.159 11.487C3.055 11.638 3 11.817 3 12C3 12.183 3.056 12.362 3.159 12.513C3.262 12.664 3.41 12.78 3.581 12.846C5.011 13.396 6.442 13.946 7.872 14.496C8.16 15.248 8.752 15.841 9.504 16.129C10.054 17.559 10.604 18.989 11.154 20.419C11.22 20.59 11.336 20.737 11.487 20.841C11.638 20.945 11.817 21 12 21C12.183 21 12.362 20.945 12.513 20.841C12.664 20.737 12.78 20.59 12.846 20.419C13.396 18.989 13.946 17.559 14.496 16.129C15.248 15.841 15.841 15.248 16.129 14.496C17.559 13.946 18.989 13.396 20.419 12.846C20.59 12.78 20.737 12.664 20.841 12.513C20.945 12.362 21 12.183 21 12C21 11.817 20.945 11.638 20.841 11.487C20.737 11.336 20.59 11.22 20.419 11.154C18.989 10.604 17.559 10.054 16.129 9.504C15.841 8.752 15.248 8.16 14.496 7.871C13.946 6.441 13.396 5.011 12.846 3.581Z".freeze
  OCTAGON = "M12.704 5C12.469 5 12.235 5 12 5C11.765 5 11.531 5 11.296 5C10.161 5.053 9.025 5.106 7.889 5.159C6.979 6.069 6.069 6.979 5.159 7.889C5.106 9.025 5.053 10.161 5 11.296C5 11.395 5 11.494 5 11.593C5 11.729 5 11.864 5 12C5 12.136 5 12.271 5 12.407C5 12.506 5 12.605 5 12.704C5.053 13.839 5.106 14.975 5.159 16.111C6.069 17.021 6.979 17.931 7.889 18.841C9.025 18.894 10.161 18.947 11.296 19C11.395 19 11.494 19 11.593 19C11.729 19 11.864 19 12 19C12.136 19 12.271 19 12.407 19C12.506 19 12.605 19 12.704 19C13.839 18.947 14.975 18.894 16.111 18.841C17.021 17.931 17.931 17.021 18.841 16.111C18.894 14.975 18.947 13.839 19 12.704C19 12.605 19 12.506 19 12.407C19 12.271 19 12.136 19 12C19 11.864 19 11.729 19 11.593C19 11.494 19 11.395 19 11.296C18.947 10.161 18.894 9.025 18.841 7.889C17.931 6.979 17.021 6.069 16.111 5.159C14.975 5.106 13.839 5.053 12.704 5Z".freeze

  def initialize(variant: :circular, current_color: false, **attributes)
    @variant = VARIANTS.include?(variant.to_sym) ? variant.to_sym : :circular
    @colors = COLORS[current_color ? :current : :accent]
    @attributes = attributes
  end

  def view_template
    span(**mix(defaults(role: "status", aria_label: "Loading", data: { slot: "spinner", variant: @variant }), @attributes.except(:class)),
      class: cn("inline-flex shrink-0 items-center justify-center align-middle text-[2.5rem]", override: @attributes[:class])) do
      send(@variant)
    end
  end

  private
    def circular
      svg(width: "1em", height: "1em", viewBox: "0 0 40 40", fill: "none", stroke: "currentColor", stroke_width: "4", stroke_linecap: "round", aria_hidden: "true", class: cn("size-[1em] stroke-4!", @colors[:indicator])) do |s|
        s.circle(cx: "20", cy: "20", r: "16", class: @colors[:track])
        s.circle(cx: "20", cy: "20", r: "16", pathLength: "1", stroke_dasharray: "0.25 0.75", class: ANIMATED) do
          s.animate(**smil(attribute: "stroke-dashoffset", values: "0;-1", dur: "0.9s"))
        end
        s.circle(cx: "20", cy: "20", r: "16", pathLength: "1", stroke_dasharray: "0.25 0.75", class: STATIC)
      end
    end

    # Twelve ticks around the clock, each fading in turn
    def dots
      svg(width: "1em", height: "1em", viewBox: "0 0 40 40", fill: "currentColor", aria_hidden: "true", class: cn("size-[1em]", @colors[:indicator])) do |s|
        s.g(class: ANIMATED) do
          12.times do |index|
            s.rect(**tick(index), opacity: "0") do
              s.animate(**smil(attribute: "opacity", values: "0;1;0.5;0", key_times: "0;0.1;0.5;1", dur: "1.2s", start: seconds(index / 12.0 * 1.2 - 1.2)))
            end
          end
        end
        s.g(class: STATIC) { 12.times { |index| s.rect(**tick(index), opacity: "0.25") } }
      end
    end

    # The star softens into an octagon and back while making a full turn, then rests
    def sparkle
      svg(width: "1em", height: "1em", viewBox: "0 0 24 24", fill: "none", stroke: "currentColor", stroke_width: "2", stroke_linejoin: "round", stroke_linecap: "round", aria_hidden: "true", class: cn("size-[1em]", @colors[:indicator])) do |s|
        s.path(d: STAR, class: ANIMATED) do
          s.animate(**smil(attribute: "d", values: [ STAR, OCTAGON, STAR, STAR ].join(";"), key_times: "0;0.2;0.4;1", dur: "2.5s",
            splines: [ EASE_IN_OUT_QUAD, EASE_IN_OUT_QUAD, LINEAR ]))
          s.animateTransform(**smil(attribute: "transform", values: "0 12 12;360 12 12;360 12 12", key_times: "0;0.4;1", dur: "2.5s",
            splines: [ EASE_IN_OUT_QUAD, LINEAR ]), type: "rotate")
        end
        s.path(d: STAR, class: STATIC)
      end
    end

    def tick(index)
      { x: "18", y: "2", width: "4", height: "6", rx: "2", transform: "rotate(#{index * 30} 20 20)" }
    end
end
