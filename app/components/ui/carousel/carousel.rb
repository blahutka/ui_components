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

  attr_reader :id, :orientation

  def initialize(orientation: :horizontal, loop: false, align: :start, slides_to_scroll: 1, contain_scroll: :trim_snaps,
                 drag_free: false, start_snap: nil, active: true, draggable: true, duration: nil, options: {},
                 autoplay: false, auto_scroll: false, auto_height: false, fade: false, wheel_gestures: false,
                 effect: nil, sync_with: nil, light: false, **attributes)
    @orientation = ORIENTATIONS.include?(orientation.to_sym) ? orientation.to_sym : :horizontal
    @embla = {
      axis: (vertical? ? "y" : "x"),
      loop:,
      align: align.to_s,
      slidesToScroll: (slides_to_scroll.to_s == "auto" ? "auto" : slides_to_scroll.to_i),
      containScroll: (contain_scroll ? CONTAIN_SCROLL.fetch(contain_scroll.to_sym, "trimSnaps") : false),
      dragFree: drag_free,
      startIndex: start_snap,
      active:,
      watchDrag: draggable,
      duration:
    }.compact.merge(options)
    @plugins = { autoplay:, autoScroll: auto_scroll, autoHeight: auto_height, fade:, wheelGestures: wheel_gestures }
    @effect, @sync_with, @light = effect, sync_with, light
    @label = attributes.delete(:aria_label) || "Carousel"
    @attributes = attributes
    @id = attributes.delete(:id) || "carousel-#{SecureRandom.hex(4)}"
  end

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

    def config
      {
        options: @embla,
        plugins: @plugins.transform_values { |value| plugin_options(value) },
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
