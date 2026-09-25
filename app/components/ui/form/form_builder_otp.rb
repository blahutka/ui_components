# An OTPField with one input per character, as UI::FormBuilder renders it. The first input
# carries the Field's control id so the label focuses it.
class UI::FormBuilderOTP < UI::Base
  prop :otp
  prop :id, default: -> { nil }

  def view_template
    render UI::OTPField.new(**@otp) do
      @otp[:length].to_i.times { |index| render UI::OTPFieldInput.new(id: (@id if index.zero?)) }
    end
  end
end
