# The fieldset's heading, naming the group.
class AppicaUI::FieldsetLegend < AppicaUI::Base
  def view_template(&)
    fieldset = consume(:ui_fieldset, component: "AppicaUI::Fieldset")

    div(**mix({ id: "#{fieldset.id}-legend", data: { slot: "fieldset-legend" } }, @attributes.except(:class)),
      class: cn("text-foreground-intense text-lg font-medium", override: @attributes[:class]), &)
  end
end
