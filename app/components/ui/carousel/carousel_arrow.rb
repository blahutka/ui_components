# Shared by CarouselPrev and CarouselNext: a positioner plus a button. A block taking an
# argument receives the button attributes, so you can render your own Button (Appica's
# `render` prop); without one it renders an unstyled button with a chevron.
#
#   CarouselNext(position: :outside) { |nxt| Button(**nxt, variant: :outline, icon: true) { chevron } }
class UI::CarouselArrow < UI::Base
  POSITIONS = %i[ inside outside outside_half none ].freeze

  def initialize(position: :inside, disabled: false, **attributes)
    @position = POSITIONS.include?(position.to_sym) ? position.to_sym : :inside
    @disabled = disabled
    @label = attributes.delete(:aria_label)
    @attributes = attributes
  end

  def before_template(&content)
    @render_prop = content&.arity == 1
    super
  end

  def view_template
    div(class: cn(positioner_classes, override: @attributes[:class]), data: { slot: "carousel-#{direction}-positioner", orientation: carousel.orientation }) do
      if @render_prop
        yield button_attributes
      elsif block_given?
        button(**button_attributes) { yield }
      else
        button(**button_attributes) { chevron }
      end
    end
  end

  private
    def carousel = consume(:ui_carousel, component: "Carousel")

    def positioner_classes
      self.class::POSITIONER[@position]
    end

    def button_attributes
      mix({
        type: "button",
        disabled: (true if @disabled),
        aria: { label: @label || label },
        data: {
          slot: "carousel-#{direction}",
          direction:,
          "ui--carousel-target": direction,
          action: "ui--carousel##{direction}",
          force_disabled: (@disabled ? "" : nil)
        }
      }, @attributes.except(:class))
    end

    def chevron
      render UI::Icon.new(chevron_icon, class: (carousel.vertical? ? "rotate-90" : "rtl:rotate-180"))
    end
end
