# An "Editor" tab in the inspector drawer (next to Source / Notes / Params) with links that
# open the scenario, the component's files and its docs page in your editor.
Lookbook.add_panel(:editor, "lookbook/panels/editor", label: "Editor", hotkey: "e")

# The toolbar's "Locale" display option: render each preview in that locale. (Previews are
# rendered inside Lookbook's previews controller action; the layout sets lang/dir from it.)
# to_prepare, because Lookbook's controllers are reloaded along with the app in development.
Rails.application.config.to_prepare do
  Lookbook::PreviewsController.around_action do |controller, action|
    # Lookbook resolves display options (from its _display param or cookie) in a before_action
    resolved = controller.instance_variable_get(:@static_display_options).to_h
    locale = (resolved[:locale] || resolved["locale"]).presence
    locale = I18n.default_locale unless locale && I18n.available_locales.map(&:to_s).include?(locale.to_s)

    I18n.with_locale(locale) { action.call }
  end
end
