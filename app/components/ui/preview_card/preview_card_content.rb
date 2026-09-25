# The preview card: Popover's card and arrow, beside the link.
class UI::PreviewCardContent < UI::PopoverContent
  private
    def wrap(&)
      template(data: { "ui--popover-target": "template" }, &)
    end

    def root_component = consume(:ui_popover, component: "PreviewCard")
    def popup_role = nil
    def labelled? = false
end
