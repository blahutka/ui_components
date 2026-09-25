# Fires a toast from a button without writing JavaScript. The toast options go in `toast:`
# (the same keys as UI.toast.add: title, description, icon, thumbnail, action, timeout,
# priority, position). A block taking an argument puts the attributes on your own element:
#
#   ToastTrigger(toast: { title: "Changes saved" }) { |trigger| Button(**trigger) { "Save" } }
class UI::ToastTrigger < UI::Base
  prop :toast

  def before_template(&content)
    @render_prop = content&.arity == 1
    super
  end

  def view_template
    attributes = mix({ type: "button", data: { toast: camelize_keys(@toast).to_json } }, @attributes)

    if @render_prop
      yield attributes
    else
      button(**attributes) { yield }
    end
  end

  private
    def camelize_keys(value)
      case value
      when Hash then value.to_h { |key, item| [ key.to_s.camelize(:lower), camelize_keys(item) ] }
      when Array then value.map { |item| camelize_keys(item) }
      else value
      end
    end
end
