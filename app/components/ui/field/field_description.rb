# Supporting text, announced as the control's description.
class UI::FieldDescription < UI::Base
  def view_template(&)
    field = consume(:ui_field, component: "UI::Field")

    p(**mix({ id: field.description_id, data: { slot: "field-description", disabled: ("" if field.disabled?) } }, @attributes.except(:class)),
      class: cn("text-foreground-muted data-disabled:opacity-disabled mt-1.5 text-sm", override: @attributes[:class]), &)
  end
end
