# The validation message, sliding open when the field turns invalid. With no block it shows the
# field's message (server `error:` or the browser's); `match: :value_missing` (any ValidityState
# key) shows the block's text only for that failure.
#
#   FieldError()
#   FieldError(match: :type_mismatch) { "That doesn't look like an email address" }
class UI::FieldError < UI::Base
  WRAPPER = "grid grid-rows-[0fr] has-[[data-slot=field-error]:not([hidden])]:grid-rows-[1fr] motion-safe:transition-[grid-template-rows] motion-safe:duration-200 motion-safe:ease-out"
  MESSAGE = "min-h-0 overflow-hidden text-error-emphasis flex gap-1 pt-1 text-xs [&_svg]:shrink-0 [&_svg:not([class*='size-'])]:size-4 [&_svg:not([class*='stroke-'])]:stroke-[1.75]"

  prop :match, default: -> { nil }

  def view_template(&block)
    field = consume(:ui_field, component: "UI::Field")
    shown = !@match && field.error.present?

    div(class: WRAPPER, data: { slot: "field-error-wrapper" }) do
      div(**mix({ id: [ field.error_id, @match ].compact.join("-").dasherize, role: "alert", aria_live: "polite", hidden: !shown,
        data: { slot: "field-error", "ui--field-target": "error", match: @match&.to_s&.camelize(:lower) } }, @attributes.except(:class)),
        class: cn(MESSAGE, override: @attributes[:class])) do
        if block
          yield
        else
          span(data: { "ui--field-target": "message" }) { field.error.to_s }
        end
      end
    end
  end
end
