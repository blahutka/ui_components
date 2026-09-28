# A scroll / autoplay progress indicator: a bar (default) or a ring (`variant: :circular`).
# `source: :auto` counts down the autoplay timer while it plays, otherwise tracks scrolling.
class AppicaUI::CarouselProgress < AppicaUI::Base
  SOURCES = %i[ auto autoplay scroll ].freeze

  prop :variant,     one_of(%i[ bar circular ], :bar), default: -> { :bar }
  prop :source,      one_of(SOURCES, :auto), default: -> { :auto }
  prop :orientation, one_of(%i[ horizontal vertical ], :horizontal), default: -> { :horizontal }
  prop :light,       default: -> { nil }

  def view_template
    if @variant == :circular
      circular
    else
      bar
    end
  end

  private
    def bar
      axis = @orientation == :vertical ? "w-1.5 h-full" : "h-1.5 w-full"
      track = light? ? "bg-white/25" : "bg-border-strong"
      fill = light? ? "bg-white" : "bg-primary"

      div(**mix(progress_attributes, @attributes.except(:class)), class: cn("relative overflow-hidden rounded-full", axis, track, override: @attributes[:class])) do
        span(aria_hidden: "true", class: cn("block rounded-full", @orientation == :vertical ? "w-full" : "h-full", fill),
             style: "#{@orientation == :vertical ? "height" : "width"}: 0%",
             data: { slot: "carousel-progress-indicator", orientation: @orientation, "appica-ui--carousel-target": "progressIndicator" })
      end
    end

    # A 24px ring; the indicator's stroke-dashoffset is driven from 100 (empty) to 0 (full)
    def circular
      track = light? ? "stroke-white/25" : "stroke-border-strong"
      fill = light? ? "stroke-white" : "stroke-primary"

      div(**mix(progress_attributes, @attributes.except(:class)), class: cn("relative size-6", override: @attributes[:class])) do
        svg(viewBox: "0 0 24 24", fill: "none", aria_hidden: "true", class: "size-full -rotate-90 rtl:scale-x-[-1]") do |s|
          s.circle(cx: "12", cy: "12", r: "10", stroke_width: "2.5", class: track)
          s.circle(cx: "12", cy: "12", r: "10", stroke_width: "2.5", stroke_linecap: "round", pathLength: "100",
                   stroke_dasharray: "100", stroke_dashoffset: "100", class: fill,
                   data: { slot: "carousel-progress-indicator", "appica-ui--carousel-target": "progressIndicator" })
        end
      end
    end

    def progress_attributes
      {
        data: {
          slot: "carousel-progress",
          variant: @variant,
          orientation: @orientation,
          source: @source,
          "appica-ui--carousel-target": "progress"
        }
      }
    end

    def light?
      @light.nil? ? context[:ui_carousel]&.light? : @light
    end
end
