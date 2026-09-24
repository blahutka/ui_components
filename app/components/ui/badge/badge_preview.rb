# A small label that highlights a status, count, or category.
#
# A compact, non-interactive <span> sized to its content. Pick a `variant:` for the color
# scheme and a `size:` for the scale; tag icons with `data: { icon: "start" | "end" }`.
# `href:` or `as: :button` makes it an interactive link or button.
#
# @label Badge
# @logical_path Data Display
# @component UI::Badge
# @display width wide
class UI::BadgePreview < UI::BasePreview
  ICONS = {
    check: :check,
    flame: :flame,
    bell: :bell,
    bell_ringing: :bell_ringing,
    star: :star,
    bolt: :bolt,
    crown: :crown
  }.freeze

  # @label Usage
  # @param variant [Symbol] select "Color scheme" { choices: [primary, primary_outline, secondary, soft, outline, error, success, warning, info, light] }
  # @param size [Symbol] select "Scale" { choices: [xs, sm, md, lg] }
  # @param label text "Badge text"
  def default(variant: :primary, size: :md, label: "Badge")
    phlex do
      Badge(variant:, size:) { label }
    end
  end

  # Each variant carries a semantic color. Solid primary/secondary and tinted
  # error/success/warning/info draw attention to a status; soft, outline and
  # primary_outline stay quieter for neutral metadata.
  def variants
    phlex do
      div(class: "flex flex-wrap items-center justify-center gap-2") do
        (UI::Badge::VARIANTS.keys - [ :light ]).each do |variant|
          Badge(variant:) { variant.to_s.humanize }
        end
      end
    end
  end

  # @label On dark backgrounds
  # The light variant is built for dark or photographic backgrounds: a translucent
  # white fill that reads against the surface beneath it.
  def on_dark
    phlex do
      div(class: "relative flex h-44 w-full max-w-66 items-end justify-start overflow-hidden rounded-xl bg-linear-to-br from-indigo-500 via-purple-500 to-pink-500") do
        div(class: "absolute inset-0 bg-linear-to-t from-black/25 via-transparent to-transparent")
        Badge(variant: :light, class: "relative m-3") do
          Icon(ICONS[:crown], stroke_width: 2, data: { icon: "start" })
          plain "Premium"
        end
      end
    end
  end

  # Four sizes from xs to lg; text and icons scale together.
  def sizes
    phlex do
      div(class: "flex flex-wrap items-center justify-center gap-2") do
        { xs: "Extra small", sm: "Small", md: "Medium", lg: "Large" }.each do |size, label|
          Badge(size:) { label }
        end
      end
    end
  end

  # @label With an icon
  # Tag the icon with `data: { icon: "start" }` or `"end"`; the badge tightens the
  # padding on that edge so the icon sits snug.
  def with_icon
    phlex do
      div(class: "flex flex-wrap items-center justify-center gap-2") do
        Badge(variant: :success) do
          Icon(ICONS[:check], stroke_width: 2, data: { icon: "start" })
          plain "Verified"
        end
        Badge(variant: :warning) do
          Icon(ICONS[:flame], stroke_width: 2, data: { icon: "start" })
          plain "Hot"
        end
        Badge(variant: :soft) do
          plain "Notification"
          Icon(ICONS[:bell_ringing], stroke_width: 2, data: { icon: "end" })
        end
      end
    end
  end

  # @label Icon only
  # `size: :icon_sm`, `:icon_md` and `:icon_lg` render a square badge for a lone icon.
  # Give it an `aria_label:` so the meaning is announced.
  def icon_only
    phlex do
      div(class: "flex flex-wrap items-center justify-center gap-2") do
        Badge(variant: :success, size: :icon_sm, aria_label: "Verified") { Icon(ICONS[:check], stroke_width: 2) }
        Badge(variant: :primary_outline, size: :icon_md, aria_label: "Featured") { Icon(ICONS[:star], stroke_width: 2) }
        Badge(variant: :warning, size: :icon_lg, aria_label: "Boosted") { Icon(ICONS[:bolt], stroke_width: 2) }
      end
    end
  end

  # @label Notification count
  # Position a small badge against an icon button for an unread count. Keep the number
  # in the badge and the full meaning in its `aria_label:`.
  def notification_count
    phlex do
      div(class: "relative inline-flex self-center") do
        Button(variant: :outline, icon: true, aria_label: "Notifications") { Icon(ICONS[:bell], stroke_width: 2) }
        Badge(variant: :secondary, size: :xs, class: "absolute -inset-e-1.5 -top-1.5 min-w-4 px-1 font-medium", aria_label: "3 unread notifications") { "3" }
      end
    end
  end

  # @label Interactive (link or button)
  # `href:` renders an <a>, `as: :button` a <button>. The badge becomes focusable and
  # animates on hover and press.
  def interactive
    phlex do
      div(class: "flex flex-wrap items-center justify-center gap-2") do
        Badge(variant: :soft, href: "#design") { "Design" }
        Badge(variant: :outline, href: "#trending") { "Trending" }
        Badge(variant: :primary_outline, as: :button) { "Follow" }
      end
    end
  end

  # @label RTL
  # The icon moves to the start (right) edge and the tightened padding follows, because
  # both use logical properties.
  def rtl
    phlex do
      div(dir: "rtl", class: "flex flex-wrap items-center justify-center gap-2") do
        Badge(variant: :success) do
          Icon(ICONS[:check], stroke_width: 2, data: { icon: "start" })
          plain "موثّق"
        end
        Badge(href: "#upgrade") { "ترقية" }
      end
    end
  end
end
