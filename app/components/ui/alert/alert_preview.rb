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
  # Props not in the Usage form (data, render blocks, generated ids): see ui_components:preview_params
  UNLISTED_PROPS = %i[ persist_key ].freeze

  VARIANTS = [
    [ :default, :bell, "Update available", "Version 2.4 is ready to install." ],
    [ :primary, :sparkle_filled, "New feature", "You can now schedule reports to run weekly." ],
    [ :secondary, :info_circle_filled, "Did you know?", "Press ⌘K to search from anywhere." ],
    [ :info, :info_circle_filled, "Maintenance window", "We will be offline Sunday 02:00-03:00 UTC." ],
    [ :success, :circle_check_filled, "Payment received", "Your invoice has been settled." ],
    [ :warning, :alert_triangle_filled, "Storage almost full", "You have used 92% of your quota." ],
    [ :error, :circle_x_filled, "Payment failed", "We could not charge your card on file." ]
  ].freeze

  # @label Usage
  # The neutral default variant with an icon, title and description. Change the variant,
  # layout and dismiss button live.
  # @param variant [Symbol] select {{ choices_for UI::Alert, :variant }}
  # @param layout [Symbol] select {{ choices_for UI::Alert, :layout }}
  # @param dismissible [Boolean] toggle
  # @param title text
  # @param description text
  # @param open [Boolean] toggle
  # @param persist_storage text
  # @param close_label text
  def default(variant: :default, layout: :block, dismissible: false, title: "Heads up", description: "A new version of the dashboard is available - refresh to pick up the latest features.", open: true, persist_storage: "local", close_label: "Dismiss")
    icon = variant.to_sym == :default ? :info_circle : :info_circle_filled

    phlex do
      div(class: "w-full max-w-md") do
        Alert(variant:, layout:, dismissible:, open:, persist_storage:, close_label:) do
          AlertIcon { Icon(icon) }
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
            AlertIcon { Icon(icon) }
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
          AlertIcon { Icon(:info_circle_filled) }
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
          AlertIcon { Icon(:alert_triangle_filled) }
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
          AlertIcon { Icon(:circle_check_filled) }
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
            AlertIcon { Icon(:info_circle_filled) }
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
          AlertIcon { Icon(:alert_triangle_filled) }
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
end
