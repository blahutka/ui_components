# Rich, interactive content floating beside a control.
#
# @label Popover
# @logical_path Overlays
# @component UI::Popover
# @display width wide
# @display min_height 320px
class UI::PopoverPreview < UI::BasePreview
  # Props not in the Usage form (data, render blocks, generated ids): see ui_components:preview_params
  UNLISTED_PROPS = %i[ id ].freeze

  # @label Usage
  # @param side [Symbol] select { choices: [bottom, top, left, right] }
  # @param align [Symbol] select { choices: [start, center, end] }
  # @param arrow [Boolean] toggle
  # @param default_open [Boolean] toggle
  def default(side: :bottom, align: :center, arrow: true, default_open: false)
    phlex do
      Popover(default_open:) do
        PopoverTrigger { |trigger| Button(**trigger, variant: :outline) { "Share" } }
        PopoverContent(side:, align:, arrow:) do
          PopoverTitle { "Share this page" }
          PopoverDescription { "Anyone with the link can view this document." }
          div(class: "mt-1 flex items-center gap-2") do
            Input(value: "https://appica.dev/docs", readonly: true, size: :sm, aria_label: "Link", class: "flex-1")
            CopyButton(value: "https://appica.dev/docs", variant: :outline)
          end
        end
      end
    end
  end

  # @label Form in a popover
  # Focus moves into the popup; PopoverClose on the actions dismisses it.
  def form
    phlex do
      Popover do
        PopoverTrigger { |trigger| Button(**trigger, variant: :outline) { Icon(:adjustments, data: { icon: "start" }); plain "Dimensions" } }
        PopoverContent(class: "w-72") do
          PopoverTitle { "Dimensions" }
          PopoverDescription { "Set the size of the selected layer." }
          div(class: "mt-1 grid grid-cols-2 gap-3") do
            Field { FieldLabel { "Width" }; Input(value: "320", inputmode: "numeric") }
            Field { FieldLabel { "Height" }; Input(value: "180", inputmode: "numeric") }
          end
          div(class: "mt-2 flex justify-end gap-2") do
            PopoverClose { |close| Button(**close, variant: :ghost, size: :sm) { "Cancel" } }
            PopoverClose { |close| Button(**close, size: :sm) { "Apply" } }
          end
        end
      end
    end
  end

  # @label Status picker
  # Navigation links as rows; choosing one closes the popover and updates the trigger.
  def status
    presets = { "🟢" => "Active", "🗓️" => "In a meeting", "🎧" => "Focusing", "🌴" => "On vacation", "🤒" => "Out sick" }
    phlex do
      Popover(data: { demo: "status" }) do
        PopoverTrigger { |trigger| Button(**trigger, variant: :outline) { span(aria_hidden: "true", data: { demo: "emoji" }) { "🟢" }; span(data: { demo: "label" }) { "Active" } } }
        PopoverContent(align: :start, class: "w-60 gap-0.5 p-1.5") do
          PopoverTitle(class: "text-foreground-muted px-2 pt-1 pb-1.5 text-xs font-medium") { "Set a status" }
          Navigation(orientation: :vertical, active_link: "Active") do
            presets.each do |emoji, label|
              NavigationLink(value: label, class: "w-full") do |link|
                button(**link, type: "button", data: { **link[:data], emoji:, label:, action: "ui--popover#close" }) do
                  span(aria_hidden: "true") { emoji }
                  plain label
                end
              end
            end
          end
        end
      end
      script(type: "module") do
        raw safe(<<~JS)
          const demo = document.querySelector("[data-demo=status]")
          demo.addEventListener("click", ({ target }) => {
            const row = target.closest("[data-label]")
            if (!row) return
            demo.querySelectorAll("[data-label]").forEach(other => {
              other.toggleAttribute("data-active", other === row)
              other === row ? other.setAttribute("aria-current", "page") : other.removeAttribute("aria-current")
            })
            demo.querySelector("[data-demo=emoji]").textContent = row.dataset.emoji
            demo.querySelector("[data-demo=label]").textContent = row.dataset.label
          })
        JS
      end
    end
  end

  # @label Open on hover
  # `open_on_hover:` on the trigger reveals it on pointer rest; it still opens on click and keyboard.
  def hover
    phlex do
      Popover do
        PopoverTrigger(open_on_hover: true, delay: 150) { |trigger| Button(**trigger, variant: :ghost, icon: true, aria_label: "Plan details") { Icon(:info_circle) } }
        PopoverContent(class: "w-64") do
          PopoverTitle { "Pro plan" }
          PopoverDescription { "Unlimited projects, priority support and 100 GB of storage." }
        end
      end
    end
  end

  # @label Without an arrow
  def no_arrow
    phlex do
      Popover do
        PopoverTrigger { |trigger| Button(**trigger, variant: :outline) { "No arrow" } }
        PopoverContent(arrow: false) do
          PopoverTitle { "Flat card" }
          PopoverDescription { "Sits closer to the trigger, without a pointer." }
        end
      end
    end
  end

  # @label Side & alignment
  # It flips and shifts to stay in view.
  def placement
    phlex do
      div(class: "flex flex-wrap items-center justify-center gap-3 py-24") do
        %i[ top right bottom left ].each do |side|
          Popover do
            PopoverTrigger { |trigger| Button(**trigger, variant: :outline, size: :sm) { side.to_s } }
            PopoverContent(side:) { PopoverDescription { "Opens on the #{side}." } }
          end
        end
      end
    end
  end

  # @label RTL
  def rtl
    phlex do
      div(dir: "rtl") do
        Popover do
          PopoverTrigger { |trigger| Button(**trigger, variant: :outline) { "مشاركة" } }
          PopoverContent(align: :start) do
            PopoverTitle { "شارك هذه الصفحة" }
            PopoverDescription { "يمكن لأي شخص لديه الرابط عرض هذا المستند." }
          end
        end
      end
    end
  end
end
