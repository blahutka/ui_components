# A row of Toggles tracking which are pressed: one at a time, or several with `multiple: true`.
#
#   ToggleGroup(default_value: [ "center" ], aria_label: "Text alignment") do
#     Toggle(value: "left", aria_label: "Align left") { |t| Button(**t, variant: :ghost, icon: true) { Icon(:align_left) } }
#     Toggle(value: "center", aria_label: "Align center") { |t| Button(**t, variant: :ghost, icon: true) { Icon(:align_center) } }
#   end
#
# The row is one tab stop; the arrow keys move along `orientation:` (wrapping with `loop_focus:`).
# `name:` submits the pressed value as `name` (or, `multiple: true`, the pressed values as `name[]`
# fields); `include_hidden: true` adds an empty one first, so pressing nothing still submits the
# key. Emits `appica-ui--toggle-group:change` with { value } (the pressed values). It's a `role="group"` -
# name it with aria_label(ledby), or put it in a Field.
class AppicaUI::ToggleGroup < AppicaUI::Base
  prop :value,         default: -> { nil }
  prop :default_value, ->(value) { Array(value).map(&:to_s) }, default: -> { [] }
  prop :multiple,      default: -> { false }
  prop :orientation,   one_of(%i[ horizontal vertical ], :horizontal), default: -> { :horizontal }
  prop :loop_focus,    default: -> { true }
  prop :disabled,      default: -> { false }
  prop :name,          default: -> { nil }
  prop :include_hidden, default: -> { false }

  def include?(value)
    selected.include?(value.to_s)
  end

  def disabled? = @disabled || field&.disabled?

  def field
    context[:ui_field]
  end

  def view_template(&)
    provide(:ui_toggle_group, self) do
      div(**mix(defaults(role: "group", data: {
        slot: "toggle-group", orientation: @orientation, multiple: ("" if @multiple), disabled: ("" if disabled?),
        controller: "appica-ui--toggle-group", action: "click->appica-ui--toggle-group#press keydown->appica-ui--toggle-group#navigate",
        "appica-ui--toggle-group-multiple-value": @multiple.to_s, "appica-ui--toggle-group-loop-value": @loop_focus.to_s,
        "appica-ui--toggle-group-name-value": input_name
      }, id: field&.control_id, aria_labelledby: (field.label_id if field && !@attributes.key?(:aria_label)),
        aria_describedby: field&.described_by.presence, aria_invalid: ("true" if field&.invalid?)), @attributes.except(:class)),
        class: cn("flex w-fit items-center gap-1 data-[orientation=vertical]:flex-col data-[orientation=vertical]:items-stretch", override: @attributes[:class])) do
        yield
        if input_name
          input(type: "hidden", name: input_name, value: "", autocomplete: "off") if @include_hidden
          selected.each { |value| input(type: "hidden", name: input_name, value:, data: { "appica-ui--toggle-group-target": "input" }) }
        end
      end
    end
  end

  private
    def input_name
      name = @name || field&.name
      return unless name

      @multiple && !name.end_with?("[]") ? "#{name}[]" : name
    end

    def selected
      @value.nil? ? @default_value : Array(@value).map(&:to_s)
    end
end
