# The field of a `multiple` Combobox: a removable chip per selected value, then the text field
# for adding more. Backspace in the empty field removes the last chip.
class UI::ComboboxChips < UI::Base
  include UI::InputStyles

  CHIP = "#{UI::Button::BASE.sub("cursor-pointer ", "").sub("font-medium ", "")} " \
    "hover:text-foreground-intense before:bg-background-muted hover:before:bg-background-subtle hover:before:border-border outline-ring before:border before:border-transparent " \
    "text-foreground-strong cursor-default font-normal"
  CHIP_SIZES = { sm: "h-6 px-2 text-xs rounded-xs gap-1", md: "h-8 px-3 text-sm rounded-sm gap-1.5", lg: "h-10 px-3.5 text-base rounded-md gap-1.5" }.freeze
  # With chips the frame grows to fit them (Appica's classes)
  WITH_CHIPS = "has-data-[slot=combobox-chip]:h-auto has-data-[slot=combobox-chip]:flex-wrap has-data-[slot=combobox-chip]:items-start has-data-[slot=combobox-chip]:p-1"
  MIN_HEIGHTS = { sm: "has-data-[slot=combobox-chip]:min-h-8", md: "has-data-[slot=combobox-chip]:min-h-10", lg: "has-data-[slot=combobox-chip]:min-h-12" }.freeze
  REMOVE = "text-foreground-subtle hover:text-foreground -me-0.5 shrink-0 cursor-pointer transition-colors duration-200 outline-none motion-reduce:transition-none"

  prop :placeholder, default: -> { " " }

  def view_template
    div(role: "group", data: { slot: "combobox-chips", "ui--combobox-target": "anchor" },
      class: cn(BASE, VARIANTS[root.variant], SIZES[root.size], STATES[:within], "group/combobox-chips", WITH_CHIPS, MIN_HEIGHTS[root.size], override: @attributes[:class])) do
      div(role: "toolbar", data: { slot: "combobox-chips-list", "ui--combobox-target": "chips" },
        class: "flex h-full min-w-0 flex-1 flex-wrap items-center gap-1 **:data-[slot=combobox-input-field]:px-1") do
        root.values.each { |value| chip(value) }
        input(type: "text", id: root.field&.control_id || "#{root.id}-input", placeholder: @placeholder, disabled: root.disabled?,
          autocomplete: "off", spellcheck: "false", autocorrect: "off", autocapitalize: "none",
          role: "combobox", aria: { expanded: "false", haspopup: "listbox", autocomplete: "list", controls: root.list_id, describedby: root.field&.described_by },
          class: "peer text-foreground placeholder:text-foreground-subtle min-w-15 flex-1 self-stretch bg-transparent outline-none disabled:cursor-not-allowed",
          data: {
            slot: "combobox-input-field", "ui--combobox-target": "input", "ui--field-target": ("mirror" if root.field),
            action: "input->ui--combobox#filter keydown->ui--combobox#navigate focus->ui--combobox#focus click->ui--combobox#focus"
          })
      end
      div(data: { slot: "combobox-controls" },
        class: "flex shrink-0 items-center gap-1 self-center group-has-data-[slot=combobox-chip]/combobox-chips:self-start group-has-data-[slot=combobox-chip]/combobox-chips:pt-1.5 group-has-data-[slot=combobox-chip]/combobox-chips:pe-2.5") do
        if root.clearable?
          button(type: "button", tabindex: "-1", hidden: root.values.empty?, aria_label: t("ui_components.ui.combobox.clear"), class: UI::AutocompleteInput::CLEAR,
            data: { slot: "combobox-clear", "ui--combobox-target": "clear", action: "ui--combobox#clear" }) { close_icon }
        end
        if root.icon?
          button(type: "button", tabindex: "-1", aria_label: t("ui_components.ui.combobox.toggle"), aria_expanded: "false", aria_haspopup: "listbox",
            data: { slot: "combobox-toggle", "ui--combobox-target": "toggle", action: "ui--combobox#toggle" }, class: UI::AutocompleteInput::TOGGLE) do
            render UI::Icon.new(:chevron_down, stroke_width: 2, class: "size-4.5 motion-safe:transition-transform motion-safe:duration-200 group-data-popup-open/autocomplete-icon:rotate-180")
          end
        end
      end
      template(data: { "ui--combobox-target": "chipTemplate" }) { chip("") }
    end
  end

  private
    def root = consume(:ui_combobox, component: "Combobox")

    def chip(value)
      label = value.empty? ? "" : root.label_for(value)
      div(tabindex: "-1", aria_label: label, data: { slot: "combobox-chip", value: }, class: "#{CHIP} #{CHIP_SIZES[root.size]}") do
        span(class: "min-w-0 truncate", data: { slot: "combobox-chip-label" }) { label }
        button(type: "button", tabindex: "-1", aria_label: t("ui_components.ui.combobox.remove"), class: REMOVE,
          data: { slot: "combobox-chip-remove", action: "ui--combobox#remove" }) { close_icon }
      end
    end

    def close_icon
      svg(xmlns: "http://www.w3.org/2000/svg", viewBox: "2 2 16 16", fill: "currentColor", aria_hidden: "true", class: "size-[1em]") { |s| s.path(d: CLEAR_ICON) }
    end
end
