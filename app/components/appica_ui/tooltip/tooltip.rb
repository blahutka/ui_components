# A short, non-interactive hint shown while its trigger is hovered or focused.
#
#   Tooltip do
#     TooltipTrigger { |trigger| Button(**trigger, variant: :outline, icon: true, aria_label: "Add to favorites") { Icon(:heart) } }
#     TooltipContent { "Add to favorites" }
#   end
#
# Opens after the delay (600 ms, or a TooltipProvider's), instantly on keyboard focus; closes on
# leave, blur, Escape or a click on the trigger. `track_cursor_axis:` (:x, :y, :both) makes it
# follow the pointer; `disabled: true` suppresses it. A tooltip isn't reachable on touch or by
# screen readers as a name - give icon-only triggers an aria_label.
class AppicaUI::Tooltip < AppicaUI::Popover
  prop :track_cursor_axis, one_of(%i[ none x y both ], :none), default: -> { :none }
  prop :disabled,          default: -> { false }
  prop :delay,             default: -> { nil }
  prop :close_delay,       default: -> { nil }
  prop :id,                default: -> { "tooltip-#{SecureRandom.hex(4)}" }

  def slot = "tooltip"

  def view_template(&)
    provide(:ui_popover, self) do
      span(**mix(defaults(id: @id, data: {
        slot:, controller: ("appica-ui--popover" unless @disabled), "appica-ui--popover-open-value": @default_open.to_s,
        "appica-ui--popover-hover-value": "true", "appica-ui--popover-focus-value": "true", "appica-ui--popover-close-on-click-value": "true",
        "appica-ui--popover-interactive-value": "false", "appica-ui--popover-delay-value": 600,
        "appica-ui--popover-track-value": (@track_cursor_axis.to_s unless @track_cursor_axis == :none)
      }), @attributes.except(:class)), class: cn("inline-flex w-fit", override: @attributes[:class])) do
        @trigger_delay = @delay
        @trigger_close_delay = @close_delay
        yield
      end
    end
  end

  attr_reader :trigger_delay, :trigger_close_delay
end
