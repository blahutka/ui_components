# Several panels sharing one region, one shown at a time.
#
# @label Tabs
# @logical_path Navigation
# @component UI::Tabs
# @display width wide
class UI::TabsPreview < UI::BasePreview
  PANELS = {
    overview: [ "Overview", "A snapshot of your workspace - recent files, members, and usage." ],
    activity: [ "Activity", "Every change, comment, and deploy across the team, newest first." ],
    settings: [ "Settings", "Manage the workspace name, visibility, and connected integrations." ]
  }.freeze

  # @label Usage
  # @param variant [Symbol] select { choices: [pill, line] }
  # @param size [Symbol] select { choices: [sm, md, lg] }
  # @param orientation [Symbol] select { choices: [horizontal, vertical] }
  def default(variant: :pill, size: :md, orientation: :horizontal)
    phlex do
      Tabs(default_value: "overview", variant:, size:, orientation:, class: "w-full max-w-md") do
        TabsList { PANELS.each { |value, (label, _)| TabsTrigger(value:) { label } } }
        PANELS.each { |value, (_, text)| TabsContent(value:, class: "text-foreground-muted text-sm") { text } }
      end
    end
  end

  # `:pill` rides a filled track; `:line` slides an underline under the active tab.
  def variants
    phlex do
      div(class: "flex w-full max-w-md flex-col gap-8") do
        %i[ pill line ].each do |variant|
          Tabs(default_value: "overview", variant:) { TabsList { PANELS.each { |value, (label, _)| TabsTrigger(value:) { label } } } }
        end
      end
    end
  end

  def sizes
    phlex do
      div(class: "flex flex-col items-center gap-6") do
        %i[ sm md lg ].each do |size|
          Tabs(default_value: "overview", size:) { TabsList { PANELS.each { |value, (label, _)| TabsTrigger(value:) { label } } } }
        end
      end
    end
  end

  # Triggers stack beside their panels; ↑/↓ move between them.
  def vertical
    phlex do
      Tabs(default_value: "general", orientation: :vertical, class: "w-full max-w-md") do
        TabsList do
          TabsTrigger(value: "general") { "General" }
          TabsTrigger(value: "members") { "Members" }
          TabsTrigger(value: "billing") { "Billing" }
        end
        TabsContent(value: "general", class: "text-foreground-muted text-sm") { "Workspace name, URL slug, and default language." }
        TabsContent(value: "members", class: "text-foreground-muted text-sm") { "Invite teammates and manage their roles and permissions." }
        TabsContent(value: "billing", class: "text-foreground-muted text-sm") { "Your current plan, invoices, and payment method." }
      end
    end
  end

  # @label With icons & badges
  def icons
    phlex do
      Tabs(default_value: "overview", class: "w-full max-w-md") do
        div(class: "overflow-x-auto [scrollbar-width:none]") do
          TabsList do
            TabsTrigger(value: "overview") { Icon(:layout_grid, data: { icon: "start" }); plain "Overview" }
            TabsTrigger(value: "activity") { Icon(:activity, data: { icon: "start" }); plain "Activity"; Badge(variant: :outline, size: :sm) { "12" } }
            TabsTrigger(value: "settings") { Icon(:settings, data: { icon: "start" }); plain "Settings" }
          end
        end
        PANELS.each { |value, (_, text)| TabsContent(value:, class: "text-foreground-muted text-sm") { text } }
      end
    end
  end

  # @label Icon-only
  # `icon: true` makes square tabs - label each one.
  def icon_only
    phlex do
      Tabs(default_value: "grid") do
        TabsList do
          TabsTrigger(value: "grid", icon: true, aria_label: "Grid view") { Icon(:layout_grid) }
          TabsTrigger(value: "list", icon: true, aria_label: "List view") { Icon(:list) }
          TabsTrigger(value: "chart", icon: true, aria_label: "Chart view") { Icon(:chart_bar) }
        end
      end
    end
  end

  # @label Controlled
  # Dispatch `ui--tabs:select` with { value } to switch from elsewhere; `ui--tabs:change` reports it.
  def controlled
    phlex do
      div(class: "flex w-full max-w-sm flex-col gap-5", data: { demo: "wizard" }) do
        Tabs(default_value: "account", id: "wizard-tabs") do
          TabsList do
            TabsTrigger(value: "account") { "Account" }
            TabsTrigger(value: "profile") { "Profile" }
            TabsTrigger(value: "review") { "Review" }
          end
          TabsContent(value: "account", class: "text-foreground-muted text-sm") { "Step 1 - choose a username and password." }
          TabsContent(value: "profile", class: "text-foreground-muted text-sm") { "Step 2 - tell us a little about yourself." }
          TabsContent(value: "review", class: "text-foreground-muted text-sm") { "Step 3 - review everything and submit." }
        end
        div(class: "flex gap-2") do
          Button(variant: :outline, size: :sm, disabled: true, data: { step: "-1" }) { "Back" }
          Button(size: :sm, data: { step: "1" }) { "Next" }
        end
      end
      script(type: "module") do
        raw safe(<<~JS)
          const demo = document.querySelector("[data-demo=wizard]")
          const tabs = document.getElementById("wizard-tabs")
          const steps = [ "account", "profile", "review" ]
          let index = 0
          const buttons = demo.querySelectorAll("[data-step]")
          const sync = () => { buttons[0].disabled = index === 0; buttons[1].disabled = index === steps.length - 1 }
          buttons.forEach(button => button.addEventListener("click", () => {
            index = Math.max(0, Math.min(steps.length - 1, index + Number(button.dataset.step)))
            tabs.dispatchEvent(new CustomEvent("ui--tabs:select", { detail: { value: steps[index] } }))
          }))
          tabs.addEventListener("ui--tabs:change", ({ detail: { value } }) => { index = steps.indexOf(value); sync() })
        JS
      end
    end
  end

  # A disabled tab is skipped by the arrow keys.
  def disabled
    phlex do
      Tabs(default_value: "overview", class: "w-full max-w-md") do
        TabsList do
          TabsTrigger(value: "overview") { "Overview" }
          TabsTrigger(value: "activity") { "Activity" }
          TabsTrigger(value: "billing", disabled: true) { "Billing" }
        end
        TabsContent(value: "overview", class: "text-foreground-muted text-sm") { "The billing tab is disabled until you upgrade to a paid plan." }
        TabsContent(value: "activity", class: "text-foreground-muted text-sm") { "Every change across the team, newest first." }
      end
    end
  end

  # @label RTL
  # The indicator and ←/→ follow the reading direction.
  def rtl
    phlex do
      div(dir: "rtl", class: "flex w-full max-w-md flex-col gap-8") do
        %i[ pill line ].each do |variant|
          Tabs(default_value: "overview", variant:) do
            TabsList do
              TabsTrigger(value: "overview") { "نظرة عامة" }
              TabsTrigger(value: "activity") { "النشاط" }
              TabsTrigger(value: "settings") { "الإعدادات" }
            end
          end
        end
      end
    end
  end
end
