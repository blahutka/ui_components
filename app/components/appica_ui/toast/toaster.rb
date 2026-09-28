# The toast viewport. Render it once, near the end of your layout's <body>:
#
#   Toaster()                                              # bottom-right, 5s, 3 visible
#   Toaster(position: :top_center, progress: true, toasts: flash_toasts)
#
# It renders a viewport per corner/edge (the default one has id="toaster" for Turbo
# Streams), any server-side toasts, and <template>s the `appica-ui--toaster` controller clones for
# toasts created in the browser with `AppicaUI.toast.add(...)`.
class AppicaUI::Toaster < AppicaUI::Base
  POSITIONS = %i[ top_left top_center top_right bottom_left bottom_center bottom_right ].freeze

  VIEWPORT = "fixed z-50 w-90 max-w-[calc(100vw-2rem)] outline-none"

  PLACEMENTS = {
    top_left: "top-4 left-4",
    top_center: "top-4 left-1/2 -translate-x-1/2",
    top_right: "top-4 right-4",
    bottom_left: "bottom-4 left-4",
    bottom_center: "bottom-4 left-1/2 -translate-x-1/2",
    bottom_right: "bottom-4 right-4"
  }.freeze

  attr_reader :id, :timeout

  prop :position, one_of(POSITIONS, :bottom_right), default: -> { :bottom_right }
  prop :progress, default: -> { false }
  prop :timeout,  default: -> { 5000 }
  prop :limit,    default: -> { 3 }
  prop :toasts,   default: -> { [] }
  prop :id,       default: -> { "toaster" }

  def view_template(&)
    div(**mix({
      id: "#{id}-root",
      data: {
        slot: "toaster",
        controller: "appica-ui--toaster",
        "appica-ui--toaster-position-value": dasherize(@position),
        "appica-ui--toaster-timeout-value": @timeout,
        "appica-ui--toaster-limit-value": @limit,
        "appica-ui--toaster-progress-value": @progress.to_s,
        action: "click@document->appica-ui--toaster#trigger"
      }
    }, @attributes)) do
      POSITIONS.each do |position|
        viewport(position) do
          if position == @position
            @toasts.each { |toast| render AppicaUI::Toast.new(**toast) }
            yield if block_given?
          end
        end
      end
      templates
    end
  end

  def progress? = @progress
  def side = @current_position.to_s.start_with?("top") ? "top" : "bottom"

  private
    def viewport(position, &)
      @current_position = position
      provide(:ui_toaster, self) do
        div(id: (position == @position ? id : "#{id}-#{dasherize(position)}"),
            role: "region", tabindex: "-1", aria: { live: "polite", atomic: "false", relevant: "additions text", label: "Notifications" },
            class: cn(VIEWPORT, PLACEMENTS[position]),
            data: {
              slot: "toast-viewport",
              position: dasherize(position),
              "appica-ui--toaster-target": "viewport",
              action: "pointerenter->appica-ui--toaster#expand pointerleave->appica-ui--toaster#collapse focusin->appica-ui--toaster#expand focusout->appica-ui--toaster#collapse"
            }, &)
      end
    end

    # Fully styled blanks for toasts created in the browser
    def templates
      @current_position = @position
      provide(:ui_toaster, self) do
        template(data: { "appica-ui--toaster-target": "template" }) do
          render AppicaUI::Toast.new(id: "toast-template", title: "", description: "", action: { label: "" }, progress: true, timeout: 1) { }
        end
        AppicaUI::ToastIcon::KINDS.each do |kind|
          [ false, true ].each do |thumbnail|
            template(data: { "appica-ui--toaster-target": "iconTemplate", kind:, thumbnail: thumbnail.to_s }) { render AppicaUI::ToastIcon.new(kind:, thumbnail:) }
          end
        end
      end
    end

    def dasherize(position) = position.to_s.dasherize
end
