# The scrollable list. With a block that takes an argument it maps over the
# root's items (Appica's render function); otherwise it renders static children.
#
#   AutocompleteList { |item| AutocompleteItem(value: item) { item } }
#   AutocompleteList { AutocompleteItem(value: "Remix") { "Remix" } }
class UI::AutocompleteList < UI::Base
  BASE = "gap-0.5 px-2 min-h-0 flex-1 overflow-y-auto overscroll-contain"

  prop :cols, default: -> { nil }

  def before_template(&content)
    @render_function = content&.arity == 1
    super
  end

  def view_template(&)
    div(**mix(list_attributes, @attributes.except(:class)), class: cn(layout, BASE, override: @attributes[:class])) do
      if @render_function
        root.items.each { |item| yield item }
      else
        yield
      end
    end
  end

  private
    def root = consume(:ui_autocomplete, component: "Autocomplete")

    def grid? = root.grid? || @cols.present?

    def layout
      grid? ? "grid" : "flex flex-col"
    end

    def list_attributes
      {
        id: root.list_id,
        role: "listbox",
        tabindex: "-1",
        aria: { orientation: grid? ? "horizontal" : "vertical" },
        style: ("grid-template-columns: repeat(#{@cols.to_i}, minmax(0, 1fr))" if grid?),
        data: { slot: "autocomplete-list", "ui--autocomplete-target": "list", cols: (@cols || 1 if grid?) }
      }
    end
end
