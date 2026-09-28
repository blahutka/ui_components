# The field's label, bound to its control (clicking it focuses the control).
class AppicaUI::FieldLabel < AppicaUI::Base
  def view_template(&)
    field = consume(:ui_field, component: "AppicaUI::Field")

    label(**mix({ id: field.label_id, for: field.control_id, data: { slot: "field-label", disabled: ("" if field.disabled?) } }, @attributes.except(:class)),
      class: cn("text-foreground-intense mb-1.5 flex w-fit items-center text-sm font-medium select-none data-disabled:opacity-disabled", override: @attributes[:class]), &)
  end
end
