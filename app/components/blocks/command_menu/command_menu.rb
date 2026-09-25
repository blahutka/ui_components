# A command palette card: a search field with a ⌘K hint, grouped commands with icons and
# keyboard shortcuts, and a footer of key hints - composed from Input, Kbd, Navigation and Icon.
#
#   CommandMenu do
#     CommandGroup(label: "Suggestions") do
#       CommandItem(icon: :layout_dashboard, shortcut: %w[ G D ], href: dashboard_path) { "Open dashboard" }
#       CommandItem(icon: :user_plus, shortcut: %w[ ⌘ I ], value: "invite") { "Invite teammates" }
#     end
#   end
#
# Typing filters the commands; ↑ / ↓ move the highlight and ↵ runs it (follows its `href:` or
# clicks it); ⌘K / Ctrl+K focuses the search from anywhere. Choosing a command emits
# `blocks--command-menu:select` with { value }. Strings: command_menu.locales.yml.
class Blocks::CommandMenu < Blocks::Base
  prop :placeholder, default: -> { t(".placeholder") }
  prop :hotkey,      default: -> { "k" }
  prop :hotkey_hint, default: -> { "⌘K" }
  prop :hints,       default: -> { true }

  def view_template(&)
    div(**mix(defaults(data: {
      slot: "command-menu", controller: "blocks--command-menu", "blocks--command-menu-hotkey-value": @hotkey,
      action: "keydown@window->blocks--command-menu#hotkeyPressed"
    }), @attributes.except(:class)), class: cn(
      "bg-background border-border-muted flex flex-col rounded-xl border p-6 shadow-lg dark:shadow-[0_8px_16px_-4px_rgba(0,0,0,0.8)]",
      override: @attributes[:class]
    )) do
      Input(start_slot: :search, end_slot: (-> { Kbd { @hotkey_hint } } if @hotkey_hint), placeholder: @placeholder, aria_label: t(".search"),
        autocomplete: "off", spellcheck: "false",
        data: { "blocks--command-menu-target": "input", action: "input->blocks--command-menu#filter keydown->blocks--command-menu#navigate" })
      Navigation(orientation: :vertical, aria_label: t(".results"), class: "mt-3 flex-1 space-y-3", &)
      p(hidden: true, class: "text-foreground-muted py-6 text-center text-sm", data: { slot: "command-menu-empty", "blocks--command-menu-target": "empty" }) { t(".empty") }
      hint_bar if @hints
    end
  end

  private
    def hint_bar
      div(class: "text-foreground-muted mt-3 flex items-center gap-3 text-xs", data: { slot: "command-menu-hints" }) do
        span(class: "flex items-center gap-1") do
          Kbd(size: :sm) { "↑" }
          Kbd(size: :sm) { "↓" }
          plain t(".navigate")
        end
        span(class: "flex items-center gap-1") do
          Kbd(size: :sm) { "↵" }
          plain t(".select")
        end
      end
    end
end
