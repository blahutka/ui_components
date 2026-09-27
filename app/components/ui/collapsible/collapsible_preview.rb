# A section that expands and collapses to show or hide its content.
#
# One trigger controlling one panel - a "read more", an inline details section, any
# one-off toggle. The parts ship almost unstyled; the scenarios add chevrons and spacing.
#
# @label Collapsible
# @logical_path Data Display
# @component UI::Collapsible
# @display width wide
class UI::CollapsiblePreview < UI::BasePreview
  # Props not in the Usage form (data, render blocks, generated ids): see ui_components:preview_params
  UNLISTED_PROPS = %i[ default_open id ].freeze

  CHEVRON_CLASS = "mt-0.75 size-4.5 shrink-0 stroke-2 transition-transform duration-200 group-data-panel-open:rotate-90 motion-reduce:transition-none rtl:-scale-x-100"
  TRIGGER_CLASS = "group text-foreground-intense data-disabled:text-foreground-muted inline-flex items-start gap-2 text-start font-medium"

  TREE = [
    { name: "app", children: [
      { name: "components", children: [ { name: "card.rb" }, { name: "drawer.rb" }, { name: "drawer_controller.js" } ] },
      { name: "models", children: [ { name: "project.rb" }, { name: "user.rb" } ] },
      { name: "views", children: [ { name: "layouts", children: [ { name: "application.html.erb" } ] } ] }
    ] },
    { name: "config", children: [ { name: "routes.rb" }, { name: "importmap.rb" } ] },
    { name: "Gemfile" },
    { name: "README.md" }
  ].freeze

  INPUT = "border-border-strong bg-background text-foreground h-8 w-full min-w-0 rounded-sm border px-3 text-sm outline-none focus:border-transparent focus:ring-3 focus:ring-ring-input"

  # @label Usage
  # A trigger and a panel. The chevron rotates because the trigger carries data-panel-open.
  # @param open [Boolean] toggle "Start expanded"
  # @param disabled [Boolean] toggle "Lock the panel"
  def default(open: true, disabled: false)
    phlex do
      Collapsible(open:, disabled:, class: "w-full max-w-100") do
        CollapsibleTrigger(class: TRIGGER_CLASS) do
          Icon(:chevron_right, class: CHEVRON_CLASS)
          plain "What's included in the free plan?"
        end
        CollapsibleContent do
          p(class: "ps-6.5 pt-2.5 text-sm") { "The free plan includes up to three projects, 1 GB of storage, and community support - everything you need to evaluate the product before upgrading." }
        end
      end
    end
  end

  # @label File tree
  # Nest a Collapsible inside another's content for an expandable tree: each folder is its
  # own disclosure, files are plain rows.
  def file_tree
    tree_item = lambda do |node, open|
      if node[:children]
        Collapsible(open:) do
          CollapsibleTrigger(class: "group inline-flex items-center gap-1.5 py-1 font-medium") do
            Icon(:chevron_right, class: "size-4 shrink-0 stroke-[1.75] transition-transform duration-200 group-data-panel-open:rotate-90 motion-reduce:transition-none rtl:-scale-x-100")
            Icon(:folder, class: "text-foreground-muted size-4 shrink-0 stroke-[1.75] group-data-panel-open:hidden")
            Icon(:folder_open, class: "text-foreground-muted hidden size-4 shrink-0 stroke-[1.75] group-data-panel-open:block")
            plain node[:name]
          end
          CollapsibleContent do
            div(class: "ms-2 flex flex-col border-s ps-2") do
              node[:children].each { |child| instance_exec(child, false, &tree_item) }
            end
          end
        end
      else
        span(class: "text-foreground-muted flex items-center gap-1.5 py-1 ps-5.5") do
          Icon(:file, class: "size-4 shrink-0 stroke-[1.75]")
          plain node[:name]
        end
      end
    end

    phlex do
      div(class: "w-full max-w-72 text-sm") do
        TREE.each { |node| instance_exec(node, node[:name] == "app", &tree_item) }
      end
    end
  end

  # @label Settings panel
  # Reveal extra controls only when needed. The icon swaps between maximize and minimize
  # from the root's data-open state (`group-data-open:`) - no extra JavaScript. The trigger
  # renders as an outline icon Button through the block argument.
  def settings_panel
    phlex do
      Collapsible(class: "group border-border w-full max-w-82 rounded-xl border p-5") do
        div do
          h3(class: "text-foreground-intense font-semibold") { "Corner radius" }
          p(class: "text-foreground-muted text-sm") { "Round every corner at once, or set each one." }
        end
        div(class: "mt-4 flex items-center gap-3") do
          input(type: "number", value: "12", aria_label: "All corners", class: INPUT)
          CollapsibleTrigger(class: "shrink-0") do |trigger|
            Button(**trigger, variant: :outline, size: :sm, icon: true, aria_label: "Set each corner individually") do
              Icon(:maximize, class: "group-data-open:hidden")
              Icon(:minimize, class: "hidden group-data-open:block")
            end
          end
        end
        CollapsibleContent do
          div(class: "mt-4 grid grid-cols-2 gap-4 px-1.5 pb-1.5") do
            [ "Top left", "Top right", "Bottom left", "Bottom right" ].each do |corner|
              label(class: "flex flex-col gap-1.5 text-xs") do
                span(class: "text-foreground") { corner }
                input(type: "number", value: "12", class: INPUT)
              end
            end
          end
        end
      end
    end
  end

  # @label Show more
  # The trigger can sit below the always-visible text; its label follows the open state
  # through the root's data-open (`group-data-open:`).
  def show_more
    phlex do
      Collapsible(class: "group max-w-100 text-sm leading-relaxed") do
        p { "Appica UI is a headless-first component library built on Base UI and Tailwind. It ships accessible primitives with sensible default styling you can override class by class." }
        CollapsibleContent do
          p(class: "pt-3") do
            plain "Every component supports right-to-left layouts, honors "
            code { "prefers-reduced-motion" }
            plain ", and forwards native attributes to the underlying element - so it drops into your design system without fighting it."
          end
        end
        CollapsibleTrigger(class: "text-primary mt-2 text-sm font-medium hover:underline") do
          span(class: "group-data-open:hidden") { "Show more" }
          span(class: "hidden group-data-open:inline") { "Show less" }
        end
      end
    end
  end

  # Any button inside the root can drive it with `data: { action: "ui--collapsible#toggle" }`
  # (or #open / #close); the header and the extra button share the same state.
  def controlled
    phlex do
      Collapsible(class: "group flex w-full max-w-100 flex-col gap-3") do
        div(class: "flex items-center justify-between") do
          span(class: "text-foreground-muted text-sm") do
            plain "Panel is "
            strong(class: "text-foreground hidden group-data-open:inline") { "open" }
            strong(class: "text-foreground group-data-open:hidden") { "closed" }
          end
          Button(size: :sm, variant: :outline, data: { action: "ui--collapsible#toggle" }) do
            span(class: "group-data-open:hidden") { "Expand" }
            span(class: "hidden group-data-open:inline") { "Collapse" }
          end
        end
        div do
          CollapsibleTrigger(class: TRIGGER_CLASS) do
            Icon(:chevron_right, class: CHEVRON_CLASS)
            plain "Order #4982"
          end
          CollapsibleContent do
            p(class: "ps-6.5 pt-2.5 text-sm") { "Two items, shipped on Aug 30 via standard delivery. The header and the external button drive the same state, so either one toggles the panel." }
          end
        end
      end
    end
  end

  # `disabled: true` locks the panel shut; the trigger leaves the tab order and exposes data-disabled.
  def disabled
    phlex do
      Collapsible(disabled: true, class: "w-full max-w-100") do
        CollapsibleTrigger(class: TRIGGER_CLASS) do
          Icon(:chevron_right, class: CHEVRON_CLASS)
          plain "Advanced settings"
        end
        CollapsibleContent { p(class: "ps-6.5 pt-2.5 text-sm") { "These settings unlock on a paid plan." } }
      end
    end
  end

  # @label Hidden until found
  # With `hidden_until_found: true` the closed panel uses hidden="until-found": the browser's
  # find-in-page (⌘F "business day") reaches the text and opens the panel.
  def hidden_until_found
    phlex do
      Collapsible(class: "w-full max-w-100") do
        CollapsibleTrigger(class: TRIGGER_CLASS) do
          Icon(:chevron_right, class: CHEVRON_CLASS)
          plain "Shipping & returns"
        end
        CollapsibleContent(hidden_until_found: true) do
          p(class: "ps-6.5 pt-2.5 text-sm") { "Orders ship within one business day and arrive in 3-5 days. Returns are free within 30 days of delivery." }
        end
      end
    end
  end

  # @label RTL
  # The trigger and panel align to the right, the indent follows the logical ps-* padding,
  # and the chevron mirrors.
  def rtl
    phlex do
      div(dir: "rtl") do
        Collapsible(open: true, class: "w-full max-w-100") do
          CollapsibleTrigger(class: TRIGGER_CLASS) do
            Icon(:chevron_right, class: CHEVRON_CLASS)
            plain "ما الذي تتضمنه الخطة المجانية؟"
          end
          CollapsibleContent do
            p(class: "ps-6.5 pt-2.5 text-sm") { "تشمل الخطة المجانية ما يصل إلى ثلاثة مشاريع، وذاكرة تخزين بسعة 1 غيغابايت، ودعم المجتمع." }
          end
        end
      end
    end
  end
end
