# A button that closes the popover; a block taking an argument receives its attributes.
class UI::PopoverClose < UI::Base
  def before_template(&content)
    @render_prop = content&.arity == 1
    super
  end

  def view_template(&)
    attributes = mix({ type: "button", data: { slot: "popover-close", action: "ui--popover#close" } }, @attributes)
    @render_prop ? yield(attributes) : button(**attributes, &)
  end
end
