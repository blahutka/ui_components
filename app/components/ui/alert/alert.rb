# A prominent, in-page message about a status or event - a banner that lives in the layout.
# (For transient notifications use Toast.)
#
#   Alert(variant: :info) do
#     AlertIcon { info_svg }
#     AlertTitle { "Scheduled maintenance" }
#     AlertDescription { "Some features may be unavailable Sunday night." }
#   end
#
# Parts are placed by a grid, so include only the ones you need. `layout: :inline` flows them
# onto one row once the container is wide enough. `dismissible: true` adds a close button that
# animates the alert out; `persist_key:` remembers the dismissal in local/session storage.
# `open: false` renders it closed - flip `data-ui--alert-open-value` to show it again.
class UI::Alert < UI::Base
  VARIANTS = {
    default: [ "bg-background border-border", "text-foreground-intense" ],
    primary: [ "bg-primary-subtle border-primary-soft", "text-primary" ],
    secondary: [ "bg-secondary-subtle border-secondary-soft", "text-secondary-emphasis" ],
    info: [ "bg-info-subtle border-info-soft", "text-info-emphasis" ],
    success: [ "bg-success-subtle border-success-soft", "text-success-emphasis" ],
    warning: [ "bg-warning-subtle border-warning-soft", "text-warning-emphasis" ],
    error: [ "bg-error-subtle border-error-soft", "text-error-emphasis" ]
  }.freeze

  BASE = "group/alert relative rounded-xl border p-5 text-foreground backdrop-blur-xl grid w-full items-start " \
    "[grid-template-columns:auto_1fr_auto] [grid-template-areas:'icon_title_close'_'._description_.'_'._actions_actions'] " \
    "@min-[460px]:data-[layout=inline]:items-center @min-[460px]:data-[layout=inline]:[grid-template-columns:auto_auto_1fr_auto_auto] " \
    "@min-[460px]:data-[layout=inline]:[grid-template-areas:'icon_title_description_actions_close']"

  CLOSE = "text-foreground-muted cursor-pointer rounded-md p-1 transition-colors outline-none [grid-area:close] hover:text-foreground-intense " \
    "focus-visible:ring-ring focus-visible:ring-2 self-start @min-[460px]:group-data-[layout=inline]/alert:self-center ms-3 -me-1 -mt-1 " \
    "@min-[460px]:group-data-[layout=inline]/alert:my-0"


  attr_reader :variant

  def initialize(variant: :default, layout: :block, dismissible: false, open: true, persist_key: nil, persist_storage: :local, close_label: "Dismiss", **attributes)
    @variant = VARIANTS.key?(variant.to_sym) ? variant.to_sym : :default
    @layout = layout.to_sym == :inline ? :inline : :block
    @dismissible = dismissible
    @open = open
    @persist_key, @persist_storage = persist_key, persist_storage
    @close_label = close_label
    @attributes = attributes
  end

  def icon_class
    VARIANTS[@variant].last
  end

  def view_template(&)
    # The outer box is the query container (for the inline layout) and what animates on dismiss
    div(class: "@container overflow-hidden", hidden: !@open, data: wrapper_data) do
      provide(:alert, self) do
        div(**mix(defaults(role: "alert", data: { slot: "alert", layout: @layout, variant: @variant }), @attributes.except(:class)),
          class: cn(BASE, VARIANTS[@variant].first, override: @attributes[:class])) do
          yield if block_given?
          close_button if @dismissible
        end
      end
    end
  end

  private
    def wrapper_data
      {
        controller: "ui--alert", "ui--alert-open-value": @open.to_s,
        "ui--alert-persist-key-value": @persist_key, "ui--alert-persist-storage-value": (@persist_storage.to_s if @persist_key)
      }
    end

    def close_button
      button(type: "button", aria_label: @close_label, data: { slot: "alert-close", action: "ui--alert#dismiss" }, class: CLOSE) do
        render UI::Icon.new(:x, stroke_width: 2, class: "size-4.5")
      end
    end
end
