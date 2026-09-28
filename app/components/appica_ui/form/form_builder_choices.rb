# A RadioGroup, CheckboxGroup or ChipGroup with one labelled Radio / Checkbox / ChipCheckbox per
# choice, as AppicaUI::FormBuilder renders it. Like Rails' collection helpers, an empty hidden input
# goes first so a group with nothing chosen still submits its key.
class AppicaUI::FormBuilderChoices < AppicaUI::Base
  ITEM = "flex w-fit items-center gap-2 text-sm select-none has-[input:disabled]:text-foreground-muted"

  prop :type, one_of(%i[ radio checkbox chip ], :radio)
  prop :group
  prop :items
  prop :id
  prop :hidden_name, default: -> { nil }

  def view_template
    input(type: "hidden", name: @hidden_name, value: "", autocomplete: "off") if @hidden_name

    case @type
    when :radio then render(AppicaUI::RadioGroup.new(**@group)) { labelled_items(AppicaUI::Radio) }
    when :checkbox then render(AppicaUI::CheckboxGroup.new(**@group)) { labelled_items(AppicaUI::Checkbox) }
    when :chip then chips
    end
  end

  private
    def labelled_items(component)
      @items.each do |value, text|
        label(class: ITEM) do
          render component.new(value:, id: item_id(value))
          plain text
        end
      end
    end

    # A ChipGroup has no value of its own: each chip gets the name and its checked state
    def chips
      name, selected, disabled = @group.values_at(:name, :value, :disabled)
      field = context[:ui_field]

      render AppicaUI::ChipGroup.new(role: "group", id: @id, aria_labelledby: (field.label_id if field), aria_describedby: field&.described_by.presence,
        **@group.except(:name, :value, :disabled)) do
        @items.each do |value, text|
          render(AppicaUI::ChipCheckbox.new(name:, value:, id: item_id(value), checked: selected.include?(value.to_s), disabled: (true if disabled))) { text }
        end
      end
    end

    # Rails' ids for collection items: user_plan_pro
    def item_id(value)
      "#{@id}_#{value.to_s.gsub(/[\s.]/, "_").gsub(/[^-[[:word:]]]/, "").downcase}"
    end
end
