# A compact pill for tags, filters and removable tokens, in Button's palette.
#
# @label Chip
# @logical_path Actions & Inputs
# @component UI::Chip
# @display width wide
class UI::ChipPreview < UI::BasePreview
  # @label Usage
  # @param variant [Symbol] select {{ choices_for UI::Chip, :variant }}
  # @param size [Symbol] select {{ choices_for UI::Chip, :size }}
  # @param dismissible [Boolean] toggle
  # @param disabled [Boolean] toggle
  # @param close_label text
  def default(variant: :soft, size: :md, dismissible: false, disabled: false, close_label: nil)
    phlex { Chip(variant:, size:, dismissible:, disabled:, **given(close_label:)) { "Label" } }
  end

  def variants
    phlex do
      div(class: "flex flex-wrap items-center gap-2") do
        UI::Chip::VARIANTS.each_key { |variant| Chip(variant:, class: "capitalize") { variant.to_s } }
      end
    end
  end

  def sizes
    phlex do
      div(class: "flex flex-wrap items-center gap-2") do
        { sm: "Small", md: "Medium", lg: "Large" }.each { |size, text| Chip(size:) { text } }
      end
    end
  end

  # @label With an icon
  # Mark the icon `data: { icon: "start" }` or `"end"` for the tighter inner spacing.
  def with_icon
    phlex do
      div(class: "flex flex-wrap items-center gap-2") do
        Chip(variant: :soft) { Icon(:plus, data: { icon: "start" }); plain "New" }
        Chip(variant: :primary) { Icon(:circle_check, data: { icon: "start" }); plain "Verified" }
        Chip(variant: :outline) { plain "4.9"; Icon(:star, data: { icon: "end" }) }
      end
    end
  end

  # Clicking a dismissible chip animates it out and removes it; `ui--chip:dismiss` fires first
  # (cancel it to remove the chip yourself, e.g. with a Turbo Stream).
  def dismissible
    phlex do
      div(class: "flex min-h-8 flex-wrap items-center gap-2") do
        %w[ Design Engineering Marketing Sales ].each { |tag| Chip(dismissible: true, close_label: "Remove #{tag}") { tag } }
      end
    end
  end

  # @label Selectable filters
  # A chip is a button: swap the variant and set aria-pressed to show the active one.
  def filters
    phlex do
      div(class: "flex flex-wrap items-center gap-2", data: { demo: "filters" }) do
        %w[ All Active Completed Archived ].each do |option|
          selected = option == "Active"
          Chip(variant: (selected ? :primary : :outline), aria_pressed: selected.to_s) do
            Icon(:check, data: { icon: "start" }, hidden: !selected)
            plain option
          end
        end
      end
      script(type: "module") do
        raw safe(<<~JS)
          const filters = document.querySelector("[data-demo=filters]")
          const classes = { primary: #{UI::Chip::VARIANTS[:primary].to_json}, outline: #{UI::Chip::VARIANTS[:outline].to_json} }
          filters.addEventListener("click", ({ target }) => {
            const chosen = target.closest("[data-slot=chip]")
            if (!chosen) return
            filters.querySelectorAll("[data-slot=chip]").forEach(chip => {
              const selected = chip === chosen, from = selected ? "outline" : "primary", to = selected ? "primary" : "outline"
              if (chip.dataset.variant !== to) {
                chip.classList.remove(...classes[from].split(" "))
                chip.classList.add(...classes[to].split(" "))
                chip.dataset.variant = to
              }
              chip.setAttribute("aria-pressed", selected)
              chip.querySelector("svg").toggleAttribute("hidden", !selected)
            })
          })
        JS
      end
    end
  end

  # @label Chip group
  # Shares variant and size; dispatching `ui--chip-group:clear` on it dismisses them all.
  def group
    phlex do
      div(class: "flex flex-col items-start gap-3") do
        ChipGroup(id: "chip-filters", variant: :outline) do
          %w[ React TypeScript Tailwind Motion Base\ UI ].each { |filter| Chip(dismissible: true) { filter } }
        end
        Button(size: :sm, variant: :ghost, data: { demo: "clear" }) { "Clear all" }
      end
      script(type: "module") do
        raw safe(%(document.querySelector("[data-demo=clear]").addEventListener("click", () => document.getElementById("chip-filters").dispatchEvent(new Event("ui--chip-group:clear")))))
      end
    end
  end

  # @label Selectable (form)
  # ChipCheckbox: a chip around a hidden checkbox, so a set of them submits like check boxes.
  def selectable
    phlex do
      ChipGroup(variant: :outline, role: "group", aria_label: "Job type") do
        { remote: "Remote", full_time: "Full-time", part_time: "Part-time", contract: "Contract" }.each do |value, text|
          ChipCheckbox(name: "job_types[]", value:, checked: value == :remote) { text }
        end
      end
    end
  end

  # @label As a link
  # `href:` renders an <a> with the chip styling.
  def link
    phlex do
      div(class: "flex flex-wrap items-center gap-2") do
        Chip(href: "#design") { "#design" }
        Chip(href: "#engineering") { "#engineering" }
        Chip(href: "#featured", variant: :primary) { "#featured" }
      end
    end
  end

  # @label RTL
  def rtl
    phlex do
      div(dir: "rtl", class: "flex flex-wrap items-center gap-2") do
        %w[ تصميم هندسة تسويق ].each { |tag| Chip(dismissible: true) { tag } }
      end
    end
  end
end
