# An assistant chat card - header, conversation, a "thinking" status, suggestion chips and a
# composer - built from Avatar, Spinner, Button and Icon.
#
# Blocks are ready-made compositions of the UI primitives. This one runs a demo in the
# preview: send a message or click a suggestion and it answers by itself. In an app, give it an
# `action:` and reply with a Turbo Stream.
#
# @label Chat assistant
# @logical_path Blocks
# @component Blocks::ChatAssistant
# @display width wide
class Blocks::ChatAssistantPreview < UI::BasePreview
  REPLIES = [
    "Done - the Pro tier now has a highlighted border and a “Most popular” badge.",
    "Added an FAQ section with six collapsible questions under the pricing table.",
    "Switched the page to the dark theme; the featured tier keeps its accent."
  ].freeze

  # @label Usage
  # The Appica homepage card. The last request is still "generating" when the page loads; the
  # demo finishes it, then answers anything you send.
  # @param title text
  # @param online [Boolean] toggle
  def default(title: "Appica Assistant", online: true)
    phlex do
      ChatAssistant(title:, status: (online ? :online : :offline), demo_replies: REPLIES, class: "h-120 w-100 max-w-full") do
        ChatHeader()
        ChatMessages do
          ChatMessage(from: :user) { "Build me a pricing page with a monthly / annual toggle." }
          ChatMessage(from: :assistant) { "On it - composing Tabs, Switch and Table into a three-tier layout." }
          ChatMessage(from: :user) { "Make the Pro tier featured." }
          ChatStatus { "Generating preview" }
        end
        ChatSuggestions([ "Add a FAQ section", "Use dark theme" ])
        ChatComposer()
      end
    end
  end

  # @label Empty state
  # A fresh conversation: a greeting from the assistant and a few starters.
  def empty
    phlex do
      ChatAssistant(title: "Appica Assistant", demo_replies: REPLIES, class: "h-100 w-100 max-w-full") do
        ChatHeader()
        ChatMessages do
          ChatMessage { "Hi! Describe the page you need and I'll compose it from Appica components." }
          ChatStatus(hidden: true)
        end
        ChatSuggestions([ "Pricing page", "Sign-in form", "Settings screen" ])
        ChatComposer(placeholder: "Describe a page…")
      end
    end
  end

  # @label Long conversation
  # The messages scroll inside a fixed-height card and stay pinned to the latest one.
  def long
    phlex do
      ChatAssistant(title: "Appica Assistant", demo_replies: REPLIES, class: "h-100 w-100 max-w-full") do
        ChatHeader()
        ChatMessages do
          6.times do |round|
            ChatMessage(from: :user) { "Iteration #{round + 1}: tighten the spacing in the hero." }
            ChatMessage { "Reduced the hero padding and aligned the CTA with the heading (step #{round + 1})." }
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
    phlex do
      ChatAssistant(title: "Appica Assistant", status: :offline, class: "w-100 max-w-full") do
        ChatHeader()
        ChatMessages do
          ChatMessage { "I'm offline right now - I'll pick this up when I'm back." }
        end
        ChatComposer(placeholder: "Assistant is offline")
      end
    end
  end

  # @label RTL
  # Bubbles swap sides with the reading direction and the corner "tails" follow (logical radii).
  def rtl
    phlex do
      div(dir: "rtl") do
        ChatAssistant(title: "مساعد أبيكا", demo_replies: [ "تم - أصبحت الخطة الاحترافية مميزة الآن." ], class: "h-100 w-100 max-w-full") do
          ChatHeader()
          ChatMessages do
            ChatMessage(from: :user) { "أنشئ صفحة أسعار مع مفتاح شهري / سنوي." }
            ChatMessage { "جارٍ العمل - أجمع علامات التبويب والمفتاح والجدول في تخطيط من ثلاث فئات." }
            ChatStatus(hidden: true)
          end
          ChatSuggestions([ "أضف قسم الأسئلة الشائعة" ])
          ChatComposer(placeholder: "اسأل أي شيء…", label: "راسل المساعد")
        end
      end
    end
  end
end
