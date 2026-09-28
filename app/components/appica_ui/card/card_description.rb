# The supporting text: a <p> in text-foreground-muted text-sm
class AppicaUI::CardDescription < AppicaUI::Base
  def view_template(&)
    p(**mix({ data: { slot: "card-description" } }, @attributes.except(:class)),
      class: cn("text-foreground-muted text-sm", override: @attributes[:class]), &)
  end
end
