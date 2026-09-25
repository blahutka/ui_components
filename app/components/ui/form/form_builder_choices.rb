# A RadioGroup or CheckboxGroup with one labelled Radio / Checkbox per choice, as
# UI::FormBuilder renders it. Like Rails' collection helpers, an empty hidden input goes first
# so a group with nothing chosen still submits its key.
class UI::FormBuilderChoices < UI::Base
  ITEM = "flex w-fit items-center gap-2 text-sm select-none has-[input:disabled]:text-foreground-muted"

  prop :type, one_of(%i[ radio checkbox ], :radio)
  prop :group
  prop :items
  prop :id
  prop :hidden_name, default: -> { nil }

  def view_template
    input(type: "hidden", name: @hidden_name, value: "", autocomplete: "off") if @hidden_name
    render group_class.new(**@group) do
      @items.each do |value, text|
        label(class: ITEM) do
          render item_class.new(value:, id: "#{@id}_#{sanitized(value)}")
          plain text
        end
      end
    end
  end

  private
    def group_class = @type == :radio ? UI::RadioGroup : UI::CheckboxGroup
    def item_class = @type == :radio ? UI::Radio : UI::Checkbox

    # Rails' ids for collection items: user_plan_pro
    def sanitized(value)
      value.to_s.gsub(/[\s.]/, "_").gsub(/[^-[[:word:]]]/, "").downcase
    end
end
