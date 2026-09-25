# One toast: a title, optional description, leading icon, action button and close button.
#
# Toasts live inside a Toaster. Render them on the server (flash messages, or appended with
# Turbo Streams: `turbo_stream.append "toaster", UI::Toast.new(title: "Saved")`), or create
# them in the browser with `UI.toast.add({ title: "Saved" })`. Either way the `ui--toaster`
# controller stacks, times, animates and dismisses them.
#
#   Toast(title: "Payment received", description: "Invoice #1024 has been settled.", icon: :success)
#   Toast(title: "Message archived", action: { label: "Undo", href: undo_path })
class UI::Toast < UI::Base
  BASE = "group/toast border-border-overlay bg-background text-foreground rounded-xl border p-4 text-sm backdrop-blur-xl " \
    "grid items-start gap-x-0 gap-y-2 has-data-[slot=toast-icon]:gap-x-3 grid-cols-[auto_1fr_auto] [grid-template-areas:'icon_title_close'] " \
    "has-data-[slot=toast-description]:[grid-template-areas:'icon_title_close'_'icon_description_close'] " \
    "has-data-[slot=toast-actions]:not-has-data-[slot=toast-description]:[grid-template-areas:'icon_title_close'_'icon_actions_actions'] " \
    "has-data-[slot=toast-actions]:has-data-[slot=toast-description]:[grid-template-areas:'icon_title_close'_'icon_description_close'_'icon_actions_actions'] " \
    "[--gap:0.75rem] [--peek:0.75rem] [--scale:calc(max(0,1-(var(--toast-index)*0.1)))] [--shrink:calc(1-var(--scale))] [--height:var(--toast-frontmost-height,var(--toast-height))] " \
    "absolute z-[calc(1000-var(--toast-index))] right-0 left-0 w-full select-none h-[var(--height)] data-expanded:h-[var(--toast-height)] " \
    "data-ending-style:opacity-0 data-limited:opacity-0 data-limited:pointer-events-none " \
    "[transition:transform_0.5s_cubic-bezier(0.22,1,0.36,1),opacity_0.5s,height_0.15s] motion-reduce:transition-none " \
    "after:absolute after:left-0 after:h-[calc(var(--gap)+1px)] after:w-full after:content-['']"

  # Bottom-anchored by default; data-side=top flips anchoring, shadow and stacking direction.
  # --sign folds Appica's separate top/bottom transforms into one set.
  SIDES = "[--sign:-1] bottom-0 origin-bottom shadow-[0_-8px_16px_-4px_var(--shadow-color)] after:top-full " \
    "data-[side=top]:[--sign:1] data-[side=top]:top-0 data-[side=top]:bottom-auto data-[side=top]:origin-top data-[side=top]:shadow-lg data-[side=top]:after:top-auto data-[side=top]:after:bottom-full"

  TRANSFORMS = "[--offset-y:calc(var(--sign)*(var(--toast-offset-y)+var(--toast-index)*var(--gap))+var(--toast-swipe-movement-y))] " \
    "[transform:translateX(var(--toast-swipe-movement-x))_translateY(calc(var(--toast-swipe-movement-y)+var(--sign)*(var(--toast-index)*var(--peek)+var(--shrink)*var(--height))))_scale(var(--scale))] " \
    "data-expanded:[transform:translateX(var(--toast-swipe-movement-x))_translateY(var(--offset-y))] " \
    "motion-safe:data-starting-style:[transform:translateY(calc(var(--sign)*-150%))] " \
    "motion-safe:[&[data-ending-style]:not([data-limited]):not([data-swipe-direction])]:[transform:translateY(calc(var(--sign)*-150%))] " \
    "motion-safe:data-ending-style:data-[swipe-direction=down]:[transform:translateY(calc(var(--toast-swipe-movement-y)+150%))] " \
    "motion-safe:data-ending-style:data-[swipe-direction=up]:[transform:translateY(calc(var(--toast-swipe-movement-y)-150%))] " \
    "motion-safe:data-ending-style:data-[swipe-direction=left]:[transform:translateX(calc(var(--toast-swipe-movement-x)-150%))_translateY(var(--offset-y))] " \
    "motion-safe:data-ending-style:data-[swipe-direction=right]:[transform:translateX(calc(var(--toast-swipe-movement-x)+150%))_translateY(var(--offset-y))]"

  ICON = "flex shrink-0 items-center [grid-area:icon] has-[>svg]:h-lh [&>svg:not([class*='size-'])]:size-5"
  TITLE = "text-foreground-intense flex w-full items-center gap-2 text-sm font-semibold [grid-area:title]"
  DESCRIPTION = "text-foreground text-sm [grid-area:description]"
  CLOSE = "text-foreground-muted -me-1 -mt-1 cursor-pointer self-start rounded-md p-1 outline-none [grid-area:close] motion-safe:transition-colors hover:text-foreground-intense focus-visible:ring-ring focus-visible:ring-2"
  PROGRESS_INDICATOR = "bg-primary absolute inset-x-0 bottom-0 h-1 origin-left rtl:origin-right animate-[toast-progress_linear_forwards] group-data-expanded/toast:[animation-play-state:paused] motion-reduce:animate-none"

  prop :title
  prop :description, default: -> { nil }
  prop :icon,        default: -> { nil }
  prop :thumbnail,   default: -> { false }
  prop :action,      default: -> { nil }
  prop :timeout,     default: -> { nil }
  prop :type,        default: -> { nil }
  prop :priority,    ->(value) { value.to_sym }, default: -> { :low }
  prop :dismissible, default: -> { true }
  prop :progress,    default: -> { nil }
  prop :close_label, default: -> { "Dismiss" }
  prop :id,          default: -> { "toast-#{SecureRandom.hex(4)}" }

  def view_template(&icon)
    div(**mix(toast_attributes, @attributes.except(:class)), class: cn(BASE, SIDES, TRANSFORMS, override: @attributes[:class])) do
      div(class: "contents") do
        if icon || @icon
          span(class: ICON, data: { slot: "toast-icon" }) do
            icon ? yield : render(UI::ToastIcon.new(kind: @icon, thumbnail: @thumbnail))
          end
        end
        h2(id: "#{@id}-title", class: TITLE, data: { slot: "toast-title" }) { @title }
        p(id: "#{@id}-description", class: DESCRIPTION, data: { slot: "toast-description" }) { @description } if @description
        actions if @action
        close_button if @dismissible
      end
      progress_bar if progress?
    end
  end

  private
    def toaster = context[:ui_toaster]

    # A toast's own timeout, else the Toaster's; 0 keeps it until dismissed
    def effective_timeout = (@timeout || toaster&.timeout || 5000).to_i

    def progress?
      (@progress.nil? ? toaster&.progress? : @progress) && effective_timeout.positive?
    end

    def toast_attributes
      {
        id: @id,
        role: (@priority == :high ? "alert" : "dialog"),
        tabindex: "0",
        aria: { modal: "false", labelledby: "#{@id}-title", describedby: ("#{@id}-description" if @description) },
        style: "--toast-index: 0; --toast-offset-y: 0px; --toast-swipe-movement-x: 0px; --toast-swipe-movement-y: 0px",
        data: {
          slot: "toast",
          side: toaster&.side,
          type: @type,
          timeout: (@timeout.to_i if @timeout),
          "ui--toaster-target": "toast",
          action: "pointerdown->ui--toaster#swipeStart"
        }
      }
    end

    # action: { label:, href: } links; { label:, toast: {...} } fires a follow-up toast;
    # { label:, event: "name" } dispatches a window event with { toast: id }
    def actions
      div(class: "flex justify-end gap-2 pt-2 [grid-area:actions]", data: { slot: "toast-actions" }) do
        render UI::Button.new(
          size: :sm, variant: @action.fetch(:variant, :primary), href: @action[:href],
          data: {
            slot: "toast-action",
            action: "ui--toaster#act",
            follow_up: (@action[:toast].to_json if @action[:toast]),
            event: @action[:event]
          }
        ) { @action[:label] }
      end
    end

    def close_button
      button(type: "button", aria: { hidden: "true", label: @close_label }, class: CLOSE, data: { slot: "toast-close", action: "ui--toaster#dismiss" }) do
        render UI::Icon.new(:x, stroke_width: 2, class: "size-4.5")
      end
    end

    def progress_bar
      div(class: "pointer-events-none absolute inset-x-0 bottom-0 h-4 overflow-hidden rounded-b-[inherit] motion-reduce:hidden", data: { slot: "toast-progress" }) do
        div(class: PROGRESS_INDICATOR, style: "animation-duration: #{effective_timeout}ms", data: { slot: "toast-progress-indicator" })
      end
    end
end
