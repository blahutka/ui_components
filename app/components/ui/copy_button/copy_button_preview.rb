# A Button that copies text, then swaps its icon for a drawn check.
#
# @label Copy Button
# @logical_path Actions & Inputs
# @component UI::CopyButton
# @display width wide
class UI::CopyButtonPreview < UI::BasePreview
  # Props not in the Usage form (data, render blocks, generated ids): see ui_components:preview_params
  UNLISTED_PROPS = %i[ target icon ].freeze

  # @label Usage
  # @param value text
  # @param variant [Symbol] select { choices: [ghost, soft, outline, primary_outline, primary, secondary] }
  # @param label text
  # @param copied_label text
  # @param timeout number
  # @param size text
  def default(value: "npm install @appica/ui-react", variant: :ghost, label: nil, copied_label: nil, timeout: 2000, size: "sm")
    phlex do
      CopyButton(value:, variant:, timeout:, size:, **given(label:, copied_label:))
    end
  end

  def variants
    phlex do
      div(class: "flex flex-wrap items-center gap-3") do
        %i[ ghost soft outline primary_outline primary secondary ].each { |variant| CopyButton(value: variant.to_s, variant:) }
      end
    end
  end

  # Square icon sizes by default; give it a block for a text label (then `sm` / `md` / `lg`).
  def sizes
    phlex do
      div(class: "flex items-center gap-3") do
        %i[ sm md lg ].each { |size| CopyButton(value: size.to_s, variant: :outline, size:) }
      end
    end
  end

  # @label With a label
  # A text label swaps to `copied_label:` while copied.
  def with_label
    phlex { CopyButton(value: "npm install @appica/ui-react", variant: :outline, copied_label: "Copied!") { "Copy" } }
  end

  # @label Custom icon
  def custom_icon
    phlex { CopyButton(value: "https://appica.dev/ui", icon: :link, label: "Copy link", copied_label: "Link copied", variant: :outline, size: :md) }
  end

  # @label Copy from an element
  # `target:` copies another element's text (or an input's value).
  def from_element
    phlex do
      div(class: "border-border-muted bg-background-subtle relative w-full max-w-90 rounded-lg border py-3 ps-4 pe-12") do
        code(id: "install-command", class: "text-foreground font-mono text-sm") { "npm install @appica/ui-react" }
        div(class: "absolute inset-e-2 top-1/2 -translate-y-1/2") { CopyButton(target: "#install-command", label: "Copy command") }
      end
    end
  end
end
