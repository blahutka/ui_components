# Displays the completion status of a task that takes a while.
#
# Tracks an upload, an import, an install moving toward completion (unlike Meter, a static
# measurement). `variant: :bar` puts the label and value above a track; `:circular` draws an
# SVG ring with the value in its center. Recolor with `indicator_color:`, weigh with `thickness:`.
#
# @label Progress
# @logical_path Status & Feedback
# @component UI::Progress
# @display width wide
class UI::ProgressPreview < UI::BasePreview
  # Props not in the Usage form (data, render blocks, generated ids): see ui_components:preview_params
  UNLISTED_PROPS = %i[ format locale ].freeze

  # @label Usage
  # The bar layout: a label on the left, the percentage on the right, the track beneath.
  # @param value number
  # @param variant [Symbol] select {{ choices_for UI::Progress, :variant }}
  # @param thickness number "Track weight in px (blank for the default)"
  # @param indicator_color [Symbol] select { choices: [var(--primary), var(--success-emphasis), var(--warning-emphasis), var(--secondary-emphasis)] }
  # @param min number
  # @param max number
  # @param size number
  def default(value: 60, variant: :bar, thickness: nil, indicator_color: :"var(--primary)", min: 0, max: 100, size: 64)
    phlex do
      Progress(variant:, min:, max:, value: value.to_f, thickness: thickness.presence&.to_i, indicator_color: indicator_color.to_s, size:, class: ("w-72 max-w-full" if variant.to_sym == :bar)) do
        ProgressLabel { "Uploading" }
        ProgressValue()
      end
    end
  end

  # `variant: :circular` draws a ring with the value centered; `size:` sets its diameter and an
  # optional ProgressLabel drops below.
  def circular
    phlex do
      div(class: "flex items-center gap-10") do
        Progress(variant: :circular, value: 72, size: 64) { ProgressValue() }
        Progress(variant: :circular, value: 40, size: 64) do
          ProgressValue()
          ProgressLabel { "Synced" }
        end
      end
    end
  end

  # @label Custom color & thickness
  # `indicator_color:` takes any CSS color (a theme token keeps it on-brand) and `thickness:`
  # the track weight in pixels - for both the bar and the ring.
  def custom
    phlex do
      div(class: "flex w-72 max-w-full flex-col gap-7") do
        Progress(value: 88, thickness: 10, indicator_color: "var(--success-emphasis)") do
          ProgressLabel { "Backup" }
          ProgressValue()
        end
        Progress(value: 24, thickness: 2, indicator_color: "var(--warning-emphasis)") do
          ProgressLabel { "Storage" }
          ProgressValue()
        end
        div(class: "flex justify-center") do
          Progress(variant: :circular, value: 62, size: 72, thickness: 8, indicator_color: "var(--secondary-emphasis)") { ProgressValue() }
        end
      end
    end
  end

  # @label File upload (controlled)
  # Advance the value as bytes arrive (here on a timer) by setting `data-ui--progress-value-value`;
  # the fill animates between values. At 100 the parts get data-complete, and the card swaps the
  # icon and label and reveals the action through `group-has-data-complete:` classes.
  def upload
    phlex do
      div(class: "group/upload border-border bg-background w-80 max-w-full rounded-xl border p-4") do
        div(class: "flex items-center gap-3") do
          span(class: "bg-background-muted text-foreground-muted group-has-data-complete/upload:bg-success-subtle group-has-data-complete/upload:text-success-emphasis flex size-12 shrink-0 items-center justify-center rounded-lg transition-colors") do
            Icon(:photo, stroke_width: 1.75, class: "size-5 group-has-data-complete/upload:hidden")
            svg(viewBox: "0 0 24 24", fill: "none", aria_hidden: "true", class: "hidden size-5 group-has-data-complete/upload:block") do |s|
              s.path(d: "M5 12.5l4.5 4.5L19 7", stroke: "currentColor", stroke_width: "2", stroke_linecap: "round", stroke_linejoin: "round", pathLength: "1",
                class: "[stroke-dasharray:1] [stroke-dashoffset:1] group-has-data-complete/upload:animate-[upload-check_500ms_ease-out_forwards] motion-reduce:[stroke-dashoffset:0]")
            end
          end
          div(class: "min-w-0 flex-1") do
            p(class: "text-foreground-intense truncate text-sm font-medium") { "cover-photo.jpg" }
            Progress(value: 0, class: "mt-1.5 gap-y-1", id: "upload-progress") do
              ProgressValue(class: "text-foreground-muted text-xs")
              ProgressLabel(class: "text-foreground-muted text-xs font-normal") do
                span(class: "group-has-data-complete/upload:hidden") { "Uploading…" }
                span(class: "hidden group-has-data-complete/upload:inline") { "Uploaded" }
              end
            end
          end
        end
        Button(variant: :soft, size: :sm, class: "mt-3 hidden w-full group-has-data-complete/upload:flex", id: "upload-again") { "Upload again" }
      end
      style { raw safe("@keyframes upload-check { to { stroke-dashoffset: 0 } }") }
      script(type: "module") do
        raw safe(<<~JS)
          const progress = document.getElementById("upload-progress")
          let timer
          const set = value => progress.setAttribute("data-ui--progress-value-value", value)
          const run = () => {
            clearInterval(timer)
            let value = 0
            set(value)
            timer = setInterval(() => {
              value = Math.min(100, value + 7)
              set(value)
              if (value >= 100) clearInterval(timer)
            }, 280)
          }
          document.getElementById("upload-again").addEventListener("click", run)
          run()
        JS
      end
    end
  end

  # @label RTL
  # The label and value swap sides and the bar fills from the right.
  def rtl
    phlex do
      div(dir: "rtl", class: "flex w-72 max-w-full flex-col items-center gap-7") do
        Progress(value: 60) do
          ProgressLabel { "جارٍ الرفع" }
          ProgressValue()
        end
        Progress(variant: :circular, value: 45, size: 64) { ProgressValue() }
      end
    end
  end
end
