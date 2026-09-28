# A row of suggestion chips; clicking one sends it.
#
#   ChatSuggestions([ "Add a FAQ section", "Use dark theme" ])
#   ChatSuggestions { ChatSuggestion("Summarize") }
class AppicaUI::Blocks::ChatSuggestions < AppicaUI::Blocks::Base
  param :suggestions, default: -> { [] }

  def view_template(&)
    div(**mix({ data: { slot: "chat-suggestions", "appica-ui--blocks--chat-assistant-target": "suggestions" } }, @attributes.except(:class)),
      class: cn("mt-3 flex flex-wrap gap-1.5", override: @attributes[:class])) do
      @suggestions.each { |text| ChatSuggestion(text) }
      yield if block_given?
    end
  end
end
