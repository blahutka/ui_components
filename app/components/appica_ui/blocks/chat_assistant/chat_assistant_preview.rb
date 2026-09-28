# An assistant chat card - header, conversation, a "thinking" status, suggestion chips and a
# composer - built from Avatar, Spinner, Button and Icon.
#
# Blocks are ready-made compositions of the UI primitives. This one runs a demo in the
# preview: send a message or click a suggestion and it answers by itself. In an app, give it an
# `action:` and reply with a Turbo Stream.
#
# Localized: switch the toolbar's **Locale** display option - the component's own strings come
# from chat_assistant.locales.yml, the sample conversation from chat_assistant_preview.locales.yml.
#
# @label Chat assistant
# @logical_path Blocks
# @component AppicaUI::Blocks::ChatAssistant
# @display width wide
class AppicaUI::Blocks::ChatAssistantPreview < AppicaUI::BasePreview
  # Props not in the Usage form (data, render blocks, generated ids): see ui_components:preview_params
  UNLISTED_PROPS = %i[ action messages_id demo_replies status ].freeze

  # @label Usage
  # The Appica homepage card. The last request is still "generating" when the page loads; the
  # demo finishes it, then answers anything you send.
  # @param title text "Leave empty for the translated sample title"
  # @param online [Boolean] toggle
  # @param method text
  def default(title: nil, online: true, method: "post")
    copy = sample

    phlex do
      ChatAssistant(method:, title: title.presence || copy[:title], status: (online ? :online : :offline), demo_replies: copy[:replies], class: "h-120 w-100 max-w-full") do
        ChatHeader()
        ChatMessages do
          copy[:conversation].each_with_index { |text, index| ChatMessage(from: index.even? ? :user : :assistant) { text } }
          ChatStatus { copy[:status] }
        end
        ChatSuggestions(copy[:suggestions])
        ChatComposer()
      end
    end
  end

  # @label Empty state
  # A fresh conversation: a greeting from the assistant and a few starters.
  def empty
    copy = sample

    phlex do
      ChatAssistant(title: copy[:title], demo_replies: copy[:replies], class: "h-100 w-100 max-w-full") do
        ChatHeader()
        ChatMessages do
          ChatMessage { copy[:empty][:greeting] }
          ChatStatus(hidden: true)
        end
        ChatSuggestions(copy[:empty][:starters])
        ChatComposer(placeholder: copy[:empty][:placeholder])
      end
    end
  end

  # @label Long conversation
  # The messages scroll inside a fixed-height card and stay pinned to the latest one.
  def long
    copy = sample

    phlex do
      ChatAssistant(title: copy[:title], demo_replies: copy[:replies], class: "h-100 w-100 max-w-full") do
        ChatHeader()
        ChatMessages do
          1.upto(6) do |n|
            ChatMessage(from: :user) { copy[:long][:request] % { n: } }
            ChatMessage { copy[:long][:reply] % { n: } }
          end
          ChatStatus(hidden: true)
        end
        ChatComposer()
      end
    end
  end

  # @label Offline
  # `status: :offline` greys the badge, stops its pulse and disables the composer.
  def offline
    copy = sample

    phlex do
      ChatAssistant(title: copy[:title], status: :offline, class: "w-100 max-w-full") do
        ChatHeader()
        ChatMessages do
          ChatMessage { copy[:offline][:message] }
        end
        ChatComposer(placeholder: copy[:offline][:placeholder])
      end
    end
  end

  # @label RTL
  # Rendered in Arabic whatever the toolbar says: bubbles swap sides with the reading direction
  # and their corner "tails" follow (logical radii).
  def rtl
    copy = I18n.with_locale(:ar) { sample }

    phlex do
      I18n.with_locale(:ar) do
        div(dir: "rtl") do
          ChatAssistant(title: copy[:title], demo_replies: copy[:replies], class: "h-100 w-100 max-w-full") do
            ChatHeader()
            ChatMessages do
              copy[:conversation].first(2).each_with_index { |text, index| ChatMessage(from: index.even? ? :user : :assistant) { text } }
              ChatStatus(hidden: true)
            end
            ChatSuggestions(copy[:suggestions].first(1))
            ChatComposer()
          end
        end
      end
    end
  end

  private
    # The sample conversation in the current locale (chat_assistant_preview.locales.yml)
    def sample
      I18n.t("ui_components.previews.chat_assistant")
    end
end
