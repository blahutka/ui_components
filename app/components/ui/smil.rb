# Attributes for SVG SMIL <animate> / <animateTransform> elements, which loop without any
# JavaScript. Shared by Spinner and Loader.
#
#   s.animate(**smil(attribute: "opacity", values: "0;1;0", dur: "1.2s", start: "-0.3s"))
module UI::Smil
  EASE_IN_OUT_QUAD = "0.455 0.03 0.515 0.955".freeze
  LINEAR = "0 0 1 1".freeze

  # Swap the animated frame for a static one under prefers-reduced-motion (SMIL ignores it)
  ANIMATED = "motion-reduce:hidden".freeze
  STATIC = "hidden motion-reduce:inline".freeze

  private
    # SMIL attributes are camelCase, so they go in as string keys (Phlex keeps those verbatim).
    # `splines:` holds one cubic-bezier per segment and switches to calcMode="spline".
    def smil(attribute:, values:, dur:, key_times: nil, start: nil, splines: nil)
      {
        "attributeName" => attribute, "values" => values, "dur" => dur, "repeatCount" => "indefinite",
        "keyTimes" => key_times, "begin" => start,
        "calcMode" => (splines ? "spline" : "linear"), "keySplines" => splines&.join(";")
      }.compact
    end

    def seconds(value)
      "#{value.round(3)}s"
    end
end
