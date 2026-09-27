# A brief, dismissible notification that stacks in a corner of the screen.
#
# Render one Toaster in your layout. Toasts come from the server (flash messages, Turbo
# Stream appends of UI::Toast) or from the browser: `UI.toast.add({ title: "Saved" })`, or a
# ToastTrigger button. Each auto-dismisses (5s by default), can be swiped away, and has a
# close button. Hover the stack to expand it.
#
# @label Toast
# @logical_path Status & Feedback
# @component UI::Toast
# @display width wide
# @display min_height 24rem
class UI::ToastPreview < UI::BasePreview
  # Props not in the Usage form (data, render blocks, generated ids): see ui_components:preview_params
  UNLISTED_PROPS = %i[ action timeout type progress id thumbnail priority dismissible close_label ].freeze

  # @label Usage
  # A ToastTrigger fires a toast with a title and description; it slides in, waits, and
  # dismisses itself.
  # @param title text
  # @param description text
  # @param icon [Symbol] select { choices: [none, success, error, warning, info, bell] }
  # @param position [Symbol] select { choices: [bottom_right, bottom_center, bottom_left, top_right, top_center, top_left] }
  def default(title: "Changes saved", description: "Your preferences have been updated.", icon: :none, position: :bottom_right)
    phlex do
      div(class: "flex justify-center") do
        ToastTrigger(toast: { title:, description:, icon: (icon.to_s unless icon.to_s == "none") }) { |trigger| Button(**trigger) { "Show toast" } }
      end
      Toaster(position:)
    end
  end

  # @label With an icon
  # `icon:` adds a filled, color-matched glyph (success, error, warning, info) while the
  # surface stays neutral.
  def icons
    phlex do
      div(class: "flex flex-wrap justify-center gap-2") do
        {
          "Success" => { title: "Payment received", description: "Invoice #1024 has been settled.", icon: "success" },
          "Error" => { title: "Upload failed", description: "The file exceeds the 25 MB limit.", icon: "error", priority: "high" },
          "Warning" => { title: "Storage almost full", description: "You have used 92% of your quota.", icon: "warning" },
          "Info" => { title: "Heads up", description: "Maintenance is scheduled for Sunday.", icon: "info" }
        }.each do |label, toast|
          ToastTrigger(toast:) { |trigger| Button(**trigger, variant: :outline) { label } }
        end
      end
      Toaster()
    end
  end

  # @label With a thumbnail
  # `thumbnail: true` wraps the icon in a tinted badge for more prominence.
  def thumbnails
    phlex do
      div(class: "flex flex-wrap justify-center gap-2") do
        {
          "Default" => { title: "New notification", description: "You have 3 unread messages.", icon: "bell", thumbnail: true },
          "Success" => { title: "Payment received", description: "Invoice #1024 has been settled.", icon: "success", thumbnail: true },
          "Error" => { title: "Upload failed", description: "The file exceeds the 25 MB limit.", icon: "error", thumbnail: true }
        }.each do |label, toast|
          ToastTrigger(toast:) { |trigger| Button(**trigger, variant: :outline) { label } }
        end
      end
      Toaster()
    end
  end

  # @label With an action
  # `action:` adds an inline button - "Undo", "Retry", "View". Here it fires a follow-up
  # toast; in an app give it `href:`, an `event:` name, or an `onClick` from JavaScript.
  def action
    phlex do
      div(class: "flex justify-center") do
        ToastTrigger(toast: { title: "Message archived", action: { label: "Undo", toast: { title: "Message restored" } } }) do |trigger|
          Button(**trigger, variant: :outline) { "Archive message" }
        end
      end
      Toaster()
    end
  end

  # `UI.toast.promise(promise, { loading, success, error })` swaps the content as the promise
  # settles. (This demo fails at random to show both outcomes.)
  def promise
    phlex do
      div(class: "flex justify-center") do
        Button(id: "toast-promise-demo") { "Save document" }
      end
      Toaster()
      script(type: "module") do
        raw safe(<<~JS)
          import { toast } from "ui/toast/toast"

          const save = () => new Promise((resolve, reject) =>
            setTimeout(() => (Math.random() > 0.3 ? resolve({ name: "report.pdf" }) : reject(new Error("Network error"))), 2000))

          document.getElementById("toast-promise-demo").addEventListener("click", () => {
            toast.promise(save(), {
              loading: { title: "Saving…", icon: "loading", thumbnail: true },
              success: file => ({ title: "Saved", description: `${file.name} is ready to share.`, icon: "success", thumbnail: true }),
              error: { title: "Could not save", description: "Check your connection and try again.", icon: "error", thumbnail: true }
            }).catch(() => {})
          })
        JS
      end
    end
  end

  # A toast can target any of the six corners and edges with `position:`; it swipes toward
  # its nearest edge to dismiss. (The Toaster's `position:` sets the default.)
  def positions
    phlex do
      div(class: "mx-auto grid max-w-md grid-cols-3 gap-2") do
        %w[ top-left top-center top-right bottom-left bottom-center bottom-right ].each do |position|
          ToastTrigger(toast: { title: "Notification", description: "Anchored #{position}.", position: }) do |trigger|
            Button(**trigger, variant: :outline, size: :sm) { position }
          end
        end
      end
      Toaster()
    end
  end

  # @label Timeout & progress
  # `timeout:` sets how long a toast lingers; `timeout: 0` keeps it until dismissed.
  # `progress: true` on the Toaster draws a countdown bar on auto-dismissing toasts.
  def timeout
    phlex do
      div(class: "flex flex-wrap justify-center gap-2") do
        ToastTrigger(toast: { title: "Auto-dismiss", description: "This toast closes in 6 seconds.", timeout: 6000 }) { |trigger| Button(**trigger, variant: :outline) { "Timed (6s)" } }
        ToastTrigger(toast: { title: "Stays put", description: "Set timeout to 0 to keep a toast until dismissed.", timeout: 0 }) { |trigger| Button(**trigger, variant: :outline) { "Persistent" } }
      end
      Toaster(progress: true)
    end
  end

  # @label Server-rendered (flash)
  # Toasts rendered with the page - e.g. from flash messages - animate in and time out like
  # any other. The same UI::Toast can be appended with a Turbo Stream.
  def server_rendered
    phlex do
      p(class: "text-foreground-muted text-center text-sm") { "Reload the preview to see the flash toasts arrive." }
      Toaster(toasts: [
        { title: "Signed in", description: "Welcome back, Sarah.", icon: :success },
        { title: "3 new comments", description: "On “Q3 roadmap”.", icon: :bell, thumbnail: true, timeout: 8000 }
      ])
    end
  end

  # @label RTL
  # The layout mirrors: the icon leads from the right, the close button moves to the left
  # and the progress bar drains in the reading direction.
  def rtl
    phlex do
      div(dir: "rtl", class: "flex justify-center") do
        ToastTrigger(toast: { title: "حفظ التغييرات", description: "تم تحديث تفضيلاتك.", icon: "success" }) { |trigger| Button(**trigger) { "حفظ التغييرات" } }
        Toaster(progress: true, dir: "rtl", id: "toaster-rtl")
      end
    end
  end
end
