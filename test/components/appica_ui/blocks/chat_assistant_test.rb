require "test_helper"

class AppicaUI::Blocks::ChatAssistantTest < ComponentTestCase
  test "renders the card with header, conversation, status, suggestions and composer" do
    html = render_ui do
      ChatAssistant(title: "Appica Assistant", action: "/chat", messages_id: "chat-messages") do
        ChatHeader()
        ChatMessages do
          ChatMessage(from: :user) { "Make the Pro tier featured." }
          ChatMessage { "On it." }
          ChatStatus { "Generating preview" }
        end
        ChatSuggestions([ "Add a FAQ section", "Use dark theme" ])
        ChatComposer()
      end
    end
    root = html.at_css("[data-slot=chat-assistant]")

    assert_equal "appica-ui--blocks--chat-assistant", root["data-controller"]
    assert_equal "false", root["data-appica-ui--blocks--chat-assistant-demo-value"]
    assert_equal "Appica Assistant", html.at_css("[data-slot=chat-header]").text.strip
    assert html.at_css("[data-slot=chat-header] [data-slot=avatar-badge] .animate-ping-paced")
    assert_equal "chat-messages", html.at_css("[data-slot=chat-messages]")["id"]
    assert_equal "log", html.at_css("[data-slot=chat-messages]")["role"]
    assert html.at_css("[data-slot=chat-status] [data-slot=spinner][data-variant=sparkle]")
    assert_equal [ "Add a FAQ section", "Use dark theme" ], html.css("[data-slot=chat-suggestion]").map { |chip| chip["data-text"] }
  end

  test "bubbles sit on opposite sides by sender" do
    html = render_ui do
      ChatAssistant do
        ChatMessages do
          ChatMessage(from: :user) { "Hi" }
          ChatMessage(from: :assistant) { "Hello" }
        end
      end
    end
    user, assistant = html.css("[data-slot=chat-messages] [data-slot=chat-message]")

    assert_includes user["class"], "self-end"
    assert_includes user["class"], "bg-secondary-soft"
    assert_includes assistant["class"], "self-start"
    assert_includes assistant["class"], "bg-background-muted"
  end

  test "the composer is a form posting the message to the action" do
    html = render_ui { ChatAssistant(action: "/chat") { ChatComposer(placeholder: "Ask anything…") } }
    form = html.at_css("form[data-slot=chat-composer]")

    assert_equal "/chat", form["action"]
    assert_equal "post", form["method"]
    assert_equal "message", form.at_css("input")["name"]
    assert_equal [ "Attach files", "Dictate a message", "Send message" ], form.css("button").map { |button| button["aria-label"] }
    assert_equal "submit", form.at_css("button[aria-label='Send message']")["type"]
  end

  test "without an action it runs the demo, offline disables the composer" do
    html = render_ui { ChatAssistant(status: :offline, demo_replies: [ "Sure." ]) { ChatHeader(); ChatComposer() } }
    root = html.at_css("[data-slot=chat-assistant]")

    assert_equal "true", root["data-appica-ui--blocks--chat-assistant-demo-value"]
    assert_equal '["Sure."]', root["data-appica-ui--blocks--chat-assistant-replies-value"]
    assert html.at_css("input[name=message]").key?("disabled")
    assert_nil html.at_css("[data-slot=avatar-badge] .animate-ping-paced")
  end

  test "its own strings are translated" do
    html = I18n.with_locale(:cs) do
      render_ui do
        ChatAssistant(status: :offline) do
          ChatHeader()
          ChatMessages { ChatStatus(hidden: true) }
          ChatComposer()
        end
      end
    end
    root = html.at_css("[data-slot=chat-assistant]")

    assert_equal "Asistent", html.at_css("[data-slot=chat-header]").text.strip
    assert_equal "Offline", html.at_css("[data-slot=avatar-badge]")["aria-label"]
    assert_equal "Konverzace", html.at_css("[data-slot=chat-messages]")["aria-label"]
    assert_equal "Přemýšlím…", html.at_css("[data-slot=chat-status]").text.strip
    assert_equal '["Hotovo – podívejte se na náhled."]', root["data-appica-ui--blocks--chat-assistant-replies-value"]
    input = html.at_css("input[name=message]")
    assert_equal "Zeptejte se na cokoli…", input["placeholder"]
    assert_equal "Napište asistentovi", input["aria-label"]
    assert_equal "Psaní zprávy", html.at_css("[role=toolbar]")["aria-label"]
    assert_equal [ "Přiložit soubory", "Nadiktovat zprávu", "Odeslat zprávu" ], html.css("form button").map { |button| button["aria-label"] }
  end

  test "explicit props still win over the translations" do
    html = I18n.with_locale(:de) { render_ui { ChatAssistant(title: "Helper") { ChatHeader(); ChatComposer(placeholder: "Frage?") } } }

    assert_equal "Helper", html.at_css("[data-slot=chat-header]").text.strip
    assert_equal "Frage?", html.at_css("input[name=message]")["placeholder"]
    assert_equal "Nachricht senden", html.at_css("button[type=submit]")["aria-label"]
  end

  test "parts outside a ChatAssistant raise" do
    assert_raises(ArgumentError) { render_ui { ChatComposer() } }
  end
end
