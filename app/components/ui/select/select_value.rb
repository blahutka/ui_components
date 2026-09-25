# The selection shown in the trigger: the item's label (from the root's `items:`, or read from the
# list), `placeholder:` when empty. With `multiple`, one label or `summary:` ("%{count} selected",
# translated by default) for several.
class UI::SelectValue < UI::Base
  prop :placeholder, default: -> { nil }
  prop :summary,     default: -> { t(".summary") }

  def view_template
    values = select.values

    span(**mix({ data: { slot: "select-value", placeholder: ("" if values.empty?), "ui--select-target": "value",
      placeholder_text: @placeholder, summary: @summary } }, @attributes.except(:class)),
      class: cn("min-w-0 flex-1 truncate text-start", override: @attributes[:class])) do
      if values.empty?
        plain @placeholder.to_s
      elsif values.size > 1
        plain @summary.gsub("%{count}", values.size.to_s)
      else
        plain(select.label_for(values.first) || values.first)
      end
    end
  end

  private
    def select
      consume(:ui_select, component: "Select")
    end
end
