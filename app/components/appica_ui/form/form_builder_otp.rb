# An OTPField with one input per character, as AppicaUI::FormBuilder renders it. The first input
# carries the Field's control id so the label focuses it.
class AppicaUI::FormBuilderOTP < AppicaUI::Base
  prop :otp
  prop :id, default: -> { nil }

  def view_template
    render AppicaUI::OTPField.new(**@otp) do
      @otp[:length].to_i.times { |index| render AppicaUI::OTPFieldInput.new(id: (@id if index.zero?)) }
    end
  end
end
