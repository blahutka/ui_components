# A draggable, swipeable slider built on Embla Carousel, with autoplay, fade,
# auto-height, thumbnails and scroll effects.
#
#   Carousel(loop: true) do
#     CarouselContent do
#       slides.each { |slide| CarouselSlide { img(src: slide.url, alt: slide.title) } }
#     end
#     CarouselPrev { |prev| Button(**prev, variant: :outline, icon: true, class: "rounded-full") { chevron_left } }
#     CarouselNext { |nxt| Button(**nxt, variant: :outline, icon: true, class: "rounded-full") { chevron_right } }
#     CarouselPagination(class: "absolute inset-x-0 top-full mt-5 justify-center")
#   end
#
# Flat options mirror Embla's (`loop:`, `align:`, `slides_to_scroll:`, `drag_free:` …);
# `options:` is a raw Embla options hash merged last. The plugins are switched on with
# `autoplay:`, `auto_scroll:`, `fade:`, `auto_height:` and `wheel_gestures:` (true or a hash).
class UI::Carousel < UI::Base
  ORIENTATIONS = %i[ horizontal vertical ].freeze
  CONTAIN_SCROLL = { trim_snaps: "trimSnaps", keep_snaps: "keepSnaps" }.freeze

  prop :orientation,      one_of(ORIENTATIONS, :horizontal), default: -> { :horizontal }
  prop :loop,             default: -> { false }
  prop :align,            default: -> { :start }
  prop :slides_to_scroll, default: -> { 1 }
  prop :contain_scroll,   default: -> { :trim_snaps }
  prop :drag_free,        default: -> { false }
  prop :start_snap,       default: -> { nil }
  prop :active,           default: -> { true }
  prop :draggable,        default: -> { true }
  prop :duration,         default: -> { nil }
  prop :options,          default: -> { {} }
  prop :autoplay,         default: -> { false }
  prop :auto_scroll,      default: -> { false }
  prop :auto_height,      default: -> { false }
  prop :fade,             default: -> { false }
  prop :wheel_gestures,   default: -> { false }
  prop :effect,           default: -> { nil }
  prop :sync_with,        default: -> { nil }
  prop :light,            default: -> { false }
  prop :aria_label,       as: :label, default: -> { "Carousel" }
  prop :id,               default: -> { "carousel-#{SecureRandom.hex(4)}" }

  attr_reader :id, :orientation

  def view_template(&)
    provide(:ui_carousel, self) do
      div(**mix(root_attributes, @attributes.except(:class)), class: cn("relative", override: @attributes[:class]), &)
    end
  end

  def vertical? = orientation == :vertical
  def light? = @light

  private
    def root_attributes
      {
        id:,
        role: "region",
        aria: { roledescription: "carousel", label: @label },
        data: {
          slot: "carousel",
          orientation:,
          light: (@light ? "" : nil),
          controller: "ui--carousel",
          "ui--carousel-config-value": config.to_json
        }
      }
    end

    # Embla's own option names, from the flat props; `options:` wins
    def embla_options
      {
        axis: (vertical? ? "y" : "x"),
        loop: @loop,
        align: @align.to_s,
        slidesToScroll: (@slides_to_scroll.to_s == "auto" ? "auto" : @slides_to_scroll.to_i),
        containScroll: (@contain_scroll ? CONTAIN_SCROLL.fetch(@contain_scroll.to_sym, "trimSnaps") : false),
        dragFree: @drag_free,
        startIndex: @start_snap,
        active: @active,
        watchDrag: @draggable,
        duration: @duration
      }.compact.merge(@options)
    end

    def plugins
      { autoplay: @autoplay, autoScroll: @auto_scroll, autoHeight: @auto_height, fade: @fade, wheelGestures: @wheel_gestures }
    end

    def config
      {
        options: embla_options,
        plugins: plugins.transform_values { |value| plugin_options(value) },
        effect: @effect&.to_s,
        syncWith: @sync_with
      }
    end

    # true → {}, a hash → camelCased options (resume_after: → resumeAfter:), false → nil
    def plugin_options(value)
      case value
      when true then {}
      when Hash then value.transform_keys { |key| key.to_s.camelize(:lower) }
      end
    end
end
