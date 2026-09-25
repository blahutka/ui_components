# A command in a CommandMenu: an icon, the label and its keyboard shortcut. With `href:` it's a
# link, otherwise a button whose `value:` comes with `blocks--command-menu:select`.
#
#   CommandItem(icon: :rocket, shortcut: %w[ ⇧ D ], value: "deploy") { "Deploy to production" }
class Blocks::CommandItem < Blocks::Base
  prop :icon,     default: -> { nil }
  prop :shortcut, ->(value) { Array(value) }, default: -> { [] }
  prop :href,     default: -> { nil }
  prop :value,    default: -> { nil }

  def view_template(&)
    NavigationItem do
      NavigationLink(active: false, class: "w-full") do |link|
        # deep_merge, not mix: the item's data-slot replaces the link's instead of joining it
        attributes = link.deep_merge(data: {
          slot: "command-item", value: @value, "blocks--command-menu-target": "item",
          action: "mouseenter->blocks--command-menu#hover click->blocks--command-menu#choose"
        }).deep_merge(@attributes.except(:class))
        if @href
          a(**attributes, href: @href) { content(&) }
        else
          button(**attributes, type: "button") { content(&) }
        end
      end
    end
  end

  private
    def content(&)
      Icon(@icon, class: "text-foreground-subtle", data: { icon: "start" }) if @icon
      span(data: { slot: "command-item-label" }, &)
      if @shortcut.any?
        span(class: "ms-auto flex gap-1") do
          @shortcut.each { |key| Kbd(size: :sm, class: "-me-1") { key } }
        end
      end
    end
end
