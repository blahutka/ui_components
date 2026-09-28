# A placeholder block shown while content loads.
#
# @label Skeleton
# @logical_path Status & Feedback
# @component AppicaUI::Skeleton
# @display width wide
class AppicaUI::SkeletonPreview < AppicaUI::BasePreview
  # @label Usage
  # @param effect [Symbol] select {{ choices_for AppicaUI::Skeleton, :effect }}
  def default(effect: :shimmer)
    phlex { Skeleton(effect:, class: "h-28 w-64 rounded-xl") }
  end

  # `:shimmer` glides a highlight, `:pulse` fades the block, `:none` stays still.
  def effects
    phlex do
      div(class: "flex flex-wrap items-start justify-center gap-10") do
        %i[ shimmer pulse none ].each do |effect|
          div(class: "flex flex-col items-center gap-3") do
            Skeleton(effect:, class: "h-24 w-40 rounded-xl")
            span(class: "text-foreground-muted text-xs") { effect.to_s }
          end
        end
      end
    end
  end

  # @label Composing shapes
  # No shape props - reshape it with utility classes.
  def shapes
    phlex do
      div(class: "flex flex-wrap items-center justify-center gap-6") do
        Skeleton(class: "size-16 rounded-full")
        Skeleton(class: "size-16 rounded-xl")
        Skeleton(class: "h-10 w-32 rounded-lg")
        Skeleton(class: "h-4 w-40 rounded-full")
      end
    end
  end

  # @label Text lines
  def text
    phlex do
      div(class: "flex w-full max-w-sm flex-col gap-2.5") do
        %w[ w-full w-full w-4/5 w-2/3 ].each { |width| Skeleton(class: "h-4 #{width}") }
      end
    end
  end

  # A skeleton shaped like the content it stands in for, so nothing shifts when it arrives.
  def card
    phlex do
      div(class: "border-border bg-background w-full max-w-sm rounded-xl border p-4", aria_busy: "true") do
        Skeleton(class: "aspect-video w-full rounded-lg")
        div(class: "mt-4 flex items-center gap-3") do
          Skeleton(class: "size-10 shrink-0 rounded-full")
          div(class: "flex flex-1 flex-col gap-2") do
            Skeleton(class: "h-3.5 w-2/3")
            Skeleton(class: "h-3 w-1/3")
          end
        end
      end
    end
  end

  # @label Recoloring
  # One text-* class tints the surface and the shimmer together.
  def colors
    phlex do
      div(class: "flex flex-wrap items-center justify-center gap-4") do
        [ nil, "text-primary", "text-secondary-emphasis", "text-error-emphasis", "text-success-emphasis", "text-warning-emphasis", "text-info-emphasis", "text-violet-500" ].each do |color|
          Skeleton(class: "#{color} size-16 rounded-xl")
        end
      end
    end
  end

  # @label Swapping in content
  # The avatar shows a Skeleton as its fallback until the photo loads; the name and role
  # replace their skeletons at the same moment. Reload to see it again.
  def swapping
    phlex do
      div(class: "flex w-full max-w-sm flex-col gap-4", data: { demo: "profile" }) do
        div(class: "flex justify-end") { Button(size: :sm, variant: :outline, data: { demo: "reload" }) { Icon(:reload, data: { icon: "start" }); plain "Reload" } }
        div(class: "border-border bg-background flex items-center gap-3 rounded-xl border p-4", aria_busy: "true", data: { demo: "card" }) do
          Avatar(size: :lg, class: "shrink-0 bg-transparent", data: { demo: "avatar" }) do
            AvatarImage(alt: "Sarah Jenkins", data: { demo: "image" })
            AvatarFallback { Skeleton(class: "size-full rounded-[inherit]") }
          end
          div(class: "flex flex-1 flex-col gap-1.5") do
            div(class: "flex flex-col gap-1.5", data: { demo: "loading" }) do
              Skeleton(class: "h-4 w-2/3")
              Skeleton(class: "h-3 w-2/5")
            end
            div(class: "flex flex-col gap-1.5", hidden: true, data: { demo: "loaded" }) do
              span(class: "text-foreground-intense -mb-0.5 text-sm font-semibold") { "Sarah Jenkins" }
              span(class: "text-foreground-muted text-xs") { "Product designer" }
            end
          end
        end
      end
      script(type: "module") do
        raw safe(<<~JS)
          const demo = document.querySelector("[data-demo=profile]")
          const card = demo.querySelector("[data-demo=card]")
          const image = demo.querySelector("[data-demo=image]")
          const reload = demo.querySelector("[data-demo=reload]")
          const photo = "data:image/svg+xml," + encodeURIComponent('<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 64 64"><rect width="64" height="64" fill="#c4b5fd"/><circle cx="32" cy="26" r="12" fill="#7c3aed"/><rect x="12" y="42" width="40" height="22" rx="11" fill="#7c3aed"/></svg>')
          const show = loaded => {
            demo.querySelector("[data-demo=loading]").hidden = loaded
            demo.querySelector("[data-demo=loaded]").hidden = !loaded
            card.setAttribute("aria-busy", String(!loaded))
            reload.disabled = !loaded
          }
          demo.addEventListener("appica-ui--avatar:loading-status-change", ({ detail: { status } }) => show(status === "loaded"))
          const load = () => {
            show(false)
            demo.querySelector("[data-demo=avatar]").dataset.status = "loading"
            image.removeAttribute("src")
            setTimeout(() => image.src = `${photo}#${Date.now()}`, 2500) // demo: a slow photo
          }
          reload.addEventListener("click", load)
          load()
        JS
      end
    end
  end

  # @label RTL
  # The shimmer runs with the reading direction.
  def rtl
    phlex do
      div(dir: "rtl", class: "flex w-full max-w-sm flex-col gap-2.5") do
        %w[ w-full w-4/5 w-2/3 ].each { |width| Skeleton(class: "h-4 #{width}") }
      end
    end
  end
end
