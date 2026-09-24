# The text field, styled like Appica's Input. Renders the clear button and the
# chevron toggle when the root has `clearable:` / `icon:`.
#
# start_slot: / end_slot: accept a String, a Proc (rendered in this component), or
# :selected_icon to mirror the selected item's `data-icon="start"` element.
class UI::AutocompleteInput < UI::Base
  BASE = "w-full border text-foreground outline-none transition-[background-color,border-color,box-shadow] duration-200 motion-reduce:transition-none [&_svg]:pointer-events-none [&_svg]:shrink-0 flex items-center " \
    "has-focus:ring-[3px] has-focus:ring-ring-input has-focus:border-transparent has-focus:bg-background " \
    "has-data-popup-open:ring-3 has-data-popup-open:ring-ring-input has-data-popup-open:border-transparent has-data-popup-open:bg-background " \
    "data-invalid:bg-error-subtle data-invalid:border-error data-invalid:has-focus:border-transparent data-invalid:has-focus:ring-ring-error data-invalid:has-focus:bg-background " \
    "has-data-invalid:bg-error-subtle has-data-invalid:border-error has-data-invalid:has-focus:border-transparent has-data-invalid:has-focus:ring-ring-error has-data-invalid:has-focus:bg-background " \
    "has-[input:disabled]:border-border-strong! has-[input:disabled]:bg-background-subtle! has-[input:disabled]:cursor-not-allowed has-[input:disabled]:border-dashed has-[input:disabled]:opacity-disabled"

  VARIANTS = {
    outline: "bg-background border-border-strong hover:not-focus:not-focus-visible:not-has-focus:not-has-focus-visible:not-data-popup-open:not-has-data-popup-open:not-data-invalid:not-has-data-invalid:border-border-emphasis",
    soft: "bg-background-muted border-transparent hover:not-focus:not-focus-visible:not-has-focus:not-has-focus-visible:not-data-popup-open:not-has-data-popup-open:not-data-invalid:not-has-data-invalid:border-border-strong"
  }.freeze

  SIZES = {
    sm: "h-8 px-3 text-xs pointer-coarse:text-base rounded-sm gap-1.5 [&_svg:not([class*='size-'])]:size-4 [&_svg:not([class*='stroke-'])]:stroke-[1.75]",
    md: "h-10 px-3.5 text-sm pointer-coarse:text-base rounded-md gap-2 [&_svg:not([class*='size-'])]:size-4.5 [&_svg:not([class*='stroke-'])]:stroke-[1.65]",
    lg: "h-12 px-4 text-base rounded-lg gap-2 [&_svg:not([class*='size-'])]:size-5 [&_svg:not([class*='stroke-'])]:stroke-[1.65]"
  }.freeze

  FIELD = "peer text-foreground placeholder:text-foreground-subtle h-full min-w-0 flex-1 bg-transparent outline-none disabled:cursor-not-allowed"
  CLEAR = "text-foreground-subtle hover:text-foreground shrink-0 cursor-pointer transition-colors duration-200 outline-none data-disabled:pointer-events-none data-disabled:cursor-not-allowed motion-reduce:transition-none"
  TOGGLE = "group/autocomplete-icon text-foreground -me-1 shrink-0 cursor-pointer outline-none disabled:cursor-not-allowed data-disabled:pointer-events-none data-disabled:cursor-not-allowed"

  def initialize(placeholder: " ", start_slot: nil, end_slot: nil, **attributes)
    @placeholder = placeholder
    @start_slot, @end_slot = start_slot, end_slot
    @attributes = attributes
  end

  def view_template
    div(
      role: "group",
      class: cn(BASE, VARIANTS[root.variant], SIZES[root.size], override: @attributes[:class]),
      data: { slot: "autocomplete-input", "ui--autocomplete-target": "anchor" }
    ) do
      slot(@start_slot, :start)
      field
      slot(@end_slot, :end)
      clear_button if root.clearable?
      toggle_button if root.icon?
    end
  end

  private
    def root = consume(:ui_autocomplete, component: "Autocomplete")

    def slot(content, position)
      if content == :selected_icon
        span(class: "contents", data: { slot: "autocomplete-#{position}-slot", "ui--autocomplete-target": "selectedIcon" })
      elsif content
        span(class: "flex shrink-0 items-center", data: { slot: "autocomplete-#{position}-slot" }) { render content }
      end
    end

    def field
      input(**mix({
        type: "text",
        id: "#{root.id}-input",
        name: root.name,
        value: root.value,
        placeholder: @placeholder,
        disabled: root.disabled?,
        autocomplete: "off", spellcheck: "false", autocorrect: "off", autocapitalize: "none",
        role: "combobox",
        aria: { expanded: "false", haspopup: "listbox", autocomplete: "list", controls: root.list_id },
        class: FIELD,
        data: {
          slot: "autocomplete-input-field",
          "ui--autocomplete-target": "input",
          action: "input->ui--autocomplete#filter keydown->ui--autocomplete#navigate focus->ui--autocomplete#focus click->ui--autocomplete#focus"
        }
      }, @attributes.except(:class)))
    end

    def clear_button
      button(
        type: "button", tabindex: "-1", hidden: root.value.blank?, aria: { label: "Clear selection" }, class: CLEAR,
        data: { slot: "autocomplete-clear", "ui--autocomplete-target": "clear", action: "ui--autocomplete#clear" }
      ) do
        render UI::Icon.new(:x, stroke_width: 2, class: "size-[1em]")
      end
    end

    def toggle_button
      button(
        type: "button", tabindex: "-1", disabled: root.disabled?,
        aria: { label: "Toggle popup", expanded: "false", haspopup: "listbox" }, class: TOGGLE,
        data: { slot: "autocomplete-icon", "ui--autocomplete-target": "toggle", action: "ui--autocomplete#toggle" }
      ) do
        render UI::Icon.new(:chevron_down, stroke_width: 2, class: "size-4.5 motion-safe:transition-transform motion-safe:duration-200 group-data-popup-open/autocomplete-icon:rotate-180")
      end
    end
end
