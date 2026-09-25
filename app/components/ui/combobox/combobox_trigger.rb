# A select-style field for a Combobox whose search input lives inside ComboboxContent. Put
# ComboboxValue in it. Set `icon: false` on the root so the popup's input has no chevron.
class UI::ComboboxTrigger < UI::Base
  include UI::InputStyles

  CHEVRON = "M11.594 5.594c.225-.225.588-.225.813 0s.225.588 0 .813l-4 4c-.225.225-.588.225-.812 0l-4-4c-.225-.225-.225-.588 0-.812s.588-.225.812 0L8 9.187l3.594-3.594z"

  prop :start_slot, default: -> { nil }

  def view_template(&)
    button(**control_attributes({
      type: "button", id: field&.control_id || "#{root.id}-trigger", role: "combobox", aria_haspopup: "dialog", aria_expanded: "false",
      aria_invalid: ("true" if invalid?), aria_describedby: field&.described_by, aria_labelledby: (field.label_id if field && !@attributes.key?(:aria_label)),
      disabled: (true if root.disabled?),
      data: {
        slot: "combobox-trigger", placeholder: flag(root.values.empty?), invalid: flag(invalid?),
        "ui--combobox-target": "anchor trigger", "ui--field-target": ("mirror" if field), action: "click->ui--combobox#toggle keydown->ui--combobox#triggerKey"
      }
    }, @attributes.except(:class)),
      class: cn(input_classes(variant: root.variant, size: root.size, state: :self), "group/combobox-trigger data-placeholder:text-foreground-subtle flex items-center justify-between",
        override: @attributes[:class])) do
      if @start_slot == :selected_icon
        span(class: "contents", data: { "ui--combobox-target": "selectedIcon" })
      elsif @start_slot
        span(class: "-ms-1 flex shrink-0 items-center") { render_slot(@start_slot) }
      end
      span(class: "flex min-w-0 flex-1 items-center truncate text-start", &)
      svg(xmlns: "http://www.w3.org/2000/svg", viewBox: "0 0 16 16", fill: "currentColor", aria_hidden: "true", data: { slot: "combobox-icon" },
        class: "size-4.5 text-foreground -me-1 shrink-0 motion-safe:transition-transform motion-safe:duration-200 group-data-popup-open/combobox-trigger:rotate-180") { |s| s.path(d: CHEVRON) }
    end
  end

  private
    def root = consume(:ui_combobox, component: "Combobox")
end
