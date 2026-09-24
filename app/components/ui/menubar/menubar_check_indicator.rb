# The animated check drawn at the end of a checkbox or radio item (Appica's indicator)
class UI::MenubarCheckIndicator < UI::Base
  PATH = "opacity-0 [stroke-dashoffset:1.02] group-data-checked/check:opacity-100 group-data-checked/check:[stroke-dashoffset:0] " \
    "motion-safe:transition-[opacity,stroke-dashoffset] motion-safe:ease-out motion-safe:delay-[0ms,150ms] motion-safe:duration-[150ms,0ms] " \
    "motion-safe:group-data-checked/check:delay-[0ms] motion-safe:group-data-checked/check:duration-[0ms,300ms]"

  def initialize(checked:, slot:)
    @checked, @slot = checked, slot
  end

  def view_template
    span(aria_hidden: "true", class: "group/check text-foreground-intense shrink-0", data: { slot: @slot, checked: (@checked ? "" : nil), unchecked: (@checked ? nil : "") }) do
      svg(xmlns: "http://www.w3.org/2000/svg", viewBox: "0 0 24 24", fill: "none", stroke: "currentColor", stroke_linecap: "round", stroke_linejoin: "round",
          aria_hidden: "true", class: "stroke-2 me-0.5 size-[1.125em]", data: { icon: "end" }) do |s|
        s.path(d: "M4.3 12.55 L9.25 17.5 L19.7 6.5", pathLength: "1", stroke_dasharray: "1 2", class: PATH)
      end
    end
  end
end
