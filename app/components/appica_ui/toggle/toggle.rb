# A two-state button (aria-pressed). It has no look of its own - hand its attributes to a Button,
# which paints the pressed state through data-pressed:
#
#   Toggle(pressed: true, aria_label: "Bold") { |toggle| Button(**toggle, variant: :outline, icon: true) { Icon(:bold) } }
#   Toggle(class: "size-4 rounded-full") { "…" }   # a plain <button> you style yourself
#
# Standalone it flips itself (`appica-ui--toggle`) and emits `appica-ui--toggle:change` with { pressed }.
# Inside a ToggleGroup it's pressed when the group's value includes its `value:` and the group
# manages it. Standalone, `name:` submits `value:` with a form while pressed (and
# `unchecked_value:` while released) through a hidden input the controller keeps in sync.
class AppicaUI::Toggle < AppicaUI::Base
  prop :pressed,  default: -> { nil }
  prop :value,    default: -> { nil }
  prop :disabled, default: -> { false }
  prop :name,     default: -> { nil }
  prop :unchecked_value, default: -> { nil }

  def before_template(&content)
    @render_prop = content&.arity == 1
    super
  end

  def view_template(&)
    attributes = mix(toggle_attributes, @attributes)

    hidden_input if @name && !group

    if @render_prop
      yield attributes
    else
      button(**attributes, &)
    end
  end

  private
    # Right before the button, where the controller finds it
    def hidden_input
      value = pressed? ? @value : @unchecked_value
      input(type: "hidden", name: @name, value:, disabled: (true if value.nil?), autocomplete: "off",
        data: { slot: "toggle-input", checked_value: @value, unchecked_value: @unchecked_value })
    end

    def group
      context[:ui_toggle_group]
    end

    def field
      context[:ui_field]
    end

    def pressed?
      if @pressed.nil? && group
        group.include?(@value)
      else
        !!@pressed
      end
    end

    def disabled?
      @disabled || group&.disabled? || (field&.disabled? unless group)
    end

    def toggle_attributes
      {
        type: "button", value: @value, aria_pressed: pressed?.to_s, disabled: (true if disabled?),
        aria_describedby: (field&.described_by.presence unless group), aria_invalid: ("true" if !group && field&.invalid?),
        data: {
          slot: "toggle", pressed: ("" if pressed?), disabled: ("" if disabled?),
          controller: ("appica-ui--toggle" unless group), action: ("appica-ui--toggle#toggle" unless group),
          "appica-ui--toggle-group-target": ("item" if group)
        }
      }.compact
    end
end
