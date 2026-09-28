# Buttons joined into one control: inner corners squared, shared borders overlapped.
#
#   ButtonGroup(variant: :outline, aria_label: "Range") do
#     Button { "Years" }
#     Button { "Months" }
#     Button { "Days" }
#   end
#
# `variant:`, `size:`, `icon:` and `disabled:` apply to every Button inside (a button's own
# variant / size wins; the group's `disabled:` can't be undone). Outlined variants overlap their
# borders into one hairline; filled ones keep a hairline gap.
class AppicaUI::ButtonGroup < AppicaUI::Base
  OUTLINED = %i[ outline primary_outline light ].freeze

  BASE = "isolate flex w-fit items-stretch *:relative *:hover:z-2 *:focus-visible:z-2 *:active:z-2"
  ORIENTATIONS = {
    horizontal: "[&>*:not(:first-of-type)]:rounded-s-none [&>*:not(:last-of-type)]:rounded-e-none",
    vertical: "flex-col [&>*:not(:first-of-type)]:rounded-t-none [&>*:not(:last-of-type)]:rounded-b-none"
  }.freeze
  SEAMS = {
    horizontal: { outlined: "-space-x-(--border-width)", filled: "space-x-(--border-width)" },
    vertical: { outlined: "-space-y-(--border-width)", filled: "space-y-(--border-width)" }
  }.freeze

  prop :variant,     one_of(AppicaUI::Button::VARIANTS, :primary), default: -> { nil }
  prop :size,        one_of(AppicaUI::Button::SIZES, :md), default: -> { nil }
  prop :icon,        default: -> { nil }
  prop :orientation, one_of(ORIENTATIONS, :horizontal), default: -> { :horizontal }
  prop :disabled,    default: -> { false }

  attr_reader :variant, :size, :icon

  def disabled? = @disabled

  def view_template(&)
    seam = SEAMS[@orientation][OUTLINED.include?(@variant || :primary) ? :outlined : :filled]

    provide(:ui_button_group, self) do
      div(**mix(defaults(role: "group", data: { slot: "button-group", orientation: @orientation, disabled: ("" if @disabled) }), @attributes.except(:class)),
        class: cn(BASE, ORIENTATIONS[@orientation], seam, override: @attributes[:class]), &)
    end
  end
end
