# The panel: a native <dialog> (top layer, so no portal is needed) holding the
# backdrop, the framed card with its drag handle, and the corner close button.
# `class:` styles the panel, e.g. "mx-auto max-w-2xl" for a top/bottom sheet.
class UI::DrawerContent < UI::Base
  VIEWPORT = "fixed inset-0 z-50 m-0 hidden size-full max-h-none max-w-none overflow-hidden border-0 bg-transparent p-2 text-foreground open:flex backdrop:bg-transparent"
  VIEWPORT_SIDES = {
    top: "items-start justify-center",
    right: "items-stretch justify-end",
    bottom: "items-end justify-center",
    left: "items-stretch justify-start"
  }.freeze

  BACKDROP = "fixed inset-0 bg-black/30 backdrop-blur-sm supports-[-webkit-touch-callout:none]:absolute opacity-[calc(1-var(--drawer-swipe-progress))] " \
    "motion-safe:transition-opacity motion-safe:duration-400 motion-safe:ease-out data-ending-style:opacity-0 data-starting-style:opacity-0 data-swiping:duration-0"

  POPUP = "relative flex min-h-0 flex-col isolate outline-none " \
    "motion-safe:transition-[transform,height] motion-safe:duration-400 motion-safe:ease-[cubic-bezier(0.32,1.2,0.4,1)] " \
    "data-ending-style:motion-safe:duration-300 data-ending-style:motion-safe:ease-out data-nested-drawer-swiping:duration-0 data-swiping:duration-0 data-swiping:select-none " \
    "[--stack-progress:clamp(0,var(--drawer-swipe-progress,0),1)] [--stack-step:0.05] [--stack-count:max(0,calc(var(--nested-drawers,0)-var(--stack-progress)))] " \
    "[--stack-scale:clamp(0,calc(1-var(--stack-step)*var(--stack-count)),1)] [--stack-shrink:calc(1-var(--stack-scale))] " \
    "[--stack-peek:calc(var(--stack-count)*1.5rem)] [--stack-offset:calc(var(--stack-peek)+var(--stack-shrink)*var(--stack-extent))]"

  FRAME = "rounded-2xl border before:bg-background border-white/15 bg-white/10 p-1.5 backdrop-blur-sm"
  SOLID = "rounded-2xl border bg-background border-border-overlay before:bg-background-strong"
  SOLID_SHADOWS = {
    top: "shadow-[0_24px_32px_-12px_var(--shadow-color)]",
    right: "shadow-[-24px_0_32px_-12px_var(--shadow-color)]",
    bottom: "shadow-[0_-24px_32px_-12px_var(--shadow-color)]",
    left: "shadow-[24px_0_32px_-12px_var(--shadow-color)]"
  }.freeze

  # Drag handle placement + panel geometry and slide transforms per edge
  POPUP_SIDES = {
    top: "pb-4! before:absolute before:bottom-1.5 before:left-1/2 before:h-1 before:w-11.5 before:-translate-x-1/2 before:rounded-full " \
      "w-full origin-top [height:var(--drawer-height,auto)] max-h-full [--stack-extent:var(--drawer-frontmost-height,var(--drawer-height,0px))] " \
      "data-nested-drawer-open:[height:var(--drawer-frontmost-height,auto)] data-nested-drawer-open:overflow-hidden " \
      "[transform:translateY(calc(var(--drawer-swipe-movement-y)+var(--stack-offset)))_scale(var(--stack-scale))] " \
      "data-starting-style:[transform:translateY(calc(-100%-0.5rem))] data-ending-style:[transform:translateY(calc(-100%-0.5rem))]",
    right: "ps-4! before:absolute before:inset-s-1.5 before:top-1/2 before:h-11.5 before:w-1 before:-translate-y-1/2 before:rounded-full " \
      "h-full w-96 max-w-full origin-right [--stack-extent:25rem] " \
      "[transform:translateX(calc(var(--drawer-swipe-movement-x)-var(--stack-offset)))_scale(var(--stack-scale))] " \
      "data-starting-style:[transform:translateX(calc(100%+0.5rem))] data-ending-style:[transform:translateX(calc(100%+0.5rem))]",
    bottom: "pt-4! before:absolute before:top-1.5 before:left-1/2 before:h-1 before:w-11.5 before:-translate-x-1/2 before:rounded-full " \
      "w-full origin-bottom [height:var(--drawer-height,auto)] max-h-full [--stack-extent:var(--drawer-frontmost-height,var(--drawer-height,0px))] " \
      "data-nested-drawer-open:[height:var(--drawer-frontmost-height,auto)] data-nested-drawer-open:overflow-hidden " \
      "[transform:translateY(calc(var(--drawer-swipe-movement-y)-var(--stack-offset)))_scale(var(--stack-scale))] " \
      "data-starting-style:[transform:translateY(calc(100%+0.5rem))] data-ending-style:[transform:translateY(calc(100%+0.5rem))]",
    left: "pe-4! before:absolute before:inset-e-1.5 before:top-1/2 before:h-11.5 before:w-1 before:-translate-y-1/2 before:rounded-full " \
      "h-full w-96 max-w-full origin-left [--stack-extent:25rem] " \
      "[transform:translateX(calc(var(--drawer-swipe-movement-x)+var(--stack-offset)))_scale(var(--stack-scale))] " \
      "data-starting-style:[transform:translateX(calc(-100%-0.5rem))] data-ending-style:[transform:translateX(calc(-100%-0.5rem))]"
  }.freeze

  CONTENT = "relative flex min-h-0 flex-col flex-1 not-has-[>[data-slot=drawer-footer]]:pb-6 not-has-[>[data-slot=drawer-header]]:pt-6 [&>[data-slot=drawer-header]+[data-slot=drawer-footer]]:pt-0"
  CONTENT_FRAME = "bg-background rounded-[calc(var(--radius-2xl)*5/6)]"
  # A solid card keeps the handle inside it; pull the content back over the handle gutter
  CONTENT_SOLID = {
    top: "overflow-hidden [&>:not([data-slot=drawer-close-button])]:-mb-4",
    right: "overflow-hidden [&>:not([data-slot=drawer-close-button])]:-ms-4",
    bottom: "overflow-hidden [&>:not([data-slot=drawer-close-button])]:-mt-4",
    left: "overflow-hidden [&>:not([data-slot=drawer-close-button])]:-me-4"
  }.freeze

  def initialize(close_button: true, close_label: "Close", backdrop: nil, frame: true, **attributes)
    @close_button, @close_label = close_button, close_label
    @backdrop, @frame = backdrop, frame
    @attributes = attributes
  end

  def view_template(&)
    dialog(**viewport_attributes) do
      div(class: BACKDROP, style: "--drawer-swipe-progress: 0", data: { slot: "drawer-backdrop", "ui--drawer-target": "backdrop" }) if backdrop?

      div(**mix(popup_attributes, @attributes.except(:class)), class: cn(popup_classes, override: @attributes[:class])) do
        div(class: cn(CONTENT, framed? ? CONTENT_FRAME : CONTENT_SOLID[drawer.side]), data: { slot: "drawer-content", "ui--drawer-target": "content" }) do
          yield
          close_button if @close_button
        end
      end
    end
  end

  private
    def drawer = consume(:ui_drawer, component: "Drawer")

    # The backdrop defaults to on at the top level and off for nested drawers
    def backdrop? = @backdrop.nil? ? (!drawer.nested? && drawer.modal?) : @backdrop

    # The glass frame needs a backdrop behind it; without one the panel is a solid card
    def framed? = @frame && backdrop?

    def viewport_attributes
      {
        id: drawer.dialog_id,
        class: cn(VIEWPORT, VIEWPORT_SIDES[drawer.side]),
        aria: { labelledby: drawer.title_id, describedby: drawer.description_id },
        data: {
          slot: "drawer-viewport",
          "ui--drawer-target": "dialog",
          action: "cancel->ui--drawer#cancel click->ui--drawer#dismiss"
        }
      }
    end

    def popup_attributes
      {
        tabindex: "-1",
        style: "--drawer-swipe-movement-x: 0px; --drawer-swipe-movement-y: 0px; --drawer-swipe-progress: 0; --nested-drawers: 0",
        data: {
          slot: "drawer-popup",
          frame: (framed? ? "" : nil),
          nested: (drawer.nested? ? "" : nil),
          swipe_direction: drawer.side,
          "ui--drawer-target": "popup",
          action: "pointerdown->ui--drawer#swipeStart"
        }
      }
    end

    def popup_classes
      [ POPUP, framed? ? FRAME : "#{SOLID} #{SOLID_SHADOWS[drawer.side]}", POPUP_SIDES[drawer.side] ]
    end

    def close_button
      render UI::Button.new(
        variant: :outline, size: :sm, icon: true, aria_label: @close_label,
        class: "absolute inset-e-3 top-3 z-10",
        data: { slot: "drawer-close-button", action: "ui--drawer#close" }
      ) do
        render UI::Icon.new(:x, stroke_width: 2)
      end
    end
end
