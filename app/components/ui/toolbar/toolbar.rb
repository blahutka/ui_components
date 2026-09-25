# A strip of controls with one tab stop: the arrow keys move between its items along
# `orientation:`, Home / End jump to the ends. Too many items scroll instead of wrapping.
#
#   Toolbar(aria_label: "Formatting") do
#     ToolbarGroup(aria_label: "Text style") do
#       ToolbarButton { |item| Button(**item, variant: :ghost) { "Bold" } }
#       ToolbarButton { |item| Button(**item, variant: :ghost) { "Italic" } }
#     end
#     ToolbarSeparator()
#     ToolbarLink(href: "#help") { "Help" }
#   end
#
# Items hand their attributes to your own control (ToolbarButton → a Button, a Toggle, a
# SelectTrigger; ToolbarInput → an Input), so it keeps its look and joins the focus order.
class UI::Toolbar < UI::Base
  prop :orientation, one_of(%i[ horizontal vertical ], :horizontal), default: -> { :horizontal }
  prop :loop_focus,  default: -> { true }
  prop :disabled,    default: -> { false }

  attr_reader :orientation

  def disabled? = @disabled

  def view_template(&)
    provide(:ui_toolbar, self) do
      div(**mix(defaults(role: "toolbar", aria_orientation: @orientation, data: {
        slot: "toolbar", orientation: @orientation, disabled: ("" if @disabled), controller: "ui--toolbar",
        "ui--toolbar-loop-value": @loop_focus.to_s, action: "keydown->ui--toolbar#navigate focusin->ui--toolbar#track"
      }), @attributes.except(:class)),
        class: cn("bg-background flex w-fit items-center gap-1 rounded-lg border p-1 max-h-full max-w-full overflow-auto [scrollbar-width:none] *:shrink-0 [&::-webkit-scrollbar]:hidden " \
          "data-[orientation=vertical]:flex-col data-[orientation=vertical]:items-stretch", override: @attributes[:class]), &)
    end
  end
end
