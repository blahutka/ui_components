# Mutually exclusive DropdownMenuRadioItems. Choosing one emits `value-change` { group, value }.
class UI::DropdownMenuRadioGroup < UI::Base
  prop :value, ->(value) { value&.to_s }, default: -> { nil }
  prop :name,  default: -> { nil }

  attr_reader :value

  def label_id
    @label_id ||= "menu-group-#{SecureRandom.hex(4)}"
  end

  def view_template(&)
    menu = consume(:ui_dropdown_menu, component: "DropdownMenu")
    provide(:ui_dropdown_menu_radio_group, self) do
      provide(:ui_dropdown_menu_group, self) do
        div(**mix({ role: "group", aria_labelledby: label_id, data: { slot: "#{menu.slot}-radio-group", name: @name, value: @value } }, @attributes.except(:class)),
          class: cn("flex flex-col gap-0.5", override: @attributes[:class]), &)
      end
    end
  end
end
