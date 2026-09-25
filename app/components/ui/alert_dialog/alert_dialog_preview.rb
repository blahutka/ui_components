# A dialog that demands a response - for destructive or high-stakes confirmations.
#
# @label Alert Dialog
# @logical_path Overlays
# @component UI::AlertDialog
# @display width wide
class UI::AlertDialogPreview < UI::BasePreview
  # @label Destructive confirmation
  # The confirm button uses the destructive variant; cancel comes first. Clicking outside doesn't
  # close it - Escape or a button does.
  def default
    phlex do
      AlertDialog do
        AlertDialogTrigger { |trigger| Button(**trigger, variant: :destructive) { "Delete project" } }
        AlertDialogContent do
          AlertDialogHeader do
            AlertDialogTitle { "Delete this project?" }
            AlertDialogDescription { "Orbit and all of its files will be permanently deleted. This can't be undone." }
          end
          AlertDialogFooter do
            AlertDialogClose { |close| Button(**close, variant: :outline) { "Cancel" } }
            AlertDialogClose { |close| Button(**close, variant: :destructive) { "Delete" } }
          end
        end
      end
    end
  end

  # @label With media
  # An icon above a centered header, with full-width actions.
  def media
    phlex do
      AlertDialog do
        AlertDialogTrigger { |trigger| Button(**trigger, variant: :outline) { "Sign out" } }
        AlertDialogContent do
          AlertDialogHeader(class: "items-center text-center") do
            span(class: "bg-error-subtle text-error-emphasis mb-2 flex size-12 items-center justify-center rounded-full") { Icon(:logout, class: "size-6") }
            AlertDialogTitle { "Sign out of all devices?" }
            AlertDialogDescription { "You'll need to sign in again on your phone, tablet and other browsers." }
          end
          AlertDialogFooter(class: "sm:*:flex-1") do
            AlertDialogClose { |close| Button(**close, variant: :outline) { "Stay signed in" } }
            AlertDialogClose { |close| Button(**close, variant: :destructive) { "Sign out" } }
          end
        end
      end
    end
  end

  # @label Asynchronous action
  # Keep it open while the request runs: the confirm button shows a spinner and the dialog
  # closes itself when done (here after a fake delay; in an app, a Turbo Stream response).
  def async
    phlex do
      AlertDialog(id: "archive-dialog") do
        AlertDialogTrigger { |trigger| Button(**trigger, variant: :outline) { "Archive workspace" } }
        AlertDialogContent do
          AlertDialogHeader do
            AlertDialogTitle { "Archive this workspace?" }
            AlertDialogDescription { "Members lose access until it's restored. You can restore it within 30 days." }
          end
          AlertDialogFooter do
            AlertDialogClose { |close| Button(**close, variant: :outline, data: { **close[:data], demo: "cancel" }) { "Cancel" } }
            Button(data: { demo: "archive" }) { "Archive" }
          end
        end
      end
      script(type: "module") do
        raw safe(<<~JS)
          const dialog = document.getElementById("archive-dialog")
          const archive = dialog.querySelector("[data-demo=archive]")
          const cancel = dialog.querySelector("[data-demo=cancel]")
          archive.addEventListener("click", () => {
            archive.disabled = cancel.disabled = true
            archive.textContent = "Archiving…"
            setTimeout(() => {
              dialog.dispatchEvent(new Event("ui--dialog:close"))
              setTimeout(() => { archive.disabled = cancel.disabled = false; archive.textContent = "Archive" }, 300)
            }, 1500)
          })
        JS
      end
    end
  end

  # @label RTL
  def rtl
    phlex do
      div(dir: "rtl") do
        AlertDialog do
          AlertDialogTrigger { |trigger| Button(**trigger, variant: :destructive) { "حذف المشروع" } }
          AlertDialogContent do
            AlertDialogHeader do
              AlertDialogTitle { "حذف هذا المشروع؟" }
              AlertDialogDescription { "سيتم حذف المشروع وجميع ملفاته نهائيًا. لا يمكن التراجع عن ذلك." }
            end
            AlertDialogFooter do
              AlertDialogClose { |close| Button(**close, variant: :outline) { "إلغاء" } }
              AlertDialogClose { |close| Button(**close, variant: :destructive) { "حذف" } }
            end
          end
        end
      end
    end
  end
end
