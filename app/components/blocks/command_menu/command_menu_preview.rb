# A command palette card: search with a ⌘K hint, grouped commands with icons and shortcuts, and
# key hints - composed from Input, Kbd, Navigation and Icon.
#
# @label Command menu
# @logical_path Blocks
# @component Blocks::CommandMenu
# @display width wide
class Blocks::CommandMenuPreview < UI::BasePreview
  COMMANDS = proc do
    CommandGroup(label: "Suggestions") do
      CommandItem(icon: :layout_dashboard, shortcut: %w[ G D ], value: "dashboard") { "Open dashboard" }
      CommandItem(icon: :user_plus, shortcut: %w[ ⌘ I ], value: "invite") { "Invite teammates" }
      CommandItem(icon: :file_plus, shortcut: %w[ ⌘ N ], value: "document") { "New document" }
    end
    CommandGroup(label: "Actions") do
      CommandItem(icon: :rocket, shortcut: %w[ ⇧ D ], value: "deploy") { "Deploy to production" }
      CommandItem(icon: :moon, shortcut: %w[ ⌘ J ], value: "dark-mode") { "Toggle dark mode" }
    end
  end

  # @label Usage
  # The Appica homepage card. Type to filter, ↑ / ↓ to move, ↵ to run; ⌘K / Ctrl+K focuses the
  # search. The chosen command is shown below.
  # @param placeholder text
  # @param hotkey text
  # @param hotkey_hint text
  # @param hints [Boolean] toggle
  def default(placeholder: nil, hotkey: "k", hotkey_hint: "⌘K", hints: true)
    phlex do
      div(class: "flex w-95 max-w-full flex-col gap-3") do
        CommandMenu(hotkey:, hotkey_hint:, hints:, **given(placeholder:), id: "demo-command-menu") { instance_exec(&COMMANDS) }
        p(class: "text-foreground-muted text-xs", data: { demo: "chosen" }) { "Choose a command…" }
      end
      script(type: "module") do
        raw safe(<<~JS)
          document.getElementById("demo-command-menu").addEventListener("blocks--command-menu:select", ({ detail }) => {
            document.querySelector("[data-demo=chosen]").textContent = `Chose “${detail.label}” (${detail.value})`
          })
        JS
      end
    end
  end

  # @label Links
  # Commands with `href:` are links; ↵ follows the highlighted one.
  def links
    phlex do
      CommandMenu(hints: false, class: "w-95 max-w-full") do
        CommandGroup(label: "Go to") do
          CommandItem(icon: :home, href: "#home") { "Home" }
          CommandItem(icon: :settings, href: "#settings", shortcut: %w[ ⌘ , ]) { "Settings" }
          CommandItem(icon: :help, href: "#help") { "Help center" }
        end
      end
    end
  end

  # @label RTL
  # Rendered in Arabic whatever the toolbar says.
  def rtl
    phlex do
      I18n.with_locale(:ar) do
        div(dir: "rtl") do
          CommandMenu(class: "w-95 max-w-full") do
            CommandGroup(label: "اقتراحات") do
              CommandItem(icon: :layout_dashboard, shortcut: %w[ G D ]) { "فتح لوحة التحكم" }
              CommandItem(icon: :user_plus, shortcut: %w[ ⌘ I ]) { "دعوة زملاء الفريق" }
            end
          end
        end
      end
    end
  end
end
