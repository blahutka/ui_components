# A row of Toggles tracking which are pressed: one at a time, or several with `multiple: true`.
#
#   ToggleGroup(default_value: [ "center" ], aria_label: "Text alignment") do
#     Toggle(value: "left", aria_label: "Align left") { |t| Button(**t, variant: :ghost, icon: true) { Icon(:align_left) } }
#     Toggle(value: "center", aria_label: "Align center") { |t| Button(**t, variant: :ghost, icon: true) { Icon(:align_center) } }
#   end
#
# The row is one tab stop; the arrow keys move along `orientation:` (wrapping with `loop_focus:`).
# `name:` submits the pressed values as `name[]` fields. Emits `ui--toggle-group:change` with
# { value } (the pressed values). It's a `role="group"` - name it with aria_label(ledby).
class UI::ToggleGroup < UI::Base
  prop :value,         default: -> { nil }
  prop :default_value, ->(value) { Array(value).map(&:to_s) }, default: -> { [] }
  prop :multiple,      default: -> { false }
  prop :orientation,   one_of(%i[ horizontal vertical ], :horizontal), default: -> { :horizontal }
  prop :loop_focus,    default: -> { true }
  prop :disabled,      default: -> { false }
  prop :name,          default: -> { nil }

  def include?(value)
    selected.include?(value.to_s)
  end

  def disabled? = @disabled

  def view_template(&)
    provide(:ui_toggle_group, self) do
      div(**mix(defaults(role: "group", data: {
        slot: "toggle-group", orientation: @orientation, multiple: ("" if @multiple), disabled: ("" if @disabled),
        controller: "ui--toggle-group", action: "click->ui--toggle-group#press keydown->ui--toggle-group#navigate",
        "ui--toggle-group-multiple-value": @multiple.to_s, "ui--toggle-group-loop-value": @loop_focus.to_s,
        "ui--toggle-group-name-value": @name
      }), @attributes.except(:class)),
        class: cn("flex w-fit items-center gap-1 data-[orientation=vertical]:flex-col data-[orientation=vertical]:items-stretch", override: @attributes[:class])) do
        yield
        selected.each { |value| input(type: "hidden", name: "#{@name}[]", value:, data: { "ui--toggle-group-target": "input" }) } if @name
      end
    end
  end

  private
    def selected
      @value.nil? ? @default_value : Array(@value).map(&:to_s)
    end
end
