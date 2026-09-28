# A user image with a text or icon fallback when it's missing.
#
# Compose it from its parts: Avatar (size and shape), AvatarImage (the photo, swapped in
# once loaded), AvatarFallback (initials or an icon), AvatarBadge (status dot) and
# AvatarGroup (an overlapping row). Sized in em, so one `size:` scales everything.
#
# @label Avatar
# @logical_path Data Display
# @component AppicaUI::Avatar
# @display width wide
class AppicaUI::AvatarPreview < AppicaUI::BasePreview
  PEOPLE = [
    { src: "/avatars/01.png", alt: "Sarah Jenkins", initials: "SJ" },
    { src: "/avatars/02.png", alt: "Liam Hudson", initials: "LH" },
    { src: "/avatars/03.png", alt: "Mateo Rossi", initials: "MR" },
    { src: "/avatars/04.png", alt: "Ava Thompson", initials: "AT" }
  ].freeze


  # @label Usage
  # @param size [Symbol] select "Preset scale" { choices: [2xs, xs, sm, md, lg, xl, 2xl] }
  # @param shape [Symbol] select "Full circle or rounded square" { choices: [circle, rounded] }
  # @param image [Boolean] toggle "Show the photo (off shows the fallback initials)"
  # @param badge [Boolean] toggle "Status dot in the corner"
  def default(size: :lg, shape: :circle, image: true, badge: false)
    phlex do
      Avatar(size:, shape:) do
        AvatarImage(src: "/avatars/01.png", alt: "Sarah Jenkins") if image
        AvatarFallback { "SJ" }
        AvatarBadge() if badge
      end
    end
  end

  # When the image is missing, still loading, or fails to load, AvatarFallback renders
  # instead. Use initials for people, or an icon for a generic placeholder.
  def fallback
    phlex do
      div(class: "flex items-center gap-4") do
        Avatar(size: :lg) do
          AvatarImage(src: "/avatars/does-not-exist.png", alt: "Sarah Jenkins")
          AvatarFallback { "SJ" }
        end
        Avatar(size: :lg) { AvatarFallback { "MR" } }
        Avatar(size: :lg) do
          AvatarFallback do
            Icon(:user_filled)
          end
        end
      end
    end
  end

  # Seven presets from 2xs to 2xl. The fallback text and badge scale with the image.
  def sizes
    phlex do
      div(class: "flex flex-wrap items-center justify-center gap-4") do
        AppicaUI::Avatar::SIZES.each_key do |size|
          Avatar(size:) do
            AvatarImage(src: "/avatars/05.png", alt: "Daniel Reyes")
            AvatarFallback { "DR" }
          end
        end
      end
    end
  end

  # @label Custom size
  # Pass a number for an exact pixel size; it drives the root's font-size, so everything
  # inside still scales proportionally.
  def custom_size
    phlex do
      div(class: "flex items-center gap-4") do
        [ 28, 44, 72 ].each do |size|
          Avatar(size:) do
            AvatarImage(src: "/avatars/04.png", alt: "Ava Thompson")
            AvatarFallback { "AT" }
          end
        end
      end
    end
  end

  # `shape: :circle` (the default) or `shape: :rounded`, a squircle-style rounded square.
  def shape
    phlex do
      div(class: "flex items-center gap-4") do
        [ :circle, :rounded ].each do |shape|
          Avatar(size: :lg, shape:) do
            AvatarImage(src: "/avatars/03.png", alt: "Mateo Rossi")
            AvatarFallback { "MR" }
          end
        end
      end
    end
  end

  # @label Status badge
  # AvatarBadge adds a corner status dot. `animate: true` adds a pulsing ping;
  # recolor it with a text-* class.
  def status_badge
    phlex do
      div(class: "flex items-center gap-4") do
        Avatar(size: :lg) do
          AvatarImage(src: "/avatars/02.png", alt: "Liam Hudson")
          AvatarFallback { "LH" }
          AvatarBadge()
        end
        Avatar(size: :lg) do
          AvatarImage(src: "/avatars/08.png", alt: "Emma Garcia")
          AvatarFallback { "EG" }
          AvatarBadge(animate: true)
        end
        Avatar(size: :lg) do
          AvatarImage(src: "/avatars/06.png", alt: "Lucas Müller")
          AvatarFallback { "LM" }
          AvatarBadge(class: "text-foreground-subtle")
        end
      end
    end
  end

  # @label Avatar group
  # AvatarGroup overlaps a row of avatars and rings each one with the background color.
  # It forwards a shared size/shape; a +N counter sits in the same rhythm.
  # @param orientation [Symbol] select { choices: [horizontal, vertical] }
  def group(orientation: :horizontal)
    phlex do
      AvatarGroup(size: :md, orientation:, aria_label: "Project members") do
        PEOPLE.each do |person|
          Avatar do
            AvatarImage(src: person[:src], alt: person[:alt])
            AvatarFallback { person[:initials] }
          end
        end
        Avatar { AvatarFallback(class: "text-foreground-muted text-sm") { "+5" } }
      end
    end
  end

  # @label Loading animation
  # AvatarFallback shows until the image has loaded, so a pulsing placeholder inside it
  # is swapped for the photo automatically. This image is served with a 2.5s delay;
  # use Lookbook's refresh button to watch it again.
  def loading
    phlex do
      Avatar(size: :xl, class: "bg-transparent") do
        AvatarImage(src: "/demo/images/8?delay=2.5&t=#{Time.now.to_f}", alt: "Emma Garcia")
        AvatarFallback do
          span(class: "bg-background-strong size-full animate-pulse rounded-[inherit]")
        end
      end
    end
  end

  # @label RTL
  # The badge moves to the start corner and the group stacks from the right, because
  # both use logical properties.
  def rtl
    phlex do
      div(dir: "rtl", class: "flex items-center gap-6") do
        Avatar(size: :lg) do
          AvatarFallback { "NP" }
          AvatarBadge()
        end
        AvatarGroup(size: :md) do
          PEOPLE.first(3).each do |person|
            Avatar do
              AvatarImage(src: person[:src], alt: person[:alt])
              AvatarFallback { person[:initials] }
            end
          end
        end
      end
    end
  end
end
