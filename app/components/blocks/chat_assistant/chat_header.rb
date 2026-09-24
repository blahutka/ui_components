# The assistant's avatar (with an online badge) and name.
class Blocks::ChatHeader < Blocks::Base
  prop :title, default: -> { nil }
  prop :icon,  default: -> { :sparkles }

  def view_template
    chat = consume(:chat_assistant, component: "Blocks::ChatAssistant")

    div(**mix({ data: { slot: "chat-header" } }, @attributes.except(:class)), class: cn("flex items-center gap-2.5", override: @attributes[:class])) do
      Avatar(size: :sm) do
        AvatarFallback(class: "bg-background-inverse text-foreground-inverse") do
          Icon(@icon, class: "size-4.5")
          AvatarBadge(animate: chat.online?, class: (chat.online? ? nil : "text-foreground-subtle"), aria_label: (chat.online? ? "Online" : "Offline"))
        end
      end
      span(class: "text-foreground-intense text-sm font-semibold") { @title || chat.title }
    end
  end
end
