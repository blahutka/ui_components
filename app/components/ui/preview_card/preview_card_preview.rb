# A rich preview of a link, shown while it's hovered or focused.
#
# @label Preview Card
# @logical_path Overlays
# @component UI::PreviewCard
# @display width wide
# @display min_height 340px
class UI::PreviewCardPreview < UI::BasePreview
  # @label Profile preview
  # Hover (or tab to) the @mention; the link still navigates on click.
  def default
    phlex do
      p(class: "text-foreground-muted text-center") do
        plain "Built and maintained by the team at "
        PreviewCard do
          PreviewCardTrigger(href: "#!", class: "text-primary font-medium underline-offset-4 hover:underline") { "@appica_ui" }
          PreviewCardContent(class: "w-72") do
            div(class: "flex items-center justify-between") do
              Avatar { AvatarFallback { "AU" } }
              Button(size: :sm) { "Follow" }
            end
            div do
              p(class: "text-foreground-intense font-semibold") { "Appica UI" }
              p(class: "text-foreground-muted text-sm") { "@appica_ui" }
            end
            p(class: "text-sm") { "An accessible component library - here rendered with Phlex and Stimulus." }
            p(class: "text-foreground-muted text-sm") { span(class: "text-foreground-intense font-medium") { "2,481" }; plain " followers" }
          end
        end
        plain " on GitHub."
      end
    end
  end

  # @label Media preview
  # `class: "p-0 gap-0 overflow-hidden"` lets a cover image fill the card.
  def media
    phlex do
      p(class: "text-foreground-muted text-center") do
        plain "Our next offsite is at the "
        PreviewCard do
          PreviewCardTrigger(href: "#!", class: "text-primary font-medium underline-offset-4 hover:underline") { "Coastal House" }
          PreviewCardContent(arrow: false, class: "w-72 gap-0 overflow-hidden p-0") do
            div(class: "h-41 w-full bg-[linear-gradient(135deg,#7dd3fc,#c4b5fd_55%,#fda4af)]")
            div(class: "flex flex-col gap-1 p-4") do
              div(class: "flex items-center justify-between") do
                p(class: "text-foreground-intense font-semibold") { "Coastal House" }
                span(class: "text-foreground-muted flex items-center gap-1 text-sm") { Icon(:star_filled, class: "text-warning-emphasis size-4"); plain "4.9" }
              end
              p(class: "text-sm") { "A bright, open workspace overlooking the bay - room for 24." }
            end
          end
        end
        plain " next month."
      end
    end
  end

  # @label Side & alignment
  def placement
    phlex do
      div(class: "flex flex-wrap items-center justify-center gap-x-6 gap-y-3 py-24") do
        [ %i[ top start ], %i[ right center ], %i[ bottom end ], %i[ left center ] ].each do |side, align|
          PreviewCard do
            PreviewCardTrigger(href: "#!", class: "text-primary text-sm font-medium underline-offset-4 hover:underline") { "#{side} / #{align}" }
            PreviewCardContent(side:, align:) do
              p(class: "text-foreground-intense font-semibold") { "#{side} / #{align}" }
              p(class: "text-sm") { "The card flips and shifts to stay in view." }
            end
          end
        end
      end
    end
  end

  # @label RTL
  def rtl
    phlex do
      p(dir: "rtl", class: "text-foreground-muted text-center") do
        plain "اقرأ المزيد في "
        PreviewCard do
          PreviewCardTrigger(href: "#!", class: "text-primary font-medium underline-offset-4 hover:underline") { "دليل البدء" }
          PreviewCardContent(class: "w-64") do
            p(class: "text-foreground-intense font-semibold") { "البدء" }
            p(class: "text-sm") { "ثبّت الحزمة واستورد الأنماط وضع أول مكوّن لك." }
          end
        end
        plain "."
      end
    end
  end
end
