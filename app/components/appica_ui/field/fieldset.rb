# Groups related fields under a legend; `disabled: true` disables every control inside.
#
#   Fieldset do
#     FieldsetLegend { "Shipping address" }
#     Field { FieldLabel { "Street" }; Input() }
#   end
class AppicaUI::Fieldset < AppicaUI::Base
  prop :disabled, default: -> { false }
  prop :id,       default: -> { "fieldset-#{SecureRandom.hex(4)}" }

  attr_reader :id

  def view_template(&)
    provide(:ui_fieldset, self) do
      fieldset(**mix({ disabled: @disabled, aria_labelledby: "#{@id}-legend", data: { slot: "fieldset", disabled: ("" if @disabled) } }, @attributes.except(:class)),
        class: cn("flex flex-col gap-4", override: @attributes[:class]), &)
    end
  end
end
