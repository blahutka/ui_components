# The modal: a native <dialog> covering the viewport, with the backdrop and the centered card
# (a frosted frame around it unless `frame: false`), plus a corner close button
# (`close_button: false` to drop it). `class:` styles the card - e.g. "sm:w-100" or "h-138".
class UI::DialogContent < UI::Base
  VIEWPORT = "fixed inset-0 z-50 m-0 hidden size-full max-h-none max-w-none items-center justify-center overflow-hidden border-0 bg-transparent p-4 text-foreground open:flex backdrop:bg-transparent"
  BACKDROP = "fixed inset-0 bg-black/30 backdrop-blur-sm supports-[-webkit-touch-callout:none]:absolute " \
    "motion-safe:transition-opacity motion-safe:duration-250 motion-safe:ease-out data-ending-style:motion-safe:opacity-0 data-starting-style:motion-safe:opacity-0"
  POPUP = "relative flex max-h-full min-h-0 max-w-full flex-col rounded-2xl border isolate transform-gpu outline-none " \
    "motion-safe:transition-[opacity,scale] motion-safe:duration-250 motion-safe:ease-[cubic-bezier(0.175,0.885,0.32,1.5)] " \
    "data-starting-style:motion-safe:scale-95 data-starting-style:motion-safe:opacity-0 " \
    "data-ending-style:motion-safe:scale-95 data-ending-style:motion-safe:opacity-0 data-ending-style:motion-safe:duration-100 data-ending-style:motion-safe:ease-out " \
    "data-nested-dialog-open:pointer-events-none data-nested-dialog-open:scale-95 data-nested-dialog-open:opacity-0"
  FRAME = "border-white/15 bg-white/10 p-1.5 backdrop-blur-sm"
  SOLID = "bg-background border-border-overlay shadow-2xl"
  CLOSE = "M11.594 3.594c.225-.225.588-.225.813 0s.225.588 0 .812L8.813 8l3.594 3.594c.225.225.225.588 0 .813s-.588.225-.812 0L8 8.812l-3.594 3.594c-.225.225-.588.225-.812 0s-.225-.588 0-.812L7.188 8 3.594 4.406c-.225-.225-.225-.588 0-.812s.588-.225.813 0L8 7.187l3.594-3.594z"

  prop :close_button, default: -> { true }
  prop :close_label,  default: -> { t("ui_components.ui.dialog.close") }
  prop :backdrop,     default: -> { true }
  prop :frame,        default: -> { true }

  def view_template(&)
    dialog = consume(:ui_dialog, component: "Dialog")
    framed = @frame && @backdrop
    slot = dialog.slot

    dialog_element(dialog) do
      div(class: BACKDROP, data: { slot: "#{slot}-backdrop", "#{dialog.identifier}-target": "backdrop" }) if @backdrop
      div(**mix({
        id: dialog.popup_id, role: dialog.role, aria_modal: "true", aria_labelledby: dialog.title_id, aria_describedby: dialog.description_id,
        data: { slot: "#{slot}-popup", frame: ("" if framed), "#{dialog.identifier}-target": "popup" }
      }, @attributes.except(:class)),
        class: cn("group/#{slot}-popup", POPUP, width, (framed ? FRAME : SOLID), override: @attributes[:class])) do
        div(data: { slot: "#{slot}-content" },
          class: cn("relative flex min-h-0 flex-1 flex-col overflow-hidden not-has-[>[data-slot=#{slot}-footer]]:pb-6 not-has-[>[data-slot=#{slot}-header]]:pt-6 " \
            "[&>[data-slot=#{slot}-header]+[data-slot=#{slot}-footer]]:pt-0", ("bg-background rounded-[calc(var(--radius-2xl)*5/6)]" if framed))) do
          yield
          close_button(dialog) if @close_button
        end
      end
    end
  end

  private
    def width = "w-150"

    def dialog_element(dialog, &)
      dialog(data: {
        slot: "#{dialog.slot}-viewport", "#{dialog.identifier}-target": "dialog",
        action: "cancel->#{dialog.identifier}#cancel click->#{dialog.identifier}#outside"
      }, class: VIEWPORT, &)
    end

    def close_button(dialog)
      button(type: "button", aria_label: @close_label, data: { slot: "#{dialog.slot}-close-button", action: "#{dialog.identifier}#close" },
        class: cn(UI::Button::BASE, UI::Button::VARIANTS[:outline], UI::Button::ICON_SIZES[:sm], "absolute inset-e-3 top-3 z-10")) do
        svg(xmlns: "http://www.w3.org/2000/svg", viewBox: "0 0 16 16", fill: "currentColor", aria_hidden: "true") { |s| s.path(d: CLOSE) }
      end
    end
end
