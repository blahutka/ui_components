# A Button that copies text to the clipboard, then swaps its icon for a drawn check.
#
#   CopyButton(value: "npm install @appica/ui-react")
#   CopyButton(target: "#install-command", label: "Copy command")     # an element's value / text
#   CopyButton(value: url, variant: :outline, size: :sm, copied_label: "Copied!") { "Copy" }
#
# Takes every Button prop (ghost, small and square by default). A text label swaps to
# `copied_label:` while copied; the accessible name and a status message change too.
# `icon:` replaces the resting copy glyph. Emits `appica-ui--copy-button:copy` with { value } (or
# `:error`), and sets data-copied for `timeout:` ms.
class AppicaUI::CopyButton < AppicaUI::Base
  COPY = "M4.012 16.737c-.307-.175-.562-.427-.739-.732S3.001 15.353 3 15V5c0-1.1.9-2 2-2h10c.75 0 1.158.385 1.5 1M7 9.667c0-.707.281-1.386.781-1.886S8.96 7 9.667 7h8.666c.35 0 .697.069 1.021.203s.618.33.865.578.444.542.578.865A2.67 2.67 0 0 1 21 9.667v8.666a2.67 2.67 0 0 1-.781 1.886 2.67 2.67 0 0 1-1.886.781H9.667a2.67 2.67 0 0 1-1.021-.203c-.324-.134-.618-.331-.865-.578s-.444-.542-.578-.865S7 18.683 7 18.333V9.667z"

  prop :value,        default: -> { nil }
  prop :target,       default: -> { nil }
  prop :label,        default: -> { t(".copy") }
  prop :copied_label, default: -> { t(".copied") }
  prop :timeout,      default: -> { 2000 }
  prop :icon,         default: -> { nil }
  prop :variant,      default: -> { :ghost }
  prop :size,         default: -> { :sm }

  def view_template(&block)
    icon_only = block.nil?

    render AppicaUI::Button.new(**mix({
      variant: @variant, size: @size, icon: icon_only, aria_label: @label, title: @label,
      data: {
        slot: "copy-button", controller: "appica-ui--copy-button", action: "appica-ui--copy-button#copy",
        "appica-ui--copy-button-value-value": @value, "appica-ui--copy-button-target-value": @target, "appica-ui--copy-button-timeout-value": @timeout,
        "appica-ui--copy-button-label-value": @label, "appica-ui--copy-button-copied-label-value": @copied_label
      }
    }, @attributes.except(:class)), class: cn("group/copy", @attributes[:class])) do
      span(class: "grid place-items-center *:[grid-area:1/1]", data: ({ icon: "start" } unless icon_only)) do
        span(class: "grid place-items-center transition-[opacity,scale] delay-150 duration-150 ease-out group-data-copied/copy:delay-0 group-data-copied/copy:scale-50 group-data-copied/copy:opacity-0 motion-reduce:transition-none") do
          if @icon
            render AppicaUI::Icon.new(@icon)
          else
            svg(xmlns: "http://www.w3.org/2000/svg", viewBox: "0 0 24 24", fill: "none", stroke: "currentColor", stroke_width: "1.5", stroke_linecap: "round", stroke_linejoin: "round", aria_hidden: "true") { |s| s.path(d: COPY) }
          end
        end
        svg(xmlns: "http://www.w3.org/2000/svg", viewBox: "0 0 24 24", fill: "none", stroke: "currentColor", stroke_width: "1.5", stroke_linecap: "round", stroke_linejoin: "round", aria_hidden: "true") do |s|
          s.path(d: "M4.3 12.55 L9.25 17.5 L19.7 6.5", pathLength: "1", stroke_dasharray: "1 2",
            class: "[stroke-dashoffset:1.02] group-data-copied/copy:[stroke-dashoffset:0] transition-[stroke-dashoffset] duration-200 ease-in group-data-copied/copy:delay-100 group-data-copied/copy:duration-350 group-data-copied/copy:ease-out motion-reduce:transition-none")
        end
      end
      span(data: { "appica-ui--copy-button-target": "text" }, &block) if block
      span(role: "status", class: "sr-only", data: { "appica-ui--copy-button-target": "status" })
    end
  end
end
