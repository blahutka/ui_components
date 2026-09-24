# A flexible content container for a title, description, media, and actions.
#
# Card is a layout container, not a widget: no state, no JavaScript. Compose it from
# CardMedia, CardHeader, CardTitle, CardDescription and CardFooter - every part is optional.
# One radius (`--card-radius`) drives the frame and the inset media.
#
# @label Card
# @logical_path Data Display
# @component UI::Card
# @display width full
class UI::CardPreview < UI::BasePreview
  ICON = { viewBox: "0 0 24 24", fill: "none", stroke: "currentColor", stroke_width: "1.5", stroke_linecap: "round", stroke_linejoin: "round", aria_hidden: "true" }.freeze

  ICONS = {
    bookmark: "M6 4h12v16l-6-4-6 4z",
    folder_plus: "M3 7a2 2 0 0 1 2-2h4l2 2h8a2 2 0 0 1 2 2v8a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2zm9 3v6m-3-3h6",
    plus: "M12 5v14M5 12h14",
    heart: "M12 20s-7-4.4-7-10a4 4 0 0 1 7-2.6A4 4 0 0 1 19 10c0 5.6-7 10-7 10",
    cart: "M3 4h2l2.4 11h10.2L20 8H6.2M10 20a1 1 0 1 0 0-2 1 1 0 0 0 0 2m7 0a1 1 0 1 0 0-2 1 1 0 0 0 0 2"
  }.freeze

  INPUT = "border-transparent bg-background-muted text-foreground h-10 w-full rounded-md border px-3.5 text-sm outline-none focus:bg-background focus:border-transparent focus:ring-3 focus:ring-ring-input"

  # @label Usage
  # @param frame [Symbol] select "Padded frame around the content" { choices: [none, solid, glass] }
  # @param inset [Boolean] toggle "Float the slots inside the content (media rounds all four corners)"
  # @param media [Boolean] toggle "Show a CardMedia above the header"
  def default(frame: :none, inset: true, media: true)
    phlex do
      Card(frame: (frame.to_sym == :none ? false : frame), inset:, class: "mx-auto w-80 max-w-full") do
        CardMedia(class: "h-40") { img(src: "/carousel/slide-6.jpg", alt: "A valley at golden hour") } if media
        CardHeader do
          CardTitle { "Golden hour in the valley" }
          CardDescription { "Three nights in a timber cabin at the treeline, with meadow trails and the peaks at your door." }
        end
        CardFooter do
          Button { "Book now" }
          Button(variant: :outline) { "Details" }
        end
      end
    end
  end

  # @label Header and footer
  # The most basic setup - no options, just a header and a footer.
  def header_and_footer
    phlex do
      Card(class: "mx-auto w-full max-w-90") do
        CardHeader do
          div(class: "text-foreground-muted mb-1 flex items-center gap-2 text-xs") do
            Logo(variant: :mark, size: :sm, class: "text-base")
            span { "Behumble" }
          end
          CardTitle { "Weekly digest" }
          CardDescription { "A short round-up of what changed, who shipped it, and what still needs a second pair of eyes." }
        end
        CardFooter { Button { "Read digest" } }
      end
    end
  end

  # `frame: :solid` wraps the content in a band of background-subtle and softens the inner
  # hairline. Leave it off unless the card needs that extra separation from the page.
  def frame
    phlex do
      div(class: "mx-auto grid w-full max-w-3xl gap-4 sm:grid-cols-2") do
        Card do
          CardHeader do
            CardTitle { "No frame" }
            CardDescription { "The card sits directly on the page, outlined by a single hairline border." }
          end
          CardFooter { Button(variant: :soft) { "Learn more" } }
        end
        Card(frame: :solid) do
          CardHeader do
            CardTitle { "Solid frame" }
            CardDescription do
              plain "An 8px band of "
              code { "background-subtle" }
              plain " wraps the content and lifts the card off the page."
            end
          end
          CardFooter { Button(variant: :outline) { "Learn more" } }
        end
      end
    end
  end

  # @label Glass frame
  # `frame: :glass` is a translucent, blurred band without the inner border. Put it over a
  # photo, a gradient or a colored section - never on flat page background.
  def glass
    phlex do
      div(class: "mx-auto w-full max-w-3xl rounded-2xl bg-[image:linear-gradient(rgb(0_0_0/0.2),rgb(0_0_0/0.2)),url('/carousel/slide-2.jpg')] bg-cover bg-center p-8") do
        Card(frame: :glass, class: "mx-auto w-full max-w-90") do
          CardHeader do
            div(class: "flex items-start justify-between gap-3") do
              CardTitle { "A room above the clouds" }
              Logo(variant: :mark, size: :md, class: "shrink-0")
            end
            CardDescription { "The glass frame borrows the pixels behind it, so it only reads as glass over imagery or a colored surface." }
          end
          CardFooter { Button { "Check availability" } }
        end
      end
    end
  end

  # CardMedia clips whatever you put in it. Inset (default): media floats inside the content
  # with four rounded corners. `inset: false`: media runs edge to edge and the card clips it.
  def media
    phlex do
      div(class: "mx-auto grid w-full max-w-3xl gap-4 sm:grid-cols-2") do
        [ true, false ].each do |inset|
          Card(inset:) do
            CardMedia(class: "h-44") { img(src: "/carousel/slide-1.jpg", alt: "Mountains at sunrise") }
            CardHeader do
              CardTitle { inset ? "Inset" : "Flush" }
              CardDescription do
                inset ? "The image floats 8px inside the content wrapper and keeps all four corners rounded." :
                        "The image runs edge to edge and the card clips it to its own top corners."
              end
            end
          end
        end
      end
    end
  end

  # @label Horizontal layout
  # The content wrapper is a flex column, so one class through `content:` turns the card
  # sideways. `as: :article` exposes it as self-contained content; only the title is a link.
  def horizontal
    phlex do
      Card(as: :article, content: { class: "md:flex-row md:gap-2" }, class: "mx-auto w-full max-w-160") do
        CardMedia(class: "h-48 shrink-0 md:h-auto md:w-56") { img(src: "/carousel/slide-7.jpg", alt: "A lone peak above a still lake") }
        div(class: "flex min-w-0 flex-1 flex-col") do
          CardHeader do
            Badge(variant: :secondary, size: :sm, class: "mb-1 self-start") { "Field notes" }
            CardTitle do
              a(href: "#", class: "outline-ring rounded-xs hover:underline") { "What eight seasons above the treeline taught us about packing light" }
            end
            CardDescription { "Every gram you carry is a decision you already made. Here is the kit that survived - and the gear that never left the tent twice." }
          end
          CardFooter(class: "flex-row items-center justify-between") do
            div(class: "flex min-w-0 items-center gap-2") do
              Avatar(size: :xs) do
                AvatarImage(src: "/avatars/01.png", alt: "Sarah Jenkins")
                AvatarFallback { "SJ" }
              end
              span(class: "text-foreground-muted truncate text-xs") { "Sarah Jenkins · 12 March 2026" }
            end
            Button(variant: :ghost, size: :sm, icon: true, aria_label: "Save for later") { svg(**ICON) { |s| s.path(d: ICONS[:bookmark]) } }
          end
        end
      end
    end
  end

  # For a card that is an image, position CardMedia absolutely (inset-2 when inset, inset-0
  # when flush) and let CardHeader stack above it, with a scrim for legible text.
  def overlay
    phlex do
      div(class: "mx-auto grid w-full max-w-3xl gap-4 sm:grid-cols-2") do
        [ true, false ].each do |inset|
          Card(inset:, class: "h-72", content: { class: "relative" }) do
            CardMedia(class: inset ? "absolute inset-2" : "absolute inset-0") do
              img(src: "/carousel/slide-4.jpg", alt: "Mountains at dusk")
              div(class: "absolute inset-0 bg-linear-to-t from-black/80 via-black/25 to-transparent")
            end
            CardHeader(class: "relative justify-between") do
              Badge(variant: :light, class: "self-start") { inset ? "inset" : "inset: false" }
              div(class: "flex flex-col gap-1.5") do
                CardTitle(class: "text-white") { "Alpenglow" }
                CardDescription(class: "text-white/75") { "The header stacks above an absolutely-positioned media layer, so the whole card becomes the image." }
              end
            end
          end
        end
      end
    end
  end

  # CardHeader is a plain flex column - here an Avatar leads a centered profile card.
  def profile
    phlex do
      Card(frame: :solid, class: "mx-auto w-full max-w-80") do
        CardHeader(class: "items-center text-center") do
          Avatar(size: :xl, class: "mb-2") do
            AvatarImage(src: "/avatars/03.png", alt: "")
            AvatarFallback { "MR" }
            AvatarBadge()
          end
          CardTitle { "Mateo Rossi" }
          CardDescription { "Principal designer · Bologna" }
        end
        CardFooter(class: "sm:justify-center") do
          Button(size: :sm) { "Follow" }
          Button(variant: :outline, size: :sm) { "Message" }
        end
      end
    end
  end

  # @label Empty state
  # `content:` restyles the surface itself - a dashed border and a subtle fill turn a card
  # into a placeholder.
  def empty_state
    phlex do
      Card(class: "mx-auto w-full max-w-110", content: { class: "bg-background-subtle items-center border-dashed border-border-strong text-center" }) do
        CardHeader(class: "items-center") do
          span(class: "border-border text-foreground-muted bg-background mb-2 flex size-12 items-center justify-center rounded-xl border [&_svg]:size-5") do
            svg(**ICON) { |s| s.path(d: ICONS[:folder_plus]) }
          end
          CardTitle { "No collections yet" }
          CardDescription(class: "max-w-70") { "Collections group related boards so your team can find them without digging through search." }
        end
        CardFooter do
          Button(size: :sm) do
            svg(**ICON, data: { icon: "start" }) { |s| s.path(d: ICONS[:plus]) }
            plain "New collection"
          end
        end
      end
    end
  end

  # @label Product card
  # Anything can live in CardHeader - a price row and size buttons here. The badge and
  # wishlist button are positioned inside CardMedia, which is already relative.
  def product
    phlex do
      Card(class: "mx-auto w-full max-w-85") do
        CardMedia(class: "h-44") do
          img(src: "/carousel/slide-3.jpg", alt: "Tulip bouquet")
          Badge(variant: :light, size: :sm, class: "absolute inset-s-2 top-2") { "-20%" }
          Button(variant: :light, size: :sm, icon: true, aria_label: "Add to wishlist", class: "absolute inset-e-2 top-2") { svg(**ICON) { |s| s.path(d: ICONS[:heart]) } }
        end
        CardHeader do
          div(class: "flex items-start justify-between gap-3") do
            div do
              CardTitle(class: "text-base") { "Spring bouquet" }
              CardDescription(class: "text-xs") { "Seasonal tulips, hand-tied" }
            end
            div(class: "text-end") do
              div(class: "text-foreground-intense font-semibold tabular-nums") { "$36" }
              s(class: "text-foreground-muted text-xs tabular-nums") { "$45" }
            end
          end
          div(class: "mt-3 flex items-center gap-2", role: "group", aria_label: "Bouquet size") do
            [ "S", "M", "L", "XL" ].each do |size|
              Button(variant: (size == "M" ? :primary : :outline), size: :sm, icon: true, aria_pressed: (size == "M").to_s, class: "text-xs") { size }
            end
          end
        end
        CardFooter do
          Button(size: :sm, class: "w-full") do
            svg(**ICON, data: { icon: "start" }) { |s| s.path(d: ICONS[:cart]) }
            plain "Add to cart"
          end
        end
      end
    end
  end

  # @label Form in a card
  # `as: :form` makes the card itself the form element, so fields and the submit button
  # need no extra wrapper. The Logo mark leads the header.
  def form
    phlex do
      Card(frame: :solid, as: :form, action: "#", class: "mx-auto w-full max-w-90") do
        CardHeader do
          Logo(variant: :mark, size: :md)
          CardTitle(class: "mt-1 text-xl") { "Sign in to Behumble" }
          CardDescription { "Sign in to view order status, update billing, check past orders." }
          div(class: "mt-4 flex flex-col gap-4") do
            label(class: "flex flex-col gap-2 text-sm") do
              span(class: "text-foreground-intense font-medium") { "Email" }
              input(type: "email", name: "email", autocomplete: "off", class: INPUT)
            end
            label(class: "flex flex-col gap-2 text-sm") do
              span(class: "flex items-center justify-between gap-3") do
                span(class: "text-foreground-intense font-medium") { "Password" }
                a(href: "#!", class: "outline-ring text-foreground-intense rounded-xs text-sm underline") { "Forgot password?" }
              end
              input(type: "password", name: "password", autocomplete: "new-password", class: INPUT)
            end
            label(class: "flex items-center gap-2 text-sm select-none") do
              input(type: "checkbox", name: "persist", checked: true, class: "accent-primary size-4")
              plain "Stay signed in"
            end
          end
        end
        CardFooter { Button(type: "submit", class: "w-full") { "Sign in" } }
      end
    end
  end

  # Changing `--card-radius` retunes the card and its inset media together.
  def radius
    phlex do
      div(class: "mx-auto grid w-full max-w-3xl gap-4 sm:grid-cols-2 md:grid-cols-3") do
        { "radius-sm" => "[--card-radius:var(--radius-sm)]", "radius-xl (default)" => nil, "radius-3xl" => "[--card-radius:var(--radius-3xl)]" }.each do |label, radius|
          Card(class: radius) do
            CardMedia(class: "h-24") { img(src: "/carousel/slide-5.jpg", alt: "") }
            CardHeader { CardTitle(class: "text-base") { label } }
          end
        end
      end
    end
  end

  # @label RTL
  # Logical padding and flex ordering: the footer's actions flow from the right and text
  # aligns to the start edge with no direction-specific classes.
  def rtl
    phlex do
      div(dir: "rtl") do
        Card(class: "mx-auto w-80 max-w-full") do
          CardMedia(class: "h-40") { img(src: "/carousel/slide-6.jpg", alt: "") }
          CardHeader do
            CardTitle { "ساعة ذهبية في الوادي" }
            CardDescription { "ثلاث ليالٍ في كوخ خشبي عند حد الأشجار، مع مسارات المروج والقمم على بابك." }
          end
          CardFooter do
            Button { "احجز الآن" }
            Button(variant: :outline) { "التفاصيل" }
          end
        end
      end
    end
  end
end
