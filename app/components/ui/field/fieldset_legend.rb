# The fieldset's heading, naming the group.
class UI::FieldsetLegend < UI::Base
  def view_template(&)
    fieldset = consume(:ui_fieldset, component: "UI::Fieldset")

    div(**mix({ id: "#{fieldset.id}-legend", data: { slot: "fieldset-legend" } }, @attributes.except(:class)),
      class: cn("text-foreground-intense text-lg font-medium", override: @attributes[:class]), &)
  end
end
