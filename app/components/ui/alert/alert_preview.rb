# A prominent, in-page message that draws attention to a status or event.
#
# A banner that sits inline with your content - a status, a heads-up, a result. Compose it
# from AlertIcon, AlertTitle, AlertDescription and AlertAction; a grid places whichever parts
# you include. For transient notifications reach for a Toast instead.
#
# @label Alert
# @logical_path Status & Feedback
# @component UI::Alert
# @display width wide
class UI::AlertPreview < UI::BasePreview
  # Appica's icons: outlined (stroke) and filled glyphs
  OUTLINED = {
    bell: "M9 17v1a3 3 0 0 0 6 0v-1M10 5a2 2 0 1 1 4 0 7 7 0 0 1 4 6v3a4 4 0 0 0 2 3H4a4 4 0 0 0 2-3v-3a7 7 0 0 1 4-6",
    info: "M12 9h.01M11 12h1v4h1M3 12a9 9 0 1 0 18.001 0A9 9 0 0 0 3 12"
  }.freeze

  FILLED = {
    sparkle: "M12.847 3.581c-.135-.35-.471-.581-.846-.581a.91.91 0 0 0-.846.581l-1.65 4.291a2.84 2.84 0 0 1-1.633 1.632l-4.29 1.65c-.171.066-.318.182-.422.333S3 11.817 3 12s.056.362.159.513.251.267.422.333l4.291 1.65a2.84 2.84 0 0 1 1.632 1.633l1.65 4.29c.066.171.182.318.333.422s.33.16.513.16.362-.056.513-.16.267-.251.333-.422l1.65-4.291a2.84 2.84 0 0 1 1.633-1.632l4.29-1.65c.171-.066.318-.182.422-.333s.16-.33.16-.513-.056-.362-.16-.513-.251-.267-.422-.333l-4.291-1.65a2.85 2.85 0 0 1-1.632-1.633l-1.65-4.29z",
    info: "M12 2.25c5.385 0 9.75 4.363 9.75 9.746a9.744 9.744 0 0 1-9.592 9.753 9.75 9.75 0 0 1-9.903-9.437l-.005-.316.004-.273C2.398 6.467 6.706 2.25 12 2.25m0 8.772h-.975l-.114.006a.974.974 0 0 0 0 1.936l.114.007v2.924l.007.114a.974.974 0 0 0 .854.853l.114.007h.975l.114-.007a.975.975 0 0 0 .854-.853l.007-.114-.007-.114a.97.97 0 0 0-.745-.836l-.109-.02-.114-.005v-2.924l-.007-.114a.975.975 0 0 0-.854-.854zm.01-2.924-.124.007a.975.975 0 0 0 0 1.935l.114.007.124-.007a.975.975 0 0 0 0-1.935z",
    success: "M16.875 3.556a9.75 9.75 0 1 1-14.62 8.76L2.25 12l.005-.316a9.75 9.75 0 0 1 14.62-8.128m-1.26 5.805a.975.975 0 0 0-1.287-.081l-.092.08-3.21 3.21-1.262-1.26-.091-.08a.975.975 0 0 0-1.368 1.368l.08.091 1.95 1.95.092.081a.975.975 0 0 0 1.196 0l.091-.08 3.9-3.9.081-.092a.975.975 0 0 0-.08-1.287",
    warning: "M12 2.5c.955 0 1.845.46 2.39 1.226l.105.157 8.115 13.32a2.83 2.83 0 0 1 .052 2.771c-.23.429-.568.793-.98 1.058a2.95 2.95 0 0 1-1.38.46l-.195.008H3.881a2.95 2.95 0 0 1-1.403-.372 2.9 2.9 0 0 1-1.046-.992 2.83 2.83 0 0 1-.133-2.765l.1-.182 8.11-13.31c.26-.42.625-.769 1.061-1.01A2.95 2.95 0 0 1 12 2.5m.01 13.105-.127.007a1 1 0 0 0-.63.323.974.974 0 0 0 0 1.306c.163.18.387.295.63.323l.117.007.127-.007c.243-.028.467-.143.63-.323a.973.973 0 0 0 0-1.306 1 1 0 0 0-.63-.323zM12 8.723a1 1 0 0 0-.665.249c-.183.16-.3.38-.328.62L11 9.705v3.933l.007.115c.029.239.146.46.329.619a1.01 1.01 0 0 0 1.328 0c.183-.16.3-.38.329-.62L13 13.64V9.706l-.007-.115a.98.98 0 0 0-.329-.62A1 1 0 0 0 12 8.724",
    error: "M16.875 3.556a9.75 9.75 0 1 1-14.62 8.76L2.25 12l.005-.316a9.75 9.75 0 0 1 14.62-8.128m-6.327 5.655a.975.975 0 0 0-1.187 1.528L10.62 12l-1.26 1.262-.081.091a.975.975 0 0 0 1.46 1.287L12 13.38l1.26 1.26.092.081a.974.974 0 0 0 1.287-1.46L13.38 12l1.26-1.26.081-.092a.975.975 0 0 0-1.46-1.287L12 10.62l-1.26-1.26-.092-.081z"
  }.freeze

  VARIANTS = [
    [ :default, [ :outlined, :bell ], "Update available", "Version 2.4 is ready to install." ],
    [ :primary, [ :filled, :sparkle ], "New feature", "You can now schedule reports to run weekly." ],
    [ :secondary, [ :filled, :info ], "Did you know?", "Press ⌘K to search from anywhere." ],
    [ :info, [ :filled, :info ], "Maintenance window", "We will be offline Sunday 02:00-03:00 UTC." ],
    [ :success, [ :filled, :success ], "Payment received", "Your invoice has been settled." ],
    [ :warning, [ :filled, :warning ], "Storage almost full", "You have used 92% of your quota." ],
    [ :error, [ :filled, :error ], "Payment failed", "We could not charge your card on file." ]
  ].freeze

  # @label Usage
  # The neutral default variant with an icon, title and description. Change the variant,
  # layout and dismiss button live.
  # @param variant [Symbol] select { choices: [default, primary, secondary, info, success, warning, error] }
  # @param layout [Symbol] select { choices: [block, inline] }
  # @param dismissible [Boolean] toggle
  # @param title text
  # @param description text
  def default(variant: :default, layout: :block, dismissible: false, title: "Heads up", description: "A new version of the dashboard is available - refresh to pick up the latest features.")
    icon = variant.to_sym == :default ? :outlined : :filled

    phlex do
      div(class: "w-full max-w-md") do
        Alert(variant:, layout:, dismissible:) do
          AlertIcon { render Icon.new(icon, :info) }
          AlertTitle { title }
          AlertDescription { description }
        end
      end
    end
  end

  # Seven variants color the alert for its purpose; the AlertIcon inherits the accent.
  def variants
    phlex do
      div(class: "flex w-full max-w-md flex-col gap-3") do
        VARIANTS.each do |variant, icon, title, description|
          Alert(variant:) do
            AlertIcon { render Icon.new(*icon) }
            AlertTitle { title }
            AlertDescription { description }
          end
        end
      end
    end
  end

  # @label Inline layout
  # `layout: :inline` flows the icon, title and description onto one row once there's room.
  # The alert is container-query aware, so it stacks again when narrow - try the mobile viewport.
  def inline
    phlex do
      div(class: "w-full max-w-xl") do
        Alert(layout: :inline, variant: :info) do
          AlertIcon { render Icon.new(:filled, :info) }
          AlertTitle { "Scheduled maintenance" }
          AlertDescription { "Some features may be unavailable Sunday night." }
        end
      end
    end
  end

  # @label With actions
  # An AlertAction row holds buttons - below the text in the block layout, trailing inline.
  def actions
    phlex do
      div(class: "w-full max-w-md") do
        Alert(variant: :warning) do
          AlertIcon { render Icon.new(:filled, :warning) }
          AlertTitle { "Your trial ends in 3 days" }
          AlertDescription { "Upgrade now to keep access to your projects and team members." }
          AlertAction do
            Button(variant: :ghost, size: :sm, class: "hover:before:bg-background") { "Maybe later" }
            Button(size: :sm) { "Upgrade" }
          end
        end
      end
    end
  end

  # `dismissible: true` adds a close button; the alert animates out when closed. Give it a
  # `persist_key:` to remember the dismissal across visits (localStorage, or
  # `persist_storage: :session`).
  def dismissible
    phlex do
      div(class: "w-full max-w-md") do
        Alert(variant: :success, dismissible: true) do
          AlertIcon { render Icon.new(:filled, :success) }
          AlertTitle { "Profile updated" }
          AlertDescription { "Your changes have been saved. You can dismiss this message." }
        end
      end
    end
  end

  # Drive visibility from outside through `data-ui--alert-open-value`, and listen for
  # `ui--alert:open-change` - here to offer a button that brings a dismissed alert back.
  def controlled
    phlex do
      div(class: "flex w-full max-w-md flex-col items-center gap-4") do
        div(class: "w-full") do
          Alert(variant: :info, dismissible: true, id: "controlled-alert") do
            AlertIcon { render Icon.new(:filled, :info) }
            AlertTitle { "Good to know" }
            AlertDescription { "This banner is controlled. Dismiss it and bring it back below." }
          end
        end
        Button(variant: :outline, size: :sm, id: "show-alert", hidden: true) { "Show alert" }
      end
      script(type: "module") do
        raw safe(<<~JS)
          const box = document.getElementById("controlled-alert").parentElement
          const show = document.getElementById("show-alert")

          box.addEventListener("ui--alert:open-change", ({ detail }) => show.hidden = detail.open)
          show.addEventListener("click", () => box.setAttribute("data-ui--alert-open-value", "true"))
        JS
      end
    end
  end

  # @label RTL
  # The icon moves to the right, the dismiss button to the left and the actions align to the
  # start edge - all from logical properties.
  def rtl
    phlex do
      div(dir: "rtl", class: "w-full max-w-md") do
        Alert(variant: :warning, dismissible: true, close_label: "إغلاق") do
          AlertIcon { render Icon.new(:filled, :warning) }
          AlertTitle { "تنتهي تجربتك خلال 3 أيام" }
          AlertDescription { "قم بالترقية الآن للحفاظ على الوصول إلى مشاريعك وأعضاء فريقك." }
          AlertAction do
            Button(variant: :ghost, size: :sm, class: "hover:before:bg-background") { "لاحقًا" }
            Button(size: :sm) { "ترقية" }
          end
        end
      end
    end
  end

  # One of Appica's icons, outlined or filled
  class Icon < UI::Base
    def initialize(style, name)
      @style, @name = style, name
    end

    def view_template
      if @style == :outlined
        svg(viewBox: "0 0 24 24", fill: "none", stroke: "currentColor", stroke_width: "1.5", stroke_linecap: "round", stroke_linejoin: "round", aria_hidden: "true") { |s| s.path(d: OUTLINED.fetch(@name)) }
      else
        svg(viewBox: "0 0 24 24", fill: "currentColor", aria_hidden: "true") { |s| s.path(d: FILLED.fetch(@name)) }
      end
    end
  end
end
