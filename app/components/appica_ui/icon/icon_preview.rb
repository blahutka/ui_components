# The Appica icon set: ~5,000 SVG icons (Tabler, Hugeicons and custom designs), normalized and
# organized into categories. One component draws any of them by name.
#
#   Icon(:star)
#   Icon(:star_filled, size: 20, class: "text-warning-emphasis")
#
# @label Icon
# @logical_path Icons
# @component AppicaUI::Icon
# @display width wide
class AppicaUI::IconPreview < AppicaUI::BasePreview
  # @label Usage
  # Any catalog name - kebab-case, a symbol with underscores, or the React PascalCase name.
  # @param name text "Icon name (see the Gallery)"
  # @param size number
  # @param stroke_width number
  # @param color [Symbol] select { choices: [text-foreground-intense, text-primary, text-secondary-emphasis, text-success-emphasis, text-warning-emphasis, text-error-emphasis] }
  def default(name: "rocket", size: 48, stroke_width: 1.5, color: :"text-foreground-intense")
    phlex do
      if AppicaUI::IconLibrary.index.key?(AppicaUI::IconLibrary.normalize(name))
        Icon(name, size: size.to_i, stroke_width: stroke_width.to_f, class: color.to_s)
      else
        p(class: "text-error-emphasis text-sm") { "No icon named “#{name}” - try the Gallery." }
      end
    end
  end

  # Browse and search every icon. Click one to copy its `Icon(...)` call.
  # @display width full
  # @display min_height 40rem
  def gallery
    phlex { render AppicaUI::IconPreview::Gallery.new }
  end

  # `size:` sets width and height in pixels (24 by default) - or size it with a `size-*` class.
  def sizes
    phlex do
      div(class: "text-foreground-intense flex items-end gap-6") do
        [ 16, 20, 24, 32, 48 ].each do |size|
          div(class: "flex flex-col items-center gap-2") do
            Icon(:photo, size:)
            span(class: "text-foreground-muted text-xs") { size.to_s }
          end
        end
      end
    end
  end

  # @label Stroke width
  # Outline icons take `stroke_width:` (1.5 by default); filled icons ignore it.
  def stroke_width
    phlex do
      div(class: "text-foreground-intense flex items-end gap-6") do
        [ 1, 1.5, 2, 2.5 ].each do |stroke_width|
          div(class: "flex flex-col items-center gap-2") do
            Icon(:settings, size: 32, stroke_width:)
            span(class: "text-foreground-muted text-xs") { stroke_width.to_s }
          end
        end
      end
    end
  end

  # @label Outline & filled
  # Filled variants are separate icons with a `-filled` suffix.
  def filled
    phlex do
      div(class: "text-foreground-intense grid grid-cols-5 gap-6") do
        %i[ heart star bell bookmark circle_check ].each do |name|
          div(class: "flex flex-col items-center gap-3") do
            Icon(name, size: 28)
            Icon(:"#{name}_filled", size: 28)
            span(class: "text-foreground-muted text-xs") { name.to_s }
          end
        end
      end
    end
  end

  # Icons draw with currentColor - color them with a `text-*` class (or `color:`).
  def color
    phlex do
      div(class: "flex items-center gap-5") do
        %w[ text-primary text-secondary-emphasis text-info-emphasis text-success-emphasis text-warning-emphasis text-error-emphasis ].each do |color|
          Icon(:circle_check_filled, size: 28, class: color)
        end
        Icon(:heart_filled, size: 28, color: "#ec4899")
      end
    end
  end

  # @label In a button
  # Buttons size their icons; `data: { icon: "start" }` (or "end") tightens the padding on that side.
  def in_button
    phlex do
      div(class: "flex flex-wrap items-center gap-3") do
        Button do
          Icon(:download, data: { icon: "start" })
          plain "Export"
        end
        Button(variant: :outline) do
          plain "Next"
          Icon(:arrow_right, data: { icon: "end" }, class: "rtl:rotate-180")
        end
        Button(variant: :soft, icon: true, aria_label: "Settings") { Icon(:settings) }
      end
    end
  end

  # @label Accessible icon
  # Icons are aria-hidden by default. A standalone meaningful icon gets `aria_label:`, which
  # renders it as role="img" instead.
  def accessible
    phlex do
      div(class: "text-foreground-intense flex items-center gap-2 text-sm") do
        Icon(:alert_triangle_filled, size: 20, class: "text-warning-emphasis", aria_label: "Warning")
        span { "Storage almost full" }
      end
    end
  end

  # The searchable grid of every icon, grouped by category
  class Gallery < AppicaUI::Base
    FIELD = "border-border-strong bg-background text-foreground h-9 rounded-md border px-3 text-sm outline-none focus:border-transparent focus:ring-3 focus:ring-ring-input"

    def view_template
      div(data: { icon_gallery: "" }, class: "flex flex-col gap-6 [--gallery-size:24px] [--gallery-stroke:1.5]") do
        toolbar
        p(class: "text-foreground-muted text-sm", data: { count: "" }) { "#{AppicaUI::IconLibrary.names.size.to_fs(:delimited)} icons" }
        AppicaUI::IconLibrary.categories.each { |category| section_for(category) }
        p(class: "text-foreground-muted py-10 text-center text-sm", data: { empty: "" }, hidden: true) { "No icons match your search." }
      end
      render AppicaUI::Toaster.new(position: :bottom_center)
      script(type: "module") { raw safe(SCRIPT) }
    end

    private
      def toolbar
        div(class: "bg-background/90 sticky top-0 z-10 flex flex-wrap items-end gap-4 py-2 backdrop-blur") do
          label(class: "flex min-w-56 flex-1 flex-col gap-1 text-xs") do
            span(class: "text-foreground-muted") { "Search" }
            input(type: "search", placeholder: "Search icons…", data: { search: "" }, class: FIELD)
          end
          label(class: "flex flex-col gap-1 text-xs") do
            span(class: "text-foreground-muted") { "Style" }
            select(data: { style: "" }, class: FIELD) do
              option(value: "all") { "All" }
              option(value: "outline") { "Outline" }
              option(value: "filled") { "Filled" }
            end
          end
          label(class: "flex flex-col gap-1 text-xs") do
            span(class: "text-foreground-muted") { "Category" }
            select(data: { category: "" }, class: FIELD) do
              option(value: "") { "All categories" }
              AppicaUI::IconLibrary.categories.each { |category| option(value: category) { category.tr("-", " ").capitalize } }
            end
          end
          slider("Size", "size", min: 16, max: 48, step: 2, value: 24, unit: "px")
          slider("Stroke width", "stroke", min: 1, max: 2.5, step: 0.25, value: 1.5)
        end
      end

      def slider(text, key, min:, max:, step:, value:, unit: "")
        label(class: "flex w-36 flex-col gap-1 text-xs") do
          span(class: "text-foreground-muted flex justify-between") do
            plain text
            span(data: { "#{key}_output": "" }) { "#{value}#{unit}" }
          end
          input(type: "range", min:, max:, step:, value:, data: { "#{key}": unit }, class: "accent-(--primary) h-9")
        end
      end

      def section_for(category)
        section(data: { section: category }, class: "[content-visibility:auto] [contain-intrinsic-size:auto_20rem]") do
          h3(class: "text-foreground-intense mb-3 text-sm font-semibold") { category.tr("-", " ").capitalize }
          div(class: "grid grid-cols-[repeat(auto-fill,minmax(3.5rem,1fr))] gap-1 *:text-foreground-emphasis *:hover:bg-background-muted *:hover:text-foreground-intense *:focus-visible:ring-ring *:flex *:aspect-square *:items-center *:justify-center *:rounded-lg *:outline-none *:focus-visible:ring-2 [&_svg]:size-(--gallery-size) [&_svg[stroke]]:[stroke-width:var(--gallery-stroke)]") do
            AppicaUI::IconLibrary.each(category) do |name, _category|
              button(type: "button", title: name, aria_label: name, data: { name:, filled: name.end_with?("-filled").to_s, snippet: snippet(name) }) do
                render AppicaUI::Icon.new(name)
              end
            end
          end
        end
      end

      # Icon(:arrow_back_up), or the string form when the name isn't a plain symbol
      def snippet(name)
        symbol = name.tr("-", "_")
        symbol.match?(/\A[a-z_][a-z0-9_]*\z/) ? "Icon(:#{symbol})" : %(Icon("#{name}"))
      end

      SCRIPT = <<~JS
        const gallery = document.querySelector("[data-icon-gallery]")
        const search = gallery.querySelector("[data-search]")
        const style = gallery.querySelector("[data-style]")
        const category = gallery.querySelector("[data-category]")
        const count = gallery.querySelector("[data-count]")
        const empty = gallery.querySelector("[data-empty]")
        const sections = [ ...gallery.querySelectorAll("[data-section]") ]
        const format = new Intl.NumberFormat()

        const filter = () => {
          const terms = search.value.trim().toLowerCase().split(/\\s+/).filter(Boolean)
          let total = 0
          sections.forEach(section => {
            let visible = 0
            const inCategory = !category.value || section.dataset.section === category.value
            section.querySelectorAll("button").forEach(button => {
              const { name, filled } = button.dataset
              const show = inCategory && terms.every(term => name.includes(term)) &&
                (style.value === "all" || (style.value === "filled") === (filled === "true"))
              button.hidden = !show
              if (show) visible++
            })
            section.hidden = visible === 0
            total += visible
          })
          count.textContent = `${format.format(total)} icons`
          empty.hidden = total > 0
        }

        const slide = (key, variable) => {
          const input = gallery.querySelector(`[data-${key}]`)
          const output = gallery.querySelector(`[data-${key}-output]`)
          input.addEventListener("input", () => {
            gallery.style.setProperty(variable, `${input.value}${input.dataset[key]}`)
            output.textContent = `${input.value}${input.dataset[key]}`
          })
        }

        search.addEventListener("input", filter)
        style.addEventListener("change", filter)
        category.addEventListener("change", filter)
        slide("size", "--gallery-size")
        slide("stroke", "--gallery-stroke")

        gallery.addEventListener("click", async event => {
          const button = event.target.closest("button[data-snippet]")
          if (!button) return

          const { snippet } = button.dataset
          if (await copy(snippet)) {
            window.AppicaUI?.toast?.add({ title: "Copied to clipboard", description: snippet, icon: "success", timeout: 2500 })
          } else {
            window.AppicaUI?.toast?.add({ title: snippet, description: "Copy it from here - clipboard access was blocked.", timeout: 6000 })
          }
          button.focus()
        })

        // Lookbook renders previews in an iframe without clipboard permission, where
        // navigator.clipboard is refused - fall back to copying a selected textarea
        async function copy(text) {
          try {
            await navigator.clipboard.writeText(text)
            return true
          } catch {
            const field = Object.assign(document.createElement("textarea"), { value: text, readOnly: true })
            field.style.cssText = "position: fixed; top: 0; left: 0; opacity: 0; pointer-events: none"
            document.body.append(field)
            field.select()
            try {
              return document.execCommand("copy")
            } catch {
              return false
            } finally {
              field.remove()
            }
          }
        }
      JS
  end
end
