# A dialog that demands a response - a destructive or high-stakes confirmation.
#
#   AlertDialog do
#     AlertDialogTrigger { |trigger| Button(**trigger, variant: :destructive) { "Delete project" } }
#     AlertDialogContent do
#       AlertDialogHeader do
#         AlertDialogTitle { "Delete this project?" }
#         AlertDialogDescription { "This can't be undone." }
#       end
#       AlertDialogFooter do
#         AlertDialogClose { |close| Button(**close, variant: :outline) { "Cancel" } }
#         button_to("Delete", project_path(@project), method: :delete, class: …)
#       end
#     end
#   end
#
# Dialog's parts under AlertDialog names, with `role="alertdialog"`, no corner close button and
# no dismissal by clicking outside - the user has to choose (Escape still cancels).
class UI::AlertDialog < UI::Dialog
  prop :dismissible, default: -> { false }

  def identifier = "ui--dialog"
  def slot = "alert-dialog"
  def role = "alertdialog"
end
