# An item that renders an <a> for navigation
class UI::MenubarLinkItem < UI::Base
  def initialize(href:, close_on_click: true, label: nil, **attributes)
    @href, @close_on_click, @label = href, close_on_click, label
    @attributes = attributes
  end

  def view_template(&)
    a(**mix({
      href: @href,
      role: "menuitem",
      tabindex: "-1",
      data: { slot: "menubar-link-item", orientation: "vertical", label: @label, close: @close_on_click.to_s }
    }, @attributes.except(:class)), class: cn(bar.item_classes, override: @attributes[:class]), &)
  end

  private
    def bar = consume(:ui_menubar, component: "Menubar")
end
