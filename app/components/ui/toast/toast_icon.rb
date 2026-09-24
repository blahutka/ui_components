# The leading glyph of a toast: success, error, warning, info, loading (a spinner) or bell.
# `thumbnail: true` wraps it in a tinted badge for more prominence.
class UI::ToastIcon < UI::Base
  KINDS = %i[ success error warning info loading bell ].freeze

  COLORS = {
    success: "text-success-emphasis", error: "text-error-emphasis", warning: "text-warning-emphasis",
    info: "text-info-emphasis", loading: "text-foreground-muted", bell: "text-foreground-intense"
  }.freeze

  THUMBNAILS = {
    success: "bg-success-subtle text-success-emphasis", error: "bg-error-subtle text-error-emphasis",
    warning: "bg-warning-subtle text-warning-emphasis", info: "bg-info-subtle text-info-emphasis",
    loading: "bg-background-muted text-foreground-intense", bell: "bg-background-muted text-foreground-intense"
  }.freeze

  # The mark drawn on top of the circle / triangle
  MARKS = {
    success: "M8 12.5l2.75 2.75L16.25 9.5",
    error: "M9.25 9.25l5.5 5.5M14.75 9.25l-5.5 5.5",
    warning: "M12 7.75v5M12 16.25v.01",
    info: "M12 11v5M12 7.75v.01"
  }.freeze

  def initialize(kind:, thumbnail: false)
    @kind = KINDS.include?(kind.to_sym) ? kind.to_sym : :info
    @thumbnail = thumbnail
  end

  def view_template
    if @thumbnail
      span(class: cn("flex size-8 shrink-0 items-center justify-center rounded-md [&>svg]:size-4.5", THUMBNAILS[@kind]), data: { slot: "toast-thumbnail" }) { glyph(outlined: true) }
    else
      glyph
    end
  end

  private
    # Filled circle glyphs for the plain icon; outlined strokes inside a thumbnail
    def glyph(outlined: false)
      case @kind
      when :loading
        svg(viewBox: "0 0 24 24", fill: "none", aria_hidden: "true", class: cn("animate-spin motion-reduce:animate-none", (COLORS[@kind] unless outlined))) do |s|
          s.circle(cx: "12", cy: "12", r: "9", stroke: "currentColor", stroke_opacity: "0.25", stroke_width: "2.5")
          s.path(d: "M21 12a9 9 0 0 0-9-9", stroke: "currentColor", stroke_width: "2.5", stroke_linecap: "round")
        end
      when :bell
        svg(viewBox: "0 0 24 24", fill: "none", stroke: "currentColor", stroke_width: "1.75", stroke_linecap: "round", stroke_linejoin: "round", aria_hidden: "true", class: (COLORS[@kind] unless outlined)) do |s|
          s.path(d: "M6 16v-5a6 6 0 1 1 12 0v5l1.5 2h-15zM10 20.5a2 2 0 0 0 4 0")
        end
      else
        outlined ? outlined_glyph : filled_glyph
      end
    end

    def filled_glyph
      svg(viewBox: "0 0 24 24", aria_hidden: "true", class: COLORS[@kind]) do |s|
        if @kind == :warning
          s.path(d: "M10.3 3.9 2.4 17.6A2 2 0 0 0 4.1 20.6h15.8a2 2 0 0 0 1.7-3L13.7 3.9a2 2 0 0 0-3.4 0z", fill: "currentColor")
        else
          s.circle(cx: "12", cy: "12", r: "9.75", fill: "currentColor")
        end
        s.path(d: MARKS[@kind], fill: "none", stroke_width: "2", stroke_linecap: "round", stroke_linejoin: "round", class: "stroke-background")
      end
    end

    def outlined_glyph
      svg(viewBox: "0 0 24 24", fill: "none", stroke: "currentColor", stroke_width: "1.75", stroke_linecap: "round", stroke_linejoin: "round", aria_hidden: "true") do |s|
        if @kind == :warning
          s.path(d: "M10.3 3.9 2.4 17.6A2 2 0 0 0 4.1 20.6h15.8a2 2 0 0 0 1.7-3L13.7 3.9a2 2 0 0 0-3.4 0z")
        else
          s.circle(cx: "12", cy: "12", r: "9.25")
        end
        s.path(d: MARKS[@kind])
      end
    end
end
