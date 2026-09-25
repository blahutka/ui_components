# A menu of actions opened from a button.
#
#   DropdownMenu do
#     DropdownMenuTrigger { |trigger| Button(**trigger, variant: :outline) { "Open" } }
#     DropdownMenuContent do
#       DropdownMenuGroup do
#         DropdownMenuGroupLabel { "My Account" }
#         DropdownMenuItem { "Profile" }
#         DropdownMenuItem { "Billing" }
#       end
#       DropdownMenuSeparator()
#       DropdownMenuLinkItem(href: "/logout") { "Sign out" }
#     end
#   end
#
# The root shares `size:`; the popup (and any submenu) opens in the browser's top layer, placed
# by `side:` / `align:` on DropdownMenuContent and flipped at the viewport edge.
# `open_on_hover: true` opens it on hover. The `ui--dropdown-menu` controller handles the
# keyboard (arrows, Home / End, typeahead, → / ← for submenus, Escape), checkbox and radio items,
# and emits `select` { item, label }, `checked-change` { item, checked }, `value-change`
# { group, value } and `open-change` { open }.
class UI::DropdownMenu < UI::Base
  POPUP = "bg-background border-border-overlay fixed inset-auto m-0 hidden open:flex max-h-(--available-height) min-w-48 flex-col overflow-visible border p-0 shadow-2xl outline-none " \
    "motion-safe:transition-[opacity,scale] motion-safe:duration-200 motion-safe:ease-[cubic-bezier(0.175,0.885,0.32,1.5)] " \
    "data-starting-style:motion-safe:scale-90 data-starting-style:motion-safe:opacity-0 " \
    "data-ending-style:motion-safe:scale-95 data-ending-style:motion-safe:opacity-0 data-ending-style:motion-safe:duration-100 data-ending-style:motion-safe:ease-out"
  RADIUS = { sm: "rounded-md", md: "rounded-lg", lg: "rounded-xl" }.freeze
  LABELS = { sm: "px-2.5 pt-1.5 pb-1 text-xs", md: "px-3 pt-2 pb-1.25 text-sm", lg: "px-3.5 pt-2.5 pb-1.5 text-base" }.freeze
  GAPS = { sm: "gap-1", md: "gap-1.5", lg: "gap-1.5" }.freeze
  CHEVRONS = { sm: "size-4", md: "size-4.5", lg: "size-5" }.freeze

  prop :size,          one_of(%i[ sm md lg ], :md), default: -> { :md }
  prop :open_on_hover, default: -> { false }
  prop :delay,         default: -> { 100 }
  prop :close_delay,   default: -> { 100 }
  prop :id,            default: -> { "#{self.class.name.demodulize.underscore.dasherize}-#{SecureRandom.hex(4)}" }

  attr_reader :size, :id

  # The Stimulus controller and data-slot prefix of the parts (ContextMenu reuses them)
  def identifier = "ui--dropdown-menu"
  def slot = "dropdown-menu"

  def trigger_id = "#{@id}-trigger"
  def content_id = "#{@id}-content"

  def item_classes(*extra)
    [ UI::NavigationLink.style(:pill, @size), "w-full outline-hidden", *extra ].join(" ")
  end

  def popup_classes = "#{POPUP} #{RADIUS[@size]}"
  def label_classes = LABELS[@size]
  def gap = GAPS[@size]
  def chevron = CHEVRONS[@size]

  def view_template(&)
    provide(:ui_dropdown_menu, self) do
      div(**mix(defaults(id: @id, data: root_data), @attributes.except(:class)), class: cn("inline-flex w-fit", override: @attributes[:class]), &)
    end
  end

  private
    def root_data
      {
        slot:, controller: identifier,
        "#{identifier}-hover-value": @open_on_hover.to_s, "#{identifier}-delay-value": @delay, "#{identifier}-close-delay-value": @close_delay,
        action: "keydown->#{identifier}#key pointermove->#{identifier}#pointerMove click->#{identifier}#click " \
          "pointerenter->#{identifier}#enter pointerleave->#{identifier}#leave focusin->#{identifier}#highlight"
      }
    end
end
