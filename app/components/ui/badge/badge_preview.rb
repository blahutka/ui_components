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
  ICON = { viewBox: "0 0 24 24", fill: "none", stroke: "currentColor", stroke_width: "2", stroke_linecap: "round", stroke_linejoin: "round", aria_hidden: "true" }.freeze

  ICONS = {
    check: "M5 12.5l4.5 4.5L19 7.5",
    flame: "M12 3c1 3.5 5 5.5 5 10a5 5 0 0 1-10 0c0-2 1-3.5 2-4.5 0 2 1 3 2 3 0-3 0-6 1-8.5z",
    bell: "M6 16v-5a6 6 0 1 1 12 0v5l1.5 2h-15zM10 20.5a2 2 0 0 0 4 0",
    bell_ringing: "M6 16v-5a6 6 0 1 1 12 0v5l1.5 2h-15zM10 20.5a2 2 0 0 0 4 0M3.5 9a8 8 0 0 1 2-4.5M20.5 9a8 8 0 0 0-2-4.5",
    star: "M12 3.5l2.6 5.3 5.9.9-4.25 4.1 1 5.8L12 16.9l-5.25 2.7 1-5.8L3.5 9.7l5.9-.9z",
    bolt: "M13 3 5 13.5h6L10 21l8-10.5h-6z",
    crown: "M4 8l4 4 4-6 4 6 4-4-1.5 10h-13z"
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
          svg(**ICON, data: { icon: "start" }) { |s| s.path(d: ICONS[:crown]) }
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
          svg(**ICON, data: { icon: "start" }) { |s| s.path(d: ICONS[:check]) }
          plain "Verified"
        end
        Badge(variant: :warning) do
          svg(**ICON, data: { icon: "start" }) { |s| s.path(d: ICONS[:flame]) }
          plain "Hot"
        end
        Badge(variant: :soft) do
          plain "Notification"
          svg(**ICON, data: { icon: "end" }) { |s| s.path(d: ICONS[:bell_ringing]) }
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
        Badge(variant: :success, size: :icon_sm, aria_label: "Verified") { svg(**ICON) { |s| s.path(d: ICONS[:check]) } }
        Badge(variant: :primary_outline, size: :icon_md, aria_label: "Featured") { svg(**ICON) { |s| s.path(d: ICONS[:star]) } }
        Badge(variant: :warning, size: :icon_lg, aria_label: "Boosted") { svg(**ICON) { |s| s.path(d: ICONS[:bolt]) } }
      end
    end
  end

  # @label Notification count
  # Position a small badge against an icon button for an unread count. Keep the number
  # in the badge and the full meaning in its `aria_label:`.
  def notification_count
    phlex do
      div(class: "relative inline-flex self-center") do
        Button(variant: :outline, icon: true, aria_label: "Notifications") { svg(**ICON) { |s| s.path(d: ICONS[:bell]) } }
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
          svg(**ICON, data: { icon: "start" }) { |s| s.path(d: ICONS[:check]) }
          plain "موثّق"
        end
        Badge(href: "#upgrade") { "ترقية" }
      end
    end
  end
end
