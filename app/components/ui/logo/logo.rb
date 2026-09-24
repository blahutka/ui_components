# A brand logo: a circular mark (drawn with Phlex's SVG builder) plus a wordmark.
#
#   Logo()                                                    # Behumble.com
#   Logo(prefix: "Be", name: "humble", suffix: ".com", size: :lg)
#   Logo(variant: :mark, href: root_path)                     # just the circle
#
# The wordmark is real text (page font, selectable, any length) in three parts: a bold
# prefix, a light name and an accent-coloured suffix. Sized in em, so `size:` (or any
# text-* class) scales the mark and the text together.
class UI::Logo < UI::Base
  SIZES = {
    sm: "text-lg",
    md: "text-2xl",
    lg: "text-4xl",
    xl: "text-6xl"
  }.freeze

  # The mark's disc and the suffix share one accent colour
  ACCENTS = {
    blue: "[--logo-accent:#4a8fd6]",
    green: "[--logo-accent:#22a06b]",
    violet: "[--logo-accent:#7c5cff]",
    orange: "[--logo-accent:#f97316]"
  }.freeze

  VARIANTS = %i[ full mark wordmark ].freeze

  def initialize(prefix: "Be", name: "humble", suffix: ".com", size: :md, accent: :blue, variant: :full, href: nil, **attributes)
    @prefix, @name, @suffix = prefix.to_s, name.to_s, suffix.to_s
    @size = SIZES.key?(size.to_sym) ? size.to_sym : :md
    @accent = ACCENTS.key?(accent.to_sym) ? accent.to_sym : :blue
    @variant = VARIANTS.include?(variant.to_sym) ? variant.to_sym : :full
    @href = href
    @attributes = attributes
  end

  def view_template
    attributes = mix(root_attributes, @attributes.except(:class))
    classes = cn("inline-flex items-center gap-[0.35em] leading-none", SIZES[@size], ACCENTS[@accent], override: @attributes[:class])

    if @href
      a(href: @href, **attributes, class: cn(classes, "outline-ring rounded-sm outline-offset-4")) { logo }
    else
      span(**attributes, class: classes) { logo }
    end
  end

  private
    def root_attributes
      # With the text hidden, the mark is the only content, so name it
      label = (@variant == :mark ? full_name : nil)
      { role: (label && !@href ? "img" : nil), aria: { label: }, data: { slot: "logo", variant: @variant } }
    end

    def full_name = [ @prefix, @name, @suffix ].join

    def logo
      mark unless @variant == :wordmark
      wordmark unless @variant == :mark
    end

    # 64×64: dark ring, accent disc, white hill with a sprout (two leaves on a stem)
    def mark
      clip_id = "logo-disc-#{SecureRandom.hex(4)}"

      svg(xmlns: "http://www.w3.org/2000/svg", viewBox: "0 0 64 64", aria_hidden: "true", focusable: "false",
          class: "size-[1.6em] shrink-0", data: { slot: "logo-mark" }) do |s|
        s.defs do
          s.clipPath(id: clip_id) { s.circle(cx: "32", cy: "32", r: "25") }
        end

        s.circle(cx: "32", cy: "32", r: "29.5", stroke_width: "3", class: "fill-background stroke-foreground-intense")
        s.circle(cx: "32", cy: "32", r: "25", class: "fill-(--logo-accent)")

        s.g(clip_path: "url(##{clip_id})", fill: "#fff") do
          # the hill the sprout grows from
          s.path(d: "M4 50 C16 41 48 41 60 50 V64 H4 Z")
          # stem
          s.path(d: "M32 45 V29", stroke: "#fff", stroke_width: "2.75", stroke_linecap: "round", fill: "none")
          # left leaf, smaller and lower
          s.path(d: "M31.5 35.5 C24 36 18.5 31.5 18 24.5 C25.5 24 31 28.5 31.5 35.5 Z")
          # right leaf, larger and higher
          s.path(d: "M32.5 30.5 C32.5 21.5 38.5 15 47 14.5 C47.5 23.5 41.5 30 32.5 30.5 Z")
        end
      end
    end

    def wordmark
      span(class: "text-foreground-emphasis tracking-tight whitespace-nowrap", data: { slot: "logo-wordmark" }) do
        span(class: "text-foreground-intense font-bold") { @prefix } if @prefix.present?
        span(class: "font-light") { @name } if @name.present?
        span(class: "font-normal text-(--logo-accent)") { @suffix } if @suffix.present?
      end
    end
end
