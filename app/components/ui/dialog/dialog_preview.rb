# A focused task or content that interrupts the page, in a centered modal.
#
# @label Dialog
# @logical_path Overlays
# @component UI::Dialog
# @display width wide
class UI::DialogPreview < UI::BasePreview
  # Props not in the Usage form (data, render blocks, generated ids): see ui_components:preview_params
  UNLISTED_PROPS = %i[ id ].freeze

  # @label Usage
  # @param frame [Boolean] toggle
  # @param close_button [Boolean] toggle
  # @param dismissible [Boolean] toggle
  # @param default_open [Boolean] toggle
  # @param modal [Boolean] toggle
  def default(frame: true, close_button: true, dismissible: true, default_open: false, modal: true)
    phlex do
      Dialog(dismissible:, default_open:, modal:) do
        DialogTrigger { |trigger| Button(**trigger, variant: :outline) { "Invite people" } }
        DialogContent(frame:, close_button:, class: "sm:w-110") do
          DialogHeader do
            DialogTitle { "Invite your team" }
            DialogDescription { "Send an invitation by email. They'll get access as soon as they accept." }
          end
          DialogBody do
            Field { FieldLabel { "Email addresses" }; Input(type: "email", placeholder: "name@company.com") }
          end
          DialogFooter do
            DialogClose { |close| Button(**close, variant: :soft) { "Cancel" } }
            DialogClose { |close| Button(**close) { "Send invites" } }
          end
        end
      end
    end
  end

  # @label Form dialog
  # A header, a body of Fields and a footer of actions.
  def form
    phlex do
      Dialog do
        DialogTrigger { |trigger| Button(**trigger, variant: :outline) { "Edit profile" } }
        DialogContent(class: "sm:w-110") do
          DialogHeader do
            DialogTitle { "Edit profile" }
            DialogDescription { "Update how you appear across the workspace. Changes are visible to your team." }
          end
          DialogBody(class: "flex flex-col gap-4") do
            Field { FieldLabel { "Display name" }; Input(value: "Sarah Jenkins") }
            Field { FieldLabel { "Email" }; Input(type: "email", value: "sarah@appica.dev") }
            Field { FieldLabel { "Bio" }; Textarea(rows: 3, value: "Product designer focused on design systems and accessibility.") }
          end
          DialogFooter do
            DialogClose { |close| Button(**close, variant: :soft) { "Cancel" } }
            DialogClose { |close| Button(**close) { "Save changes" } }
          end
        end
      end
    end
  end

  # The card is `w-150` by default; `class:` sets another width - it always shrinks to fit.
  def sizing
    phlex do
      div(class: "flex flex-wrap items-center justify-center gap-3") do
        { "Small" => [ "sm:w-100", "400px" ], "Default" => [ nil, "600px" ], "Large" => [ "sm:w-200", "800px" ] }.each do |label, (width, pixels)|
          Dialog do
            DialogTrigger { |trigger| Button(**trigger, variant: :outline) { label } }
            DialogContent(class: width) do
              DialogHeader do
                DialogTitle { "#{label} dialog" }
                DialogDescription { width ? "Set with class: \"#{width}\" (#{pixels})." : "The default width is #{pixels}." }
              end
              DialogBody { p { "Every dialog also carries max-w-full, so it shrinks to fit narrow screens instead of overflowing." } }
              DialogFooter { DialogClose { |close| Button(**close, variant: :outline) { "Close" } } }
            end
          end
        end
      end
    end
  end

  # @label Scrollable content
  # A fixed height with a scrolling body between the pinned header and footer.
  def scrollable
    sections = [
      [ "1. Acceptance of terms", "By accessing or using the service you agree to be bound by these terms. If you are entering into this agreement on behalf of a company, you represent that you have the authority to bind that company." ],
      [ "2. Accounts", "You are responsible for safeguarding the credentials you use to access the service and for any activity under your account." ],
      [ "3. Acceptable use", "You agree not to misuse the service: no probing, scanning, or testing the vulnerability of any system." ],
      [ "4. Content", "You retain ownership of the content you submit and grant us a license to host and display it to operate the service." ],
      [ "5. Subscriptions", "Paid plans renew automatically at the end of each billing cycle unless canceled beforehand." ],
      [ "6. Termination", "We may suspend or terminate your access if you breach these terms. You may stop using the service at any time." ],
      [ "7. Disclaimers", "The service is provided \"as is\" without warranties of any kind, whether express or implied." ],
      [ "8. Changes", "We may revise these terms from time to time. Material changes will be communicated in advance." ]
    ]
    phlex do
      Dialog do
        DialogTrigger { |trigger| Button(**trigger, variant: :outline) { "Review terms" } }
        DialogContent(class: "h-138 sm:w-130") do
          DialogHeader do
            DialogTitle { "Terms of Service" }
            DialogDescription { "Last updated June 27, 2026" }
          end
          div(class: "min-h-0 flex-1 overflow-y-auto") do
            div(class: "flex flex-col gap-5 px-6 pb-2") do
              sections.each do |title, body|
                section(class: "flex flex-col gap-1.5") do
                  h3(class: "text-foreground-intense font-medium") { title }
                  p { body }
                end
              end
            end
          end
          DialogFooter do
            DialogClose { |close| Button(**close, variant: :outline) { "Decline" } }
            DialogClose { |close| Button(**close) { "Accept" } }
          end
        end
      end
    end
  end

  # @label Nested dialogs
  # A Dialog inside another's content stacks on top; the parent steps back until it closes.
  ROW = proc do |label, value, action = nil|
    div(class: "border-border-muted flex items-center justify-between gap-4 border-b py-3 last:border-b-0") do
      div(class: "flex min-w-0 flex-col") do
        span(class: "text-foreground-intense font-medium") { label }
        span(class: "truncate text-sm") { value.is_a?(Proc) ? instance_exec(&value) : value }
      end
      instance_exec(&action) if action
    end
  end

  def nested
    phlex do
      Dialog do
        DialogTrigger { |trigger| Button(**trigger, variant: :outline) { "Account settings" } }
        DialogContent(class: "sm:w-110") do
          DialogHeader do
            DialogTitle { "Account & security" }
            DialogDescription { "Manage how you sign in and keep your account safe." }
          end
          DialogBody do
            instance_exec("Email", "ada@appica.dev", &ROW)
            change_password = proc do
              Dialog do
                DialogTrigger { |trigger| Button(**trigger, variant: :soft, size: :sm) { "Change" } }
                DialogContent(class: "sm:w-110") do
                  DialogHeader do
                    DialogTitle { "Change password" }
                    DialogDescription { "Use at least 8 characters, including a number." }
                  end
                  DialogBody(class: "flex flex-col gap-4") do
                    Field { FieldLabel { "Current password" }; Input(type: "password", autocomplete: "new-password", value: "opensesame") }
                    Field { FieldLabel { "New password" }; Input(type: "password", autocomplete: "new-password", value: "correct-horse") }
                  end
                  DialogFooter do
                    DialogClose { |close| Button(**close, variant: :soft) { "Cancel" } }
                    DialogClose { |close| Button(**close) { "Update password" } }
                  end
                end
              end
            end
            instance_exec("Password", "Last changed 3 months ago", change_password, &ROW)
            instance_exec("Two-factor auth", proc { Badge(variant: :success) { "Enabled" } }, &ROW)
            instance_exec("Active sessions", "2 devices", &ROW)
          end
          DialogFooter { DialogClose { |close| Button(**close) { "Done" } } }
        end
      end
    end
  end

  # @label Opened by the server
  # `default_open: true` renders it open - e.g. a dialog a Turbo Stream appends to the page, or a
  # form re-rendered with errors. Dispatch `ui--dialog:open` / `ui--dialog:close` to drive it.
  def server_open
    phlex do
      div(class: "flex gap-3") do
        Button(variant: :outline, data: { demo: "open" }) { "Open from elsewhere" }
        Dialog(id: "remote-dialog") do
          DialogContent(class: "sm:w-100") do
            DialogHeader do
              DialogTitle { "Opened by an event" }
              DialogDescription { "This dialog has no trigger - a script dispatched ui--dialog:open on it." }
            end
            DialogFooter { DialogClose { |close| Button(**close) { "Got it" } } }
          end
        end
      end
      script(type: "module") do
        raw safe(%(document.querySelector("[data-demo=open]").addEventListener("click", () => document.getElementById("remote-dialog").dispatchEvent(new Event("ui--dialog:open")))))
      end
    end
  end

  # @label RTL
  def rtl
    phlex do
      div(dir: "rtl") do
        Dialog do
          DialogTrigger { |trigger| Button(**trigger, variant: :outline) { "دعوة أشخاص" } }
          DialogContent(close_label: "إغلاق", class: "sm:w-110") do
            DialogHeader do
              DialogTitle { "ادعُ فريقك" }
              DialogDescription { "أرسل دعوة عبر البريد الإلكتروني." }
            end
            DialogBody { Input(type: "email", placeholder: "name@company.com", aria_label: "البريد الإلكتروني") }
            DialogFooter do
              DialogClose { |close| Button(**close, variant: :soft) { "إلغاء" } }
              DialogClose { |close| Button(**close) { "إرسال" } }
            end
          end
        end
      end
    end
  end
end
