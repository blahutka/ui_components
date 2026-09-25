# Clickable bullets, one per snap point. The count is only known once the engine has
# measured the slides, so the bullets are cloned in the browser from the <template>
# rendered here. While autoplay runs, the active bullet grows into a filling pill.
class UI::CarouselPagination < UI::Base
  BULLET = "relative cursor-pointer overflow-hidden rounded-full outline-offset-1 motion-safe:transition-[width,height,background-color] motion-safe:duration-300"

  AXES = {
    horizontal: "h-1.5 w-1.5 data-active:w-5 in-data-autoplay:data-active:w-8",
    vertical: "w-1.5 h-1.5 data-active:h-5 in-data-autoplay:data-active:h-8"
  }.freeze

  TONES = {
    default: "outline-ring bg-border-strong data-active:bg-primary in-data-autoplay:data-active:bg-border-strong",
    light: "outline-ring-light bg-white/25 data-active:bg-white in-data-autoplay:data-active:bg-white/25"
  }.freeze

  FILL = {
    default: "absolute start-0 top-0 hidden rounded-full bg-primary in-data-autoplay:in-data-active:block",
    light: "absolute start-0 top-0 hidden rounded-full bg-white in-data-autoplay:in-data-active:block"
  }.freeze

  prop :orientation, one_of(%i[ horizontal vertical ], :horizontal), default: -> { :horizontal }
  prop :light,       default: -> { nil }

  def view_template
    div(**mix({
      role: "group",
      aria: { label: "Choose slide to display" },
      data: { slot: "carousel-pagination", orientation: @orientation, "ui--carousel-target": "pagination" }
    }, @attributes.except(:class)), class: cn("flex gap-2 data-[orientation=vertical]:flex-col", override: @attributes[:class])) do
      template(data: { "ui--carousel-target": "bulletTemplate" }) do
        button(type: "button", class: cn(BULLET, AXES[@orientation], TONES[tone]), data: { slot: "carousel-pagination-bullet", orientation: @orientation }) do
          span(class: cn(FILL[tone], @orientation == :vertical ? "w-full" : "h-full"), data: { slot: "carousel-pagination-fill" })
        end
      end
    end
  end

  private
    def tone
      light = @light.nil? ? context[:ui_carousel]&.light? : @light
      light ? :light : :default
    end
end
