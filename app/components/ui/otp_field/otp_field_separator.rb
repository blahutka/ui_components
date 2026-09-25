# A divider between groups of OTPField slots - a dash unless given content.
class UI::OTPFieldSeparator < UI::Base
  def view_template(&block)
    div(**mix({ role: "separator", aria_orientation: "horizontal", data: { slot: "otp-field-separator", orientation: "horizontal" } }, @attributes.except(:class)),
      class: cn("text-border-strong flex items-center justify-center w-4 [&_svg]:size-3.5", override: @attributes[:class])) do
      if block
        yield
      else
        svg(aria_hidden: "true", viewBox: "0 0 20 4", fill: "none") { |s| s.path(d: "M2 2H18", stroke: "currentColor", stroke_width: "2", stroke_linecap: "round") }
      end
    end
  end
end
