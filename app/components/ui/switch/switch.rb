# An on/off toggle for a setting that applies right away: a native checkbox with role="switch".
#
#   label(class: "flex items-center gap-2.5") do
#     Switch(name: "airplane_mode", checked: true)
#     plain "Airplane mode"
#   end
#
# It renders only the track and thumb - wrap it with its text in a <label>. `size:` scales both.
# Native attributes (name, value, required, form, aria_*) go to the <input>, `class:` to the
# track. `unchecked_value:` submits a value when it's off. Inside a Field it takes the field's
# id and state.
class UI::Switch < UI::Base
  include UI::FieldControl

  SIZES = {
    sm: { track: "h-4 w-7.5", thumb: "size-3 peer-checked:translate-x-3.5 rtl:peer-checked:-translate-x-3.5", check: "size-2.5" },
    md: { track: "h-5 w-9.5", thumb: "size-4 peer-checked:translate-x-4.5 rtl:peer-checked:-translate-x-4.5", check: "size-3" },
    lg: { track: "h-6 w-11.5", thumb: "size-5 peer-checked:translate-x-5.5 rtl:peer-checked:-translate-x-5.5", check: "size-4" }
  }.freeze

  ROOT = "group/switch relative inline-flex shrink-0 align-middle has-[input:disabled]:opacity-disabled"
  TRACK = "peer m-0 shrink-0 cursor-pointer appearance-none bg-background-strong outline-ring rounded-full border border-transparent outline-offset-1 " \
    "transition-[background-color] duration-200 motion-reduce:transition-none " \
    "checked:bg-primary checked:outline-ring-primary " \
    "disabled:cursor-not-allowed disabled:not-checked:border-border-strong disabled:not-checked:border-dashed " \
    "aria-invalid:border-error aria-invalid:not-checked:bg-error-subtle aria-invalid:outline-ring-error"
  THUMB = "pointer-events-none absolute start-0.5 top-0.5 flex items-center justify-center rounded-full bg-white shadow-2xs " \
    "peer-checked:bg-primary-foreground motion-safe:transition-transform motion-safe:duration-200 motion-safe:ease-[cubic-bezier(0.175,0.885,0.32,1.25)]"
  CHECK = "text-foreground-intense [stroke-dasharray:12] [stroke-dashoffset:12] group-has-checked/switch:[stroke-dashoffset:0] " \
    "motion-safe:transition-[stroke-dashoffset] motion-safe:duration-200 motion-safe:delay-75"

  prop :size,            one_of(SIZES.keys, :md), default: -> { :md }
  prop :checked,         default: -> { nil }
  prop :invalid,         default: -> { nil }
  prop :value,           default: -> { nil }
  prop :unchecked_value, default: -> { nil }

  def view_template
    span(data: { slot: "switch" }, class: ROOT) do
      input(type: "hidden", name: control_name, value: @unchecked_value, form: @attributes[:form], disabled: disabled?) if @unchecked_value && control_name
      input(**control_attributes({
        type: "checkbox", role: "switch", id: field&.control_id, name: control_name, value: @value, checked: @checked,
        disabled: (true if disabled?), aria_invalid: ("true" if invalid?), aria_describedby: field&.described_by,
        data: { slot: "switch-input", invalid: flag(invalid?), "ui--field-target": ("control" if field) }
      }, @attributes.except(:class)), class: cn(TRACK, SIZES[@size][:track], override: @attributes[:class]))
      span(aria_hidden: "true", class: "#{THUMB} #{SIZES[@size][:thumb]}", data: { slot: "switch-thumb" }) do
        svg(xmlns: "http://www.w3.org/2000/svg", viewBox: "0 0 12 12", fill: "none", stroke: "currentColor", stroke_width: "1.5",
          stroke_linecap: "round", stroke_linejoin: "round", class: "#{CHECK} #{SIZES[@size][:check]}") { |s| s.path(d: "M3 6l2 2 4-4") }
      end
    end
  end

  private
    def control_name
      @attributes[:name] || field&.name
    end
end
