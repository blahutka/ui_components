# An indicator that shows a loading state.
#
# An indeterminate "working on it" indicator in two shapes: a sweeping bar and flowing dots.
# It reads a little more like progress than a Spinner, so it suits section- and status-level
# waits. Sized by font-size; `current_color:` takes the surrounding text color.
#
# @label Loader
# @logical_path Status & Feedback
# @component UI::Loader
# @display width wide
class UI::LoaderPreview < UI::BasePreview
  ITEMS = %w[ Aurora Borealis Cosmos Drift Ember Flux Glow Halo Ion ].freeze

  # @label Usage
  # @param variant [Symbol] select { choices: [bar, dots] }
  # @param size [Symbol] select "Font size" { choices: [text-xl, text-3xl, text-[2.5rem], text-5xl, text-7xl] }
  # @param current_color [Boolean] toggle "Inherit the text color (violet here)"
  def default(variant: :bar, size: :"text-[2.5rem]", current_color: false)
    phlex do
      span(class: "text-violet-500") { Loader(variant:, current_color:, class: size.to_s) }
    end
  end

  # Two shapes - a sweeping track and a flowing trio. Under prefers-reduced-motion both hold a
  # static frame.
  def variants
    phlex do
      div(class: "flex items-center gap-12") do
        %i[ bar dots ].each do |variant|
          div(class: "flex flex-col items-center gap-3") do
            Loader(variant:)
            span(class: "text-foreground-muted text-xs") { variant.to_s }
          end
        end
      end
    end
  end

  # Scales with font-size at a fixed ratio - a text-* utility resizes it.
  def sizing
    phlex do
      div(class: "flex flex-wrap items-center gap-8") do
        %w[ text-xl text-3xl text-5xl text-7xl ].each { |size| Loader(class: size) }
      end
    end
  end

  # The primary accent with a soft track by default; `current_color: true` adopts the text color.
  def color
    phlex do
      div(class: "flex items-center gap-12 text-4xl") do
        Loader()
        %w[ text-violet-500 text-success-emphasis ].each do |color|
          span(class: color) { Loader(current_color: true) }
        end
      end
    end
  end

  # @label Load more
  # The button shows the dots loader while the next page "fetches"; `current_color:` matches
  # the button text.
  def load_more
    phlex do
      div(class: "flex w-56 flex-col gap-2", data: { demo: "load-more" }) do
        ul(class: "flex flex-col gap-2") do
          ITEMS.each_with_index do |item, index|
            li(class: "bg-background-subtle border-border-muted text-foreground-emphasis rounded-lg border px-4 py-3 text-sm", hidden: index >= 3) { item }
          end
        end
        Button(class: "self-center") do
          span { "Load more" }
          Loader(variant: :dots, current_color: true, class: "text-3xl", hidden: true)
        end
      end
      script(type: "module") do
        raw safe(<<~JS)
          const demo = document.querySelector("[data-demo=load-more]")
          const button = demo.querySelector("button")
          const [label, loader] = button.children

          button.addEventListener("click", () => {
            button.disabled = true
            label.hidden = true
            loader.hidden = false
            setTimeout(() => {
              ;[ ...demo.querySelectorAll("li[hidden]") ].slice(0, 3).forEach(item => item.hidden = false)
              button.disabled = false
              label.hidden = false
              loader.hidden = true
              button.hidden = !demo.querySelector("li[hidden]")
            }, 1400)
          })
        JS
      end
    end
  end

  # @label Section loading
  # Show a centered loader while a panel's data is in flight, then swap in the content.
  # Refresh re-runs it.
  def section
    phlex do
      div(class: "border-border bg-background w-80 overflow-hidden rounded-xl border", data: { demo: "section" }) do
        div(class: "border-border-muted bg-background-subtle flex items-center justify-between border-b px-4 py-2.5") do
          span(class: "text-foreground-intense text-sm font-semibold") { "Revenue" }
          Button(variant: :outline, size: :sm) { "Refresh" }
        end
        div(class: "flex h-32 items-center justify-center p-4") do
          div(class: "flex flex-col items-center gap-3") do
            Loader(variant: :bar, class: "text-4xl")
            span(class: "text-foreground-muted text-xs") { "Crunching the numbers…" }
          end
          div(class: "text-center", hidden: true) do
            p(class: "text-foreground-intense mb-0.5 text-3xl font-semibold") { "$48,250" }
            p(class: "text-success-emphasis text-sm") { "+12.5% this month" }
          end
        end
      end
      script(type: "module") do
        raw safe(<<~JS)
          const demo = document.querySelector("[data-demo=section]")
          const button = demo.querySelector("button")
          const [loading, ready] = demo.lastElementChild.children
          const load = () => {
            button.disabled = true
            loading.hidden = false
            ready.hidden = true
            setTimeout(() => {
              button.disabled = false
              loading.hidden = true
              ready.hidden = false
            }, 1800)
          }
          button.addEventListener("click", load)
          load()
        JS
      end
    end
  end

  # @label Inline status
  # Sized in em with `current_color:`, a loader sits on the line next to a status message.
  def inline_status
    phlex do
      div(class: "flex flex-col gap-4 text-sm") do
        span(class: "text-foreground-muted inline-flex items-center gap-2") do
          plain "Syncing your changes"
          Loader(variant: :dots, current_color: true, class: "text-[1.6em]")
        end
        span(class: "text-secondary-emphasis inline-flex items-center gap-2") do
          plain "Uploading 3 files"
          Loader(variant: :bar, current_color: true, class: "text-[1.6em]")
        end
      end
    end
  end

  # @label RTL
  # Beside text, the loader follows the inline flow onto the correct side.
  def rtl
    phlex do
      div(dir: "rtl", class: "flex flex-col gap-4 text-sm") do
        span(class: "text-foreground-muted inline-flex items-center gap-2") do
          plain "جارٍ مزامنة تغييراتك"
          Loader(variant: :dots, current_color: true, class: "text-[1.6em]")
        end
        span(class: "text-secondary-emphasis inline-flex items-center gap-2") do
          plain "جارٍ رفع 3 ملفات"
          Loader(variant: :bar, current_color: true, class: "text-[1.6em]")
        end
      end
    end
  end
end
