# The Combobox's text field (styled like Input): typing filters the list. It shows the selected
# item's label; inside ComboboxContent it's the popup's search field instead. `start_slot:
# :selected_icon` mirrors the selected item's `data: { icon: "start" }` element.
class UI::ComboboxInput < UI::AutocompleteInput
  prop :placeholder, default: -> { " " }

  def view_template
    if in_popup?
      div(role: "group", class: cn(BASE, VARIANTS[root.variant], SIZES[root.size], override: @attributes[:class]), data: { slot: "combobox-input" }) do
        slot(@start_slot || -> { render UI::Icon.new(:search, class: "text-foreground-subtle") }, :start)
        field
      end
    else
      super
    end
  end

  private
    def root = consume(:ui_combobox, component: "Combobox")

    def in_popup? = context[:ui_combobox_content]

    def field
      label = root.multiple? || in_popup? ? nil : root.values.first.then { |value| value && root.label_for(value) }

      input(**mix({
        type: "text", id: (root.field&.control_id unless in_popup?) || "#{root.id}-input", value: label,
        placeholder: @placeholder, disabled: root.disabled?,
        autocomplete: "off", spellcheck: "false", autocorrect: "off", autocapitalize: "none",
        role: "combobox", aria: { expanded: "false", haspopup: "listbox", autocomplete: "list", controls: root.list_id,
          invalid: ("true" if root.field&.invalid?), describedby: root.field&.described_by },
        class: FIELD,
        data: {
          slot: "combobox-input-field", "ui--combobox-target": "input", "ui--field-target": ("mirror" if root.field),
          action: "input->ui--combobox#filter keydown->ui--combobox#navigate focus->ui--combobox#focus click->ui--combobox#focus"
        }
      }, @attributes.except(:class)))
    end

    def clear_button
      button(type: "button", tabindex: "-1", hidden: root.values.empty?, aria: { label: t("ui_components.ui.combobox.clear") }, class: CLEAR,
        data: { slot: "combobox-clear", "ui--combobox-target": "clear", action: "ui--combobox#clear" }) do
        svg(xmlns: "http://www.w3.org/2000/svg", viewBox: "2 2 16 16", fill: "currentColor", aria_hidden: "true", class: "size-[1em]") { |s| s.path(d: UI::InputStyles::CLEAR_ICON) }
      end
    end
end
