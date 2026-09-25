# A two-state button (aria-pressed). It has no look of its own - hand its attributes to a Button,
# which paints the pressed state through data-pressed:
#
#   Toggle(pressed: true, aria_label: "Bold") { |toggle| Button(**toggle, variant: :outline, icon: true) { Icon(:bold) } }
#   Toggle(class: "size-4 rounded-full") { "…" }   # a plain <button> you style yourself
#
# Standalone it flips itself (`ui--toggle`) and emits `ui--toggle:change` with { pressed }.
# Inside a ToggleGroup it's pressed when the group's value includes its `value:` and the group
# manages it. `name:` submits `value:` with a form while pressed.
class UI::Toggle < UI::Base
  prop :pressed,  default: -> { nil }
  prop :value,    default: -> { nil }
  prop :disabled, default: -> { false }

  def before_template(&content)
    @render_prop = content&.arity == 1
    super
  end

  def view_template(&)
    attributes = mix(toggle_attributes, @attributes)

    if @render_prop
      yield attributes
    else
      button(**attributes, &)
    end
  end

  private
    def group
      context[:ui_toggle_group]
    end

    def pressed?
      if @pressed.nil? && group
        group.include?(@value)
      else
        !!@pressed
      end
    end

    def disabled?
      @disabled || group&.disabled?
    end

    def toggle_attributes
      {
        type: "button", value: @value, aria_pressed: pressed?.to_s, disabled: (true if disabled?),
        data: {
          slot: "toggle", pressed: ("" if pressed?), disabled: ("" if disabled?),
          controller: ("ui--toggle" unless group), action: ("ui--toggle#toggle" unless group),
          "ui--toggle-group-target": ("item" if group)
        }
      }.compact
    end
end
