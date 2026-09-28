# A Chip you can select: a <label> in Chip's look around a visually hidden checkbox, so a set of
# them submits like check boxes. The checked chip turns primary and shows a check - pure CSS.
#
#   ChipGroup(variant: :outline, role: "group", aria_label: "Tags") do
#     ChipCheckbox(name: "tags[]", value: "ruby", checked: true) { "Ruby" }
#     ChipCheckbox(name: "tags[]", value: "rails") { "Rails" }
#   end
#
# Inside a ChipGroup it takes the group's variant and size (outline by default).
class AppicaUI::ChipCheckbox < AppicaUI::Base
  include AppicaUI::FieldControl

  CHECKED = "has-checked:text-primary-foreground has-checked:hover:text-primary-foreground " \
    "has-checked:before:bg-primary has-checked:before:border-primary has-checked:hover:before:bg-primary has-checked:hover:before:border-primary"
  STATES = "has-focus-visible:outline-3 has-focus-visible:outline-solid " \
    "has-aria-invalid:before:border-error has-aria-invalid:text-error-emphasis " \
    "has-disabled:opacity-disabled has-disabled:cursor-not-allowed has-disabled:pointer-events-none"

  prop :value,   default: -> { nil }
  prop :checked, default: -> { nil }
  prop :invalid, default: -> { nil }
  prop :variant, one_of(AppicaUI::Chip::VARIANTS, :outline), default: -> { nil }
  prop :size,    one_of(AppicaUI::Chip::SIZES, :md), default: -> { nil }

  def view_template(&)
    label(data: { slot: "chip-checkbox", variant:, size: }, class: cn(AppicaUI::Button::BASE, AppicaUI::Chip::VARIANTS[variant], AppicaUI::Chip::SIZES[size],
      "group/chip-checkbox", CHECKED, STATES, override: @attributes[:class])) do
      input(**control_attributes({
        type: "checkbox", name: field&.name, value: @value, checked: @checked,
        disabled: (true if disabled?), aria_invalid: ("true" if invalid?),
        data: { slot: "chip-checkbox-input", invalid: flag(invalid?), "appica-ui--field-target": ("control" if field) }
      }, @attributes.except(:class)), class: "peer sr-only")
      render AppicaUI::Icon.new(:check, stroke_width: 2, aria_hidden: "true", class: "-ms-0.5 hidden group-has-checked/chip-checkbox:inline")
      yield if block_given?
    end
  end

  private
    def variant
      @variant || context[:ui_chip_group]&.variant || :outline
    end

    def size
      @size || context[:ui_chip_group]&.size || :md
    end
end
