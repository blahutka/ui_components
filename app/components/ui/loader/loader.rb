# An indeterminate "working on it" indicator for section- and status-level waits.
#
#   Loader()
#   Loader(variant: :dots, current_color: true, class: "text-3xl")
#
# `variant: :bar` (a track with a sweeping fill) or `:dots` (a flowing trio). Sized by
# font-size like Spinner, and `current_color: true` takes the surrounding text color. Animated
# with SVG SMIL, holding a static frame under prefers-reduced-motion.
class UI::Loader < UI::Base
  include UI::Smil

  VARIANTS = %i[ bar dots ].freeze

  COLORS = {
    accent: { indicator: "text-primary", track: "text-primary-soft" },
    current: { indicator: "text-current", track: "text-current/20" }
  }.freeze

  # The bar's two sweeps: [ x values, width values, easing, start delay ]
  SWEEPS = [
    [ "-15.4;44;44", "15.4;39.6;39.6", "0.65 0.815 0.735 0.395", nil ],
    [ "-88;47.08;47.08", "88;0.44;0.44", "0.165 0.84 0.44 1", "1.15s" ]
  ].freeze

  prop :variant,       one_of(VARIANTS, :bar), default: -> { :bar }
  prop :current_color, default: -> { false }

  def view_template
    span(**mix(defaults(role: "status", aria_label: "Loading", data: { slot: "loader", variant: @variant }), @attributes.except(:class)),
      class: cn("inline-flex shrink-0 items-center justify-center align-middle text-[2.5rem]", override: @attributes[:class])) do
      send(@variant)
    end
  end

  private
    def colors
      COLORS[@current_color ? :current : :accent]
    end

    def bar
      clip_id = "loader-clip-#{SecureRandom.hex(4)}"

      svg(width: "1.4em", height: "0.2em", viewBox: "0 0 44 6", fill: "currentColor", aria_hidden: "true", class: cn("size-[1em] h-[0.2em]! w-[1.4em]!", colors[:indicator])) do |s|
        s.defs { s.clipPath(id: clip_id) { s.rect(x: "0", y: "0", width: "44", height: "6", rx: "3") } }
        s.rect(x: "0", y: "0", width: "44", height: "6", rx: "3", class: colors[:track])
        s.g(clip_path: "url(##{clip_id})", class: ANIMATED) do
          SWEEPS.each do |xs, widths, ease, start|
            s.rect(x: xs.split(";").first, y: "0", width: widths.split(";").first, height: "6", rx: "3") do
              s.animate(**smil(attribute: "x", values: xs, key_times: "0;0.6;1", dur: "2.1s", start:, splines: [ ease, ease ]))
              s.animate(**smil(attribute: "width", values: widths, key_times: "0;0.6;1", dur: "2.1s", start:, splines: [ ease, ease ]))
            end
          end
        end
        s.rect(x: "12", y: "0", width: "20", height: "6", rx: "3", class: STATIC)
      end
    end

    # Three dots grow in from the right, peak in the middle and shrink away on the left
    def dots
      svg(width: "0.8em", height: "0.35em", viewBox: "0 0 28 12", fill: "currentColor", aria_hidden: "true", class: cn("size-[1em] h-[0.35em]! w-[0.8em]!", colors[:indicator])) do |s|
        s.g(class: ANIMATED) do
          3.times do |index|
            start = seconds(-1.6 * (0.85 + index))
            s.circle(cx: "28", cy: "6", r: "0") do
              s.animate(**smil(attribute: "cx", values: "28;28;14;0", key_times: "0;0.01;0.5;1", dur: "2.4s", start:))
              s.animate(**smil(attribute: "r", values: "0;0;6;0", key_times: "0;0.01;0.5;1", dur: "2.4s", start:))
            end
          end
        end
        s.g(class: STATIC) { 3.times { |index| s.circle(cx: (4 + 10 * index).to_s, cy: "6", r: "4") } }
      end
    end
end
