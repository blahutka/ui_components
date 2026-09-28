# The alert dialog's card: narrower than a Dialog and without a corner close button.
class AppicaUI::AlertDialogContent < AppicaUI::DialogContent
  prop :close_button, default: -> { false }

  private
    def width = "w-100"
end
