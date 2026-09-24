# A draggable, swipeable slider built on Embla, with autoplay, fade, auto-height,
# thumbnails and scroll effects.
#
# Carousel sets up the engine; CarouselContent is the viewport and track; each
# CarouselSlide is a snap point. CarouselPrev / CarouselNext, CarouselPagination,
# CarouselProgress and CarouselThumbs read the engine, so they can sit anywhere inside.
#
# @label Carousel
# @logical_path Data Display
# @component UI::Carousel
# @display width full
# @display min_height 26rem
class UI::CarouselPreview < UI::BasePreview
  PLACES = [
    { n: 1, title: "Sunlit summit", caption: "Aurora Range", body: "First light catches the ridgeline while the valley below stays in shadow - the clearest window for the summit push." },
    { n: 2, title: "Heather bloom", caption: "Meadowvale Heath", body: "The heath turns violet at golden hour, birches standing in a sea of flowering heather." },
    { n: 3, title: "Tulip garden", caption: "Keukenhof Lanes", body: "Rows of tulips run up to an old wooden fence, every colour of the spring palette in one bed." },
    { n: 4, title: "Alpenglow", caption: "Crimson Peaks", body: "The last sun paints the peaks pink and gold while the valleys fill with evening shadow." },
    { n: 5, title: "Rainbow ridges", caption: "Painted Hills", body: "Layers of red, orange and cream sandstone stripe the hills like a watercolour." }
  ].freeze

  CARDS = [
    { title: "Short", body: "A compact slide." },
    { title: "Medium", body: "This slide carries a couple of sentences, so it stands a little taller than the first. The viewport grows to fit it." },
    { title: "Tall", body: "And this one runs longer still. Auto height animates the viewport between each slide's natural height as you navigate, so nothing is clipped and there's no empty space below shorter slides. It keeps mixed-length content - quotes, cards, forms - looking tidy inside a single carousel." }
  ].freeze

  # @label Usage
  # A single slide per view with arrows inside the frame and pagination below.
  # `loop:` wraps around from the last slide back to the first.
  # @param loop [Boolean] toggle "Wrap around at the ends"
  # @param align [Symbol] select "Where slides settle" { choices: [start, center, end] }
  # @param fade [Boolean] toggle "Cross-fade instead of sliding"
  # @param autoplay [Boolean] toggle "Advance on a timer"
  def default(loop: true, align: :start, fade: false, autoplay: false)
    phlex do
      div(class: "mx-auto w-full max-w-xl pb-8") do
        Carousel(loop:, align:, fade:, autoplay:) do
          CarouselContent do
            (1..5).each do |n|
              CarouselSlide { img(src: "/carousel/slide-#{n}.jpg", alt: "Slide #{n}", class: "aspect-3/2 w-full rounded-xl object-cover") }
            end
          end
          CarouselPrev { |prev| Button(**prev, variant: :outline, icon: true, class: "rounded-full") { Icon(:chevron_left) } }
          CarouselNext { |nxt| Button(**nxt, variant: :outline, icon: true, class: "rounded-full") { Icon(:chevron_right) } }
          CarouselPagination(class: "absolute inset-x-0 top-full mt-5 justify-center")
        end
      end
    end
  end

  # @label Multiple slides (responsive)
  # A fractional basis-* fits several per view. `slides_to_scroll: :auto` advances by
  # however many are fully visible; arrows sit outside the frame.
  def multiple
    phlex do
      div(class: "mx-auto w-full max-w-xl px-15") do
        Carousel(align: :start, slides_to_scroll: :auto, loop: true) do
          CarouselContent do
            [ 4, 5, 6, 7, 8, 2 ].each do |n|
              CarouselSlide(class: "sm:basis-1/2 md:basis-1/3") { img(src: "/carousel/slide-#{n}.jpg", alt: "Slide #{n}", class: "aspect-square w-full rounded-xl object-cover") }
            end
          end
          CarouselPrev(position: :outside) { |prev| Button(**prev, variant: :outline, icon: true, class: "rounded-full") { Icon(:chevron_left) } }
          CarouselNext(position: :outside) { |nxt| Button(**nxt, variant: :outline, icon: true, class: "rounded-full") { Icon(:chevron_right) } }
        end
      end
    end
  end

  # `align:` controls where slides settle. With a basis smaller than the viewport,
  # :center peeks the neighbouring slides on either side.
  def alignment
    phlex do
      div(class: "mx-auto w-full max-w-xl") do
        Carousel(align: :center, loop: true) do
          CarouselContent do
            (1..6).each do |n|
              CarouselSlide(class: "basis-2/3") { img(src: "/carousel/slide-#{n}.jpg", alt: "Slide #{n}", class: "aspect-3/2 w-full rounded-xl object-cover") }
            end
          end
          CarouselPrev { |prev| Button(**prev, variant: :outline, icon: true, class: "rounded-full") { Icon(:chevron_left) } }
          CarouselNext { |nxt| Button(**nxt, variant: :outline, icon: true, class: "rounded-full") { Icon(:chevron_right) } }
        end
      end
    end
  end

  # `orientation: :vertical` drags and snaps along the Y axis. Give the track a fixed
  # height; the arrows settle at the top and bottom, and pagination runs down the side.
  def vertical
    phlex do
      Carousel(orientation: :vertical, loop: true, class: "mx-auto flex w-full max-w-2xl items-center justify-center gap-5") do
        div(class: "relative w-full max-w-xl") do
          CarouselContent(class: "h-100") do
            [ 1, 2, 4, 5 ].each do |n|
              CarouselSlide { img(src: "/carousel/slide-#{n}.jpg", alt: "Slide #{n}", class: "size-full rounded-xl object-cover") }
            end
          end
          CarouselPrev { |prev| Button(**prev, variant: :outline, icon: true, class: "rounded-full") { Icon(:chevron_up) } }
          CarouselNext { |nxt| Button(**nxt, variant: :outline, icon: true, class: "rounded-full") { Icon(:chevron_down) } }
        end
        CarouselPagination(orientation: :vertical)
      end
    end
  end

  # `autoplay:` advances on a timer. `resume_after:` restarts it a set time after the user
  # interacts; while it runs, the active bullet grows into a filling progress pill.
  def autoplay
    phlex do
      div(class: "mx-auto w-full max-w-xl pb-8") do
        Carousel(loop: true, autoplay: { delay: 4000, resume_after: 3000 }) do
          CarouselContent do
            [ 1, 5, 4, 7, 6 ].each do |n|
              CarouselSlide { img(src: "/carousel/slide-#{n}.jpg", alt: "Slide #{n}", class: "aspect-3/2 w-full rounded-xl object-cover") }
            end
          end
          CarouselPagination(class: "absolute inset-x-0 top-full mt-5 justify-center")
        end
      end
    end
  end

  # @label Auto scroll
  # `auto_scroll:` is continuous marquee-style motion; pair it with `loop:` and
  # `drag_free:` for an endless conveyor. Paused under reduced motion.
  def auto_scroll
    phlex do
      div(class: "mx-auto w-full max-w-xl") do
        Carousel(loop: true, drag_free: true, auto_scroll: { speed: 1.5, start_delay: 0, resume_after: 3000 }) do
          CarouselContent do
            (1..8).each do |n|
              CarouselSlide(class: "basis-1/2 sm:basis-1/3") { img(src: "/carousel/slide-#{n}.jpg", alt: "Slide #{n}", class: "aspect-square w-full rounded-xl object-cover") }
            end
          end
        end
      end
    end
  end

  # `fade:` cross-fades between slides instead of sliding - one slide per view.
  def fade
    phlex do
      div(class: "mx-auto w-full max-w-xl pb-8") do
        Carousel(loop: true, fade: true) do
          CarouselContent do
            (1..5).each do |n|
              CarouselSlide { img(src: "/carousel/slide-#{n}.jpg", alt: "Slide #{n}", class: "aspect-3/2 w-full rounded-xl object-cover") }
            end
          end
          CarouselPrev { |prev| Button(**prev, variant: :outline, icon: true, class: "rounded-full") { Icon(:chevron_left) } }
          CarouselNext { |nxt| Button(**nxt, variant: :outline, icon: true, class: "rounded-full") { Icon(:chevron_right) } }
          CarouselPagination(class: "absolute inset-x-0 top-full mt-5 justify-center")
        end
      end
    end
  end

  # @label Auto height
  # `auto_height:` animates the viewport to each slide's natural height; use
  # `align: :start` so slides measure from the top.
  def auto_height
    phlex do
      div(class: "mx-auto w-full max-w-md") do
        Carousel(loop: true, auto_height: true, align: :start) do
          CarouselContent do
            CARDS.each do |card|
              CarouselSlide do
                div(class: "border-border-muted bg-background-subtle rounded-xl border p-6") do
                  h4(class: "text-foreground-intense mb-2 font-semibold") { card[:title] }
                  p(class: "text-sm") { card[:body] }
                end
              end
            end
          end
          div(class: "mt-5 flex items-center justify-between gap-4") do
            CarouselPrev(position: :none) { |prev| Button(**prev, variant: :outline, icon: true) { Icon(:chevron_left) } }
            CarouselPagination()
            CarouselNext(position: :none) { |nxt| Button(**nxt, variant: :outline, icon: true) { Icon(:chevron_right) } }
          end
        end
      end
    end
  end

  # @label Free drag & wheel gestures
  # `drag_free:` glides to a momentum stop wherever the drag ends; `wheel_gestures:`
  # scrolls with a trackpad or mouse wheel.
  def drag_free
    phlex do
      div(class: "mx-auto w-full max-w-xl") do
        Carousel(drag_free: true, wheel_gestures: true, align: :start, contain_scroll: :trim_snaps) do
          CarouselContent do
            (1..8).each do |n|
              CarouselSlide(class: "basis-1/2 sm:basis-1/3 md:basis-1/4") { img(src: "/carousel/slide-#{n}.jpg", alt: "Slide #{n}", class: "aspect-square w-full rounded-xl object-cover") }
            end
          end
        end
      end
    end
  end

  # CarouselProgress is a scroll progress bar, or a ring with `variant: :circular`.
  # It tracks the drag position, and counts down the autoplay timer while autoplay plays.
  def progress
    phlex do
      div(class: "mx-auto w-full max-w-xl") do
        Carousel(align: :start) do
          CarouselContent do
            (1..6).each do |n|
              CarouselSlide(class: "basis-1/2 sm:basis-1/3") { img(src: "/carousel/slide-#{n}.jpg", alt: "Slide #{n}", class: "aspect-square w-full rounded-xl object-cover") }
            end
          end
          div(class: "mt-5 flex items-center justify-between") do
            div(class: "flex items-center gap-4") do
              CarouselProgress(class: "w-14")
              CarouselProgress(variant: :circular)
            end
            div(class: "flex gap-2") do
              CarouselPrev(position: :none) { |prev| Button(**prev, variant: :outline, icon: true) { Icon(:chevron_left) } }
              CarouselNext(position: :none) { |nxt| Button(**nxt, variant: :outline, icon: true) { Icon(:chevron_right) } }
            end
          end
        end
      end
    end
  end

  # CarouselThumbs is a rail of CarouselThumb buttons that drives the carousel it sits in.
  # The rail scrolls when it outgrows its width; selection is one outline that slides.
  def thumbnails
    phlex do
      Carousel(loop: true, class: "mx-auto flex w-full max-w-142 flex-col gap-3") do
        CarouselContent do
          (1..7).each do |n|
            CarouselSlide { img(src: "/carousel/slide-#{n}.jpg", alt: "Slide #{n}", class: "aspect-3/2 w-full rounded-xl object-cover") }
          end
        end
        CarouselThumbs do
          (1..7).each do |n|
            CarouselThumb(class: "w-16 sm:w-22") { img(src: "/carousel/slide-#{n}.jpg", alt: "", class: "size-full object-cover") }
          end
        end
      end
    end
  end

  # @label Thumbnails over imagery
  # `light: true` on the carousel switches every control to its light-on-dark palette.
  # Float the rail over the slides with a gradient scrim under it.
  def thumbnails_light
    phlex do
      Carousel(loop: true, light: true, class: "mx-auto w-full max-w-146 overflow-hidden rounded-xl") do
        CarouselContent do
          (1..7).each do |n|
            CarouselSlide do
              div(class: "relative aspect-3/2 w-full") do
                img(src: "/carousel/slide-#{n}.jpg", alt: "Slide #{n}", class: "size-full object-cover")
                div(class: "absolute inset-0 bg-linear-to-t from-black/70 via-black/10 to-transparent")
              end
            end
          end
        end
        CarouselThumbs(class: "absolute inset-x-0 bottom-3 px-3 sm:bottom-4 sm:px-4") do
          (1..7).each do |n|
            CarouselThumb(class: "w-14 sm:w-18") { img(src: "/carousel/slide-#{n}.jpg", alt: "", class: "size-full object-cover") }
          end
        end
      end
    end
  end

  # @label Synced carousels
  # `sync_with:` links two carousels (by id) both ways: the image carousel drives a fading
  # caption carousel, which is `draggable: false` so it only follows.
  def synced
    phlex do
      div(class: "mx-auto flex w-full max-w-xl flex-col gap-4 px-15") do
        Carousel(id: "synced-images", loop: true, sync_with: "synced-captions") do
          CarouselContent do
            PLACES.each do |place|
              CarouselSlide { img(src: "/carousel/slide-#{place[:n]}.jpg", alt: place[:title], class: "aspect-3/2 w-full rounded-xl object-cover") }
            end
          end
          CarouselPrev(position: :outside) { |prev| Button(**prev, variant: :outline, icon: true, class: "rounded-full") { Icon(:chevron_left) } }
          CarouselNext(position: :outside) { |nxt| Button(**nxt, variant: :outline, icon: true, class: "rounded-full") { Icon(:chevron_right) } }
        end
        Carousel(id: "synced-captions", loop: true, fade: true, draggable: false) do
          CarouselContent do
            PLACES.each do |place|
              CarouselSlide do
                div(class: "min-h-24 text-center") do
                  p(class: "text-foreground-intense text-lg font-semibold") { place[:title] }
                  p(class: "text-foreground mt-1 text-sm") { place[:body] }
                end
              end
            end
          end
        end
      end
    end
  end

  # `effect: :parallax` over-scales each slide's inner layer (`data: { carousel_layer: true }`)
  # and drifts it against the scroll.
  def parallax
    phlex do
      div(class: "mx-auto w-full max-w-xl") do
        Carousel(loop: true, align: :center, effect: :parallax) do
          CarouselContent do
            (1..6).each do |n|
              CarouselSlide(class: "basis-2/3") do
                div(class: "aspect-3/2 overflow-hidden rounded-xl") do
                  div(class: "size-full", data: { carousel_layer: true }) do
                    img(src: "/carousel/slide-#{n}.jpg", alt: "Slide #{n}", class: "size-full scale-[1.6] object-cover")
                  end
                end
              end
            end
          end
          div(class: "mt-5 flex justify-center gap-2") do
            CarouselPrev(position: :none) { |prev| Button(**prev, variant: :outline, icon: true) { Icon(:chevron_left) } }
            CarouselNext(position: :none) { |nxt| Button(**nxt, variant: :outline, icon: true) { Icon(:chevron_right) } }
          end
        end
      end
    end
  end

  # `effect: :scale` shrinks and dims each slide by its distance from the center,
  # so the focused slide pops.
  def scale
    phlex do
      div(class: "mx-auto w-full max-w-xl") do
        Carousel(loop: true, align: :center, effect: :scale) do
          CarouselContent do
            (1..6).each do |n|
              CarouselSlide(class: "basis-2/3") do
                div(data: { carousel_layer: true }) do
                  img(src: "/carousel/slide-#{n}.jpg", alt: "Slide #{n}", class: "aspect-3/2 w-full rounded-xl object-cover")
                end
              end
            end
          end
          div(class: "mt-5 flex justify-center gap-2") do
            CarouselPrev(position: :none) { |prev| Button(**prev, variant: :outline, icon: true) { Icon(:chevron_left) } }
            CarouselNext(position: :none) { |nxt| Button(**nxt, variant: :outline, icon: true) { Icon(:chevron_right) } }
          end
        end
      end
    end
  end

  # @label Overlaid controls
  # `light: true` when the controls sit over imagery, with a light Button for the arrows.
  def overlaid_controls
    phlex do
      div(class: "mx-auto w-full max-w-xl") do
        Carousel(loop: true, light: true, class: "overflow-hidden rounded-xl") do
          CarouselContent do
            PLACES.each do |place|
              CarouselSlide do
                div(class: "relative aspect-3/2 w-full") do
                  img(src: "/carousel/slide-#{place[:n]}.jpg", alt: place[:title], class: "size-full object-cover")
                  div(class: "absolute inset-0 bg-linear-to-t from-black/70 via-black/10 to-transparent")
                  div(class: "absolute inset-s-0 bottom-0 p-5") do
                    p(class: "text-lg font-semibold text-white") { place[:title] }
                    p(class: "text-sm text-white/70") { place[:caption] }
                  end
                end
              end
            end
          end
          CarouselPrev { |prev| Button(**prev, variant: :light, icon: true, class: "rounded-full") { Icon(:chevron_left) } }
          CarouselNext { |nxt| Button(**nxt, variant: :light, icon: true, class: "rounded-full") { Icon(:chevron_right) } }
          CarouselPagination(class: "absolute inset-x-0 bottom-5 justify-center")
        end
      end
    end
  end

  # @label Controlled
  # Arrows can live anywhere inside the carousel. Elements targeted as `current` / `count`
  # show the position, and the `ui--carousel:select` event carries { index, count, api }.
  def controlled
    phlex do
      div(class: "mx-auto w-full max-w-xl") do
        Carousel(loop: true) do
          CarouselContent do
            (1..5).each do |n|
              CarouselSlide { img(src: "/carousel/slide-#{n}.jpg", alt: "Slide #{n}", class: "aspect-3/2 w-full rounded-xl object-cover") }
            end
          end
          div(class: "mt-5 flex items-center justify-between") do
            CarouselPrev(position: :none) { |prev| Button(**prev, variant: :outline, icon: true) { Icon(:chevron_left) } }
            p(class: "text-sm tabular-nums") do
              plain "Slide "
              span(data: { "ui--carousel-target": "current" }) { "1" }
              plain " of "
              span(data: { "ui--carousel-target": "count" }) { "5" }
            end
            CarouselNext(position: :none) { |nxt| Button(**nxt, variant: :outline, icon: true) { Icon(:chevron_right) } }
          end
        end
      end
    end
  end

  # @label RTL
  # A horizontal carousel reverses its drag axis and starting edge; the arrows swap sides.
  def rtl
    phlex do
      div(dir: "rtl", class: "mx-auto w-full max-w-xl pb-8") do
        Carousel(loop: true, aria_label: "معرض الصور") do
          CarouselContent do
            (1..5).each do |n|
              CarouselSlide { img(src: "/carousel/slide-#{n}.jpg", alt: "الشريحة #{n}", class: "aspect-3/2 w-full rounded-xl object-cover") }
            end
          end
          CarouselPrev(aria_label: "الشريحة السابقة") { |prev| Button(**prev, variant: :outline, icon: true, class: "rounded-full") { Icon(:chevron_left, class: "rotate-180") } }
          CarouselNext(aria_label: "الشريحة التالية") { |nxt| Button(**nxt, variant: :outline, icon: true, class: "rounded-full") { Icon(:chevron_right, class: "rotate-180") } }
          CarouselPagination(class: "absolute inset-x-0 top-full mt-5 justify-center")
        end
      end
    end
  end
end
