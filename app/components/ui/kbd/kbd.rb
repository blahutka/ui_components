# A keyboard key or shortcut, e.g. in menu items: Kbd(size: :sm, class: "ms-auto") { "⌘N" }
class UI::Kbd < UI::Base
  BASE = "border-border bg-background text-foreground-muted pointer-events-none inline-flex w-fit shrink-0 items-center justify-center border font-sans font-medium whitespace-nowrap select-none " \
    "in-data-[slot=tooltip-content]:bg-background-inverse in-data-[slot=tooltip-content]:text-foreground-inverse/75 dark:in-data-[slot=tooltip-content]:border-border-intense/20 in-data-[slot=tooltip-content]:border-white/25"

  SIZES = {
    sm: "h-5 min-w-5 text-xs px-1.25 rounded-2xs",
    md: "h-6 min-w-6 text-xs px-1.5 rounded-xs",
    lg: "h-7 min-w-7 text-sm px-2 rounded-sm"
  }.freeze

  def initialize(size: :md, **attributes)
    @size = SIZES.key?(size.to_sym) ? size.to_sym : :md
    @attributes = attributes
  end

  def view_template(&)
    kbd(**mix({ data: { slot: "kbd" } }, @attributes.except(:class)), class: cn(BASE, SIZES[@size], override: @attributes[:class]), &)
  end
end
