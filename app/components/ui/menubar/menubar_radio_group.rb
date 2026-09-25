# A set of mutually exclusive MenubarRadioItems. Choosing one dispatches
# `ui--menubar:value-change` with { value, group }.
class UI::MenubarRadioGroup < UI::Base
  prop :value, ->(value) { value&.to_s }, default: -> { nil }
  prop :name,  default: -> { nil }

  attr_reader :value

  def label_id
    @label_id ||= "menubar-group-#{SecureRandom.hex(4)}"
  end

  def view_template(&)
    provide(:ui_menubar_radio_group, self) do
      provide(:ui_menubar_group, self) do
        div(**mix({ role: "group", aria: { labelledby: label_id }, data: { slot: "menubar-radio-group", name: @name, value: @value } }, @attributes.except(:class)),
            class: cn("flex flex-col gap-0.5", override: @attributes[:class]), &)
      end
    end
  end
end
