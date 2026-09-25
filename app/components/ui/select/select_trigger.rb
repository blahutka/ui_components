# The button that opens the Select, styled like Input. `clearable: true` adds a ✕ (Delete /
# Backspace clear too); `start_slot:` / `end_slot:` take an icon name, text or a block -
# `start_slot: :selected` mirrors the selected item's `data: { icon: "start" }` element (a flag, an
# avatar). Put SelectValue inside.
class UI::SelectTrigger < UI::Base
  include UI::InputStyles

  CHEVRON = "M10.26 9.593c.225-.224.589-.224.814 0s.224.589 0 .813l-2.667 2.667c-.225.224-.589.224-.813 0l-2.666-2.667c-.225-.225-.225-.589 0-.813s.588-.224.813 0l2.26 2.26 2.261-2.26zM7.593 2.927c.225-.225.589-.225.813 0l2.667 2.666c.224.224.224.589 0 .813s-.589.225-.814 0L7.999 4.146 5.74 6.407c-.225.224-.588.224-.812 0s-.225-.589 0-.813l2.666-2.666z"

  prop :clearable,   default: -> { false }
  prop :start_slot,  default: -> { nil }
  prop :end_slot,    default: -> { nil }
  prop :invalid,     default: -> { nil }

  def view_template(&)
    button(**control_attributes({
      type: "button", id: field&.control_id || "#{select.id}-trigger", role: "combobox", aria_haspopup: "listbox", aria_expanded: "false",
      aria_controls: select.list_id, aria_invalid: ("true" if invalid?), aria_describedby: field&.described_by,
      aria_labelledby: (field.label_id if field && !@attributes.key?(:aria_label)),
      disabled: (true if select.disabled?),
      data: {
        slot: "select-trigger", placeholder: flag(select.values.empty?), invalid: flag(invalid?), disabled: flag(select.disabled?),
        "ui--select-target": "trigger", "ui--field-target": ("mirror" if field), action: "click->ui--select#toggle"
      }
    }, @attributes.except(:class)),
      class: cn(input_classes(variant: select.variant, size: select.size, state: :self), "data-placeholder:text-foreground-subtle flex items-center justify-between",
        override: @attributes[:class])) do
      span(data: { slot: "select-trigger-start", "ui--select-target": "start" }, class: "-ms-1 flex shrink-0 items-center empty:hidden") { start_content } if @start_slot
      span(class: "flex min-w-0 flex-1 items-center truncate text-start", &)
      span(data: { slot: "select-trigger-end" }, class: "flex shrink-0 items-center") { render_slot(@end_slot) } if @end_slot
      if @clearable
        span(aria_hidden: "true", hidden: select.values.empty?,
          data: { slot: "select-clear", "ui--select-target": "clear", action: "pointerdown->ui--select#clear" },
          class: "text-foreground-subtle hover:text-foreground shrink-0 cursor-pointer transition-colors duration-200 motion-reduce:transition-none") do
          svg(xmlns: "http://www.w3.org/2000/svg", viewBox: "2 2 16 16", fill: "currentColor", aria_hidden: "true", class: "size-[1em]") { |s| s.path(d: CLEAR_ICON) }
        end
      end
      svg(xmlns: "http://www.w3.org/2000/svg", viewBox: "0 0 16 16", fill: "currentColor", aria_hidden: "true", data: { slot: "select-icon" },
        class: "size-4.5 text-foreground -me-1 shrink-0") { |s| s.path(d: CHEVRON) }
    end
  end

  private
    def select
      consume(:ui_select, component: "Select")
    end

    def invalid?
      @invalid || [ true, "true" ].include?(@attributes[:aria_invalid]) || field&.invalid?
    end

    # :selected is filled by the controller from the selected item
    def start_content
      render_slot(@start_slot) unless @start_slot == :selected
    end
end
