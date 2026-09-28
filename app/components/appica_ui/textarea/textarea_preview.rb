# A multi-line text field, sharing Input's appearance, variants and sizes.
#
# `rows:` seeds the height and it still resizes vertically. Slots align to the first line and
# `clearable:` adds a ✕.
#
# @label Textarea
# @logical_path Actions & Inputs
# @component AppicaUI::Textarea
# @display width wide
class AppicaUI::TextareaPreview < AppicaUI::BasePreview
  # Props not in the Usage form (data, render blocks, generated ids): see ui_components:preview_params
  UNLISTED_PROPS = %i[ start_slot end_slot invalid textarea ].freeze

  # @label Usage
  # @param placeholder text
  # @param rows number
  # @param variant [Symbol] select {{ choices_for AppicaUI::Textarea, :variant }}
  # @param size [Symbol] select {{ choices_for AppicaUI::Textarea, :size }}
  # @param clearable [Boolean] toggle
  # @param disabled [Boolean] toggle
  # @param value text
  # @param clear_label text
  def default(placeholder: "Write a message…", rows: 4, variant: :outline, size: :md, clearable: false, disabled: false, value: nil, clear_label: nil)
    phlex do
      Textarea(placeholder:, variant:, size:, clearable:, disabled:, **given(value:, clear_label:), rows: rows.to_i, aria_label: "Message", class: "max-w-70")
    end
  end

  def variants
    phlex do
      div(class: "flex w-full max-w-70 flex-col gap-4") do
        Textarea(variant: :outline, placeholder: "Outline", aria_label: "Outline")
        Textarea(variant: :soft, placeholder: "Soft", aria_label: "Soft")
      end
    end
  end

  def sizes
    phlex do
      div(class: "flex w-full max-w-70 flex-col gap-4") do
        { sm: "Small", md: "Medium", lg: "Large" }.each { |size, label| Textarea(size:, placeholder: label, aria_label: label) }
      end
    end
  end

  # @label Start & end slots
  # A compact composer (an avatar and a send button) and a live character counter.
  def slots
    phlex do
      div(class: "flex w-full max-w-70 flex-col gap-4") do
        Textarea(rows: 4, placeholder: "Add a comment…", aria_label: "Comment", class: "*:data-[slot=textarea-end]:h-full *:data-[slot=textarea-end]:items-end",
          start_slot: -> { Avatar(size: :"2xs") { AvatarFallback { Icon(:user_filled) } } },
          end_slot: -> { Button(variant: :soft, size: :sm, icon: true, aria_label: "Send comment") { Icon(:send_2) } })
        Textarea(rows: 3, maxlength: 180, placeholder: "What's on your mind?", aria_label: "Status", data: { demo: "status" },
          end_slot: -> { span(class: "text-foreground-muted text-xs tabular-nums", data: { demo: "count" }) { "0/180" } })
      end
      script(type: "module") do
        raw safe(<<~JS)
          const status = document.querySelector("[data-demo=status]")
          const count = document.querySelector("[data-demo=count]")
          status.addEventListener("input", () => count.textContent = `${status.value.length}/180`)
        JS
      end
    end
  end

  def clearable
    phlex do
      Textarea(clearable: true, value: "The quick brown fox jumps over the lazy dog.", aria_label: "Notes", class: "max-w-70")
    end
  end

  # @label Disabled, read-only & error states
  def states
    phlex do
      div(class: "flex w-full max-w-70 flex-col gap-4") do
        Textarea(placeholder: "Disabled", disabled: true, aria_label: "Disabled")
        Textarea(value: "Read-only content", readonly: true, aria_label: "Read-only")
        Textarea(value: "Too short", invalid: true, aria_label: "Notes with error")
      end
    end
  end

  # @label RTL
  def rtl
    phlex do
      div(dir: "rtl", class: "w-full max-w-70") do
        Textarea(rows: 3, placeholder: "اكتب رسالتك…", aria_label: "رسالة")
      end
    end
  end
end
