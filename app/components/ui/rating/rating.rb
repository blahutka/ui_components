# A score input: a row of stars (or any icon pair) that fills from the start up to the value,
# with fractional steps, a hover preview, keyboard control and a hidden form input.
#
#   Rating(default_value: 3, aria_label: "Rate this product")
#   Rating(value: 4.3, step: 0.1, read_only: true, size: 14, class: "text-warning-emphasis")
#   Rating(icon: :heart, name: "score", clearable: true)
#
# The accent is the text color (text-primary by default). `variant: :filled` draws unrated
# items as muted solid icons, `:outline` as line icons. `read_only: true` renders a single
# labelled image ("4.3 out of 5") without buttons. The `ui--rating` controller handles the
# pointer preview, clicks and arrow keys, and dispatches `ui--rating:change` with { value }.
class UI::Rating < UI::Base
  ROOT = "text-primary relative inline-flex w-fit items-center data-disabled:cursor-not-allowed data-disabled:opacity-disabled " \
    "data-[orientation=vertical]:flex-col data-[orientation=horizontal]:mx-[calc(var(--rating-size)/-6)] data-[orientation=vertical]:my-[calc(var(--rating-size)/-6)]"
  ITEM = "outline-ring rounded-sm relative inline-flex cursor-pointer items-center justify-center disabled:pointer-events-none p-[calc(var(--rating-size)/6)]"

  prop :value,         default: -> { nil }
  prop :default_value, default: -> { 0 }
  prop :count,         ->(value) { value.to_i }, default: -> { 5 }
  prop :step,          ->(value) { value.to_f }, default: -> { 1.0 }
  prop :variant,       one_of(%i[ filled outline ], :filled), default: -> { :filled }
  prop :orientation,   one_of(%i[ horizontal vertical ], :horizontal), default: -> { :horizontal }
  prop :size,          ->(value) { value.is_a?(Numeric) ? "#{value}px" : value.to_s }, default: -> { "24px" }
  prop :icon,          default: -> { :star }
  prop :hoverable,     default: -> { true }
  prop :clearable,     default: -> { false }
  prop :disabled,      default: -> { false }
  prop :read_only,     default: -> { false }
  prop :name,          default: -> { nil }

  def view_template
    div(**mix(defaults(**root_attributes), @attributes.except(:class, :style)), style: "--rating-size: #{@size}; #{@attributes[:style]}".strip,
      class: cn(ROOT, override: @attributes[:class])) do
      1.upto(@count) { |index| @read_only ? static_item(index) : item(index) }
      input(type: "hidden", name: @name, value: format_value(current), data: { "ui--rating-target": "input" }) if @name
    end
  end

  private
    def current
      (@value || @default_value).to_f.clamp(0, @count)
    end

    # Fractional values check the item they fall in (2.5 → the third)
    def checked_index
      current.positive? ? current.ceil : nil
    end

    def root_attributes
      labelled = @attributes.key?(:aria_label) || @attributes.key?(:aria_labelledby)
      data = { slot: "rating", orientation: @orientation, variant: @variant, readonly: ("" if @read_only), disabled: ("" if @disabled) }

      if @read_only
        { role: "img", aria_label: (t(".read_only", value: format_value(current), count: @count) unless labelled), data: }
      else
        {
          role: "radiogroup", aria_orientation: @orientation, aria_label: (t(".label") unless labelled), aria_disabled: ("true" if @disabled),
          data: data.merge(
            controller: "ui--rating", action: "pointermove->ui--rating#preview pointerleave->ui--rating#reset keydown->ui--rating#navigate",
            "ui--rating-value-value": current, "ui--rating-step-value": @step, "ui--rating-count-value": @count,
            "ui--rating-clearable-value": @clearable.to_s, "ui--rating-hoverable-value": @hoverable.to_s
          )
        }
      end
    end

    def item(index)
      checked = index == checked_index
      focusable = checked || (checked_index.nil? && index == 1)

      button(type: "button", role: "radio", aria_checked: checked.to_s, aria_label: t(".item", value: index, count: @count), tabindex: (focusable ? "0" : "-1"),
        disabled: @disabled, style: fill_style(index), class: ITEM,
        data: { slot: "rating-item", index:, checked: ("" if checked), "ui--rating-target": "item", action: "ui--rating#select" }) { glyphs }
    end

    def static_item(index)
      span(data: { slot: "rating-item" }, style: fill_style(index), class: "inline-flex p-[calc(var(--rating-size)/6)]") { glyphs }
    end

    # The muted base icon with the accent icon clipped to the item's fill on top
    def glyphs
      empty, filled = icon_pair

      span(class: "relative block", data: { slot: "rating-item-icon" }) do
        span(data: { slot: "rating-item-base" }, class: cn("relative block size-(--rating-size) *:size-full", ("text-border-strong" if @variant == :filled))) do
          render UI::Icon.new(@variant == :filled ? filled : empty)
        end
        span(data: { slot: "rating-item-fill" }, aria_hidden: "true", class: "absolute inset-0 block size-(--rating-size) *:size-full") do
          render UI::Icon.new(filled)
        end
      end
    end

    # icon: :heart → heart / heart-filled; or { empty: :thumb_up, filled: :thumb_up_filled }
    def icon_pair
      @icon.is_a?(Hash) ? @icon.values_at(:empty, :filled) : [ @icon, :"#{@icon}_filled" ]
    end

    def fill_style(index)
      "--rating-fill: #{((current - (index - 1)).clamp(0, 1) * 100).round(2)}%"
    end

    def format_value(value)
      ActiveSupport::NumberHelper.number_to_rounded(value, precision: 2, strip_insignificant_zeros: true, locale: I18n.locale)
    end
end
