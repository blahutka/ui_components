# A compact pill for tags, attributes, filters and removable tokens, in Button's palette.
#
#   Chip { "Design" }
#   Chip(variant: :primary, size: :sm) { Icon(:circle_check, data: { icon: "start" }); plain "Verified" }
#   Chip(dismissible: true, close_label: "Remove React") { "React" }
#   Chip(href: "/tags/design") { "#design" }
#
# It's a <button> (an <a> with `href:`). `dismissible: true` adds a ✕: clicking the chip plays an
# exit animation, removes it and emits `ui--chip:dismiss` (cancel it to keep the chip - e.g. to
# remove it with a Turbo Stream instead). Inside a ChipGroup it takes the group's variant and size.
class UI::Chip < UI::Base
  VARIANTS = UI::Button::VARIANTS.slice(:soft, :outline, :primary, :secondary, :destructive)

  SIZES = {
    sm: "h-6 gap-0.75 rounded-xs px-2 text-xs has-data-[icon=end]:pe-1.5 has-data-[icon=start]:ps-1.5 [&_svg:not([class*='size-'])]:size-3.5",
    md: "h-8 gap-1 rounded-sm px-3 text-sm has-data-[icon=end]:pe-2 has-data-[icon=start]:ps-2 [&_svg:not([class*='size-'])]:size-4",
    lg: "h-10 gap-1.25 rounded-md px-3.5 text-base has-data-[icon=end]:pe-2.5 has-data-[icon=start]:ps-2.5 [&_svg:not([class*='size-'])]:size-4.5"
  }.freeze

  WRAPPER = "inline-flex align-middle transition-[opacity,scale,filter] duration-200 ease-out " \
    "data-ending-style:scale-75 data-ending-style:opacity-0 data-ending-style:blur-xs motion-reduce:data-ending-style:scale-100 motion-reduce:data-ending-style:blur-none"
  CLOSE_ICON = "M11.523 3.522c.264-.264.691-.264.955 0s.264.691 0 .955L8.955 8l3.522 3.522c.264.264.264.691 0 .955s-.691.264-.955 0L8 8.955l-3.522 3.522c-.264.264-.691.264-.955 0s-.264-.691 0-.955L7.045 8 3.522 4.478c-.264-.264-.264-.691 0-.955s.691-.264.955 0L8 7.045l3.523-3.522z"

  prop :variant,     one_of(VARIANTS, :soft), default: -> { nil }
  prop :size,        one_of(SIZES, :md), default: -> { nil }
  prop :dismissible, default: -> { false }
  prop :close_label, default: -> { t(".dismiss") }
  prop :disabled,    default: -> { false }

  def view_template(&)
    if @dismissible
      span(class: WRAPPER, data: { slot: "chip-wrapper", controller: "ui--chip" }) { chip(&) }
    else
      chip(&)
    end
  end

  private
    def chip(&)
      attributes = mix({
        data: {
          slot: "chip", variant:, size:, dismissible: ("true" if @dismissible), disabled: ("" if @disabled),
          action: ("ui--chip#dismiss" if @dismissible)
        }
      }, @attributes.except(:class))
      classes = cn(UI::Button::BASE, VARIANTS[variant], SIZES[size], ("group/chip" if @dismissible), override: @attributes[:class])

      if attributes[:href]
        a(**attributes, aria_disabled: ("true" if @disabled), class: classes) { content(&) }
      else
        button(**{ type: "button", disabled: (true if @disabled) }.merge(attributes), class: classes) { content(&) }
      end
    end

    def content
      yield if block_given?
      return unless @dismissible

      svg(xmlns: "http://www.w3.org/2000/svg", viewBox: "0 0 16 16", fill: "currentColor", aria_hidden: "true",
        data: { slot: "chip-close-icon", icon: "end" },
        class: "size-3.5 opacity-60 transition-opacity duration-200 group-hover/chip:opacity-100 motion-reduce:transition-none") { |s| s.path(d: CLOSE_ICON) }
      span(class: "sr-only") { @close_label }
    end

    def variant
      @variant || group&.variant || :soft
    end

    def size
      @size || group&.size || :md
    end

    def group
      context[:ui_chip_group]
    end
end
