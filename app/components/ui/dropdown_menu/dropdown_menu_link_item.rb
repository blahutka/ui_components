# An item that is a link (<a>) - for navigation from the menu.
class UI::DropdownMenuLinkItem < UI::DropdownMenuItem
  prop :href

  def view_template(&)
    a(**mix({ href: @href }.merge(item_attributes("link-item")), @attributes.except(:class)), class: cn(menu.item_classes, override: @attributes[:class]), &)
  end
end
