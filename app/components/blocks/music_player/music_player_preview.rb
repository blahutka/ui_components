# A now-playing card: cover, title and artist with a favorite toggle, a seek bar with elapsed and
# remaining time, and shuffle / previous / play-pause / next / repeat - composed from Toggle,
# Button, Slider and Icon.
#
# @label Music player
# @logical_path Blocks
# @component Blocks::MusicPlayer
# @display width wide
class Blocks::MusicPlayerPreview < UI::BasePreview
  # @label Usage
  # The Appica homepage card. Without `src:` the demo advances the time while playing; drag the
  # seek bar to jump.
  # @param position number "Seconds played"
  # @param playing [Boolean] toggle
  def default(position: 84, playing: false)
    phlex do
      MusicPlayer(title: "Midnight Drive", artist: "Neon Waves", album: "Retrograde", cover: "/landing/midnight-drive.svg",
        duration: 222, position: position.to_i, playing:, class: "w-95 max-w-full")
    end
  end

  # @label Without cover art
  # A music tile stands in for a missing cover; long titles truncate.
  def no_cover
    phlex do
      MusicPlayer(title: "An Extremely Long Track Title That Keeps Going", artist: "Various Artists", duration: 3_725, position: 1_800,
        favorite: true, repeat: true, class: "w-95 max-w-full")
    end
  end

  # @label RTL
  # Rendered in Arabic whatever the toolbar says.
  def rtl
    phlex do
      I18n.with_locale(:ar) do
        div(dir: "rtl") do
          MusicPlayer(title: "قيادة منتصف الليل", artist: "نيون ويفز", cover: "/landing/midnight-drive.svg", duration: 222, position: 84, class: "w-95 max-w-full")
        end
      end
    end
  end
end
