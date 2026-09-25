# A single-line text field, with icons and an optional clear button.
#
# Native attributes pass straight to the <input>. Adornments (`start_slot:` / `end_slot:` - an
# icon name, text or a block) and `clearable:` wrap it in one frame. Label it with a Field, a
# <label for> or aria_label.
#
# @label Input
# @logical_path Actions & Inputs
# @component UI::Input
# @display width wide
class UI::InputPreview < UI::BasePreview
  # @label Usage
  # @param placeholder text
  # @param variant [Symbol] select { choices: [outline, soft] }
  # @param size [Symbol] select { choices: [sm, md, lg] }
  # @param start_icon [Boolean] toggle
  # @param end_icon [Boolean] toggle
  # @param clearable [Boolean] toggle
  # @param disabled [Boolean] toggle
  def default(placeholder: "Placeholder text", variant: :outline, size: :md, start_icon: false, end_icon: false, clearable: false, disabled: false)
    phlex do
      Input(placeholder:, variant:, size:, clearable:, disabled:, start_slot: (:search if start_icon), end_slot: (:at if end_icon),
        aria_label: "Playground", class: "max-w-70")
    end
  end

  # `variant:` - a bordered outline (default) or a filled soft field.
  def variants
    phlex do
      div(class: "flex w-full max-w-70 flex-col gap-4") do
        Input(variant: :outline, placeholder: "Outline", aria_label: "Outline")
        Input(variant: :soft, placeholder: "Soft", aria_label: "Soft")
      end
    end
  end

  # `size:` scales height, padding and text.
  def sizes
    phlex do
      div(class: "flex w-full max-w-70 flex-col gap-4") do
        { sm: "Small", md: "Medium", lg: "Large" }.each { |size, label| Input(size:, placeholder: label, aria_label: label) }
      end
    end
  end

  # @label Start & end slots
  # A slot takes an icon name, text, or a block - here an Avatar and a password-visibility Button.
  def slots
    phlex do
      div(class: "flex w-full max-w-70 flex-col gap-4") do
        Input(start_slot: :mail, end_slot: -> { span(class: "text-foreground-muted text-sm") { "@example.com" } }, placeholder: "yourname", aria_label: "Email username")
        Input(start_slot: -> { Avatar(size: :"2xs") { AvatarFallback { Icon(:user_filled) } } }, placeholder: "Display name", aria_label: "Display name")
        Input(type: "password", value: "hidden@password", start_slot: :lock, aria_label: "Password", data: { demo: "password" },
          end_slot: -> { Button(variant: :ghost, size: :sm, icon: true, aria_label: "Show password", class: "-me-1.5", data: { demo: "reveal" }) { Icon(:eye) } })
      end
      script(type: "module") do
        raw safe(<<~JS)
          const button = document.querySelector("[data-demo=reveal]")
          const input = document.querySelector("[data-demo=password]")
          button.addEventListener("click", () => {
            const show = input.type === "password"
            input.type = show ? "text" : "password"
            button.setAttribute("aria-label", show ? "Hide password" : "Show password")
            button.querySelector("svg").outerHTML = show ? #{UI::Icon.new(:eye_off).call.to_json} : #{UI::Icon.new(:eye).call.to_json}
          })
        JS
      end
    end
  end

  # `clearable: true` adds a ✕ once the field has a value; it empties the field and fires `input`.
  def clearable
    phlex do
      Input(clearable: true, start_slot: :search, value: "Wireless headphones", aria_label: "Search products", class: "max-w-70")
    end
  end

  # @label Disabled, read-only & error states
  # `invalid: true` (or aria_invalid) paints the error state; inside a Field the field sets it.
  def states
    phlex do
      div(class: "flex w-full max-w-70 flex-col gap-4") do
        Input(placeholder: "Disabled", disabled: true, aria_label: "Disabled")
        Input(value: "Read-only value", readonly: true, aria_label: "Read-only")
        Input(value: "Input with error", invalid: true, aria_label: "Input with error")
      end
    end
  end

  # @label RTL
  # The text aligns to the start edge and the adornments swap sides.
  def rtl
    phlex do
      div(dir: "rtl", class: "w-full max-w-70") do
        Input(start_slot: :search, clearable: true, value: "سماعات لاسلكية", placeholder: "ابحث عن منتج", aria_label: "بحث")
      end
    end
  end
end
