# A now-playing card: cover, title and artist with a favorite toggle, a seek bar with elapsed and
# remaining time, and shuffle / previous / play-pause / next / repeat - composed from Toggle,
# Button, Slider and Icon.
#
# @label Music player
# @logical_path Blocks
# @component AppicaUI::Blocks::MusicPlayer
# @display width wide
class AppicaUI::Blocks::MusicPlayerPreview < AppicaUI::BasePreview
  # @label Usage
  # The Appica homepage card. Without `src:` the demo advances the time while playing; drag the
  # seek bar to jump.
  # @param position number "Seconds played"
  # @param playing [Boolean] toggle
  # @param cover_alt text
  # @param favorite [Boolean] toggle
  # @param shuffle [Boolean] toggle
  # @param repeat [Boolean] toggle
  # @param src text
  # @param title text
  # @param artist text
  # @param album text
  # @param cover text
  # @param duration number
  def default(position: 84, playing: false, cover_alt: nil, favorite: false, shuffle: false, repeat: false, src: nil, title: "Midnight Drive", artist: "Neon Waves", album: "Retrograde", cover: "/landing/midnight-drive.svg", duration: 222)
    phlex do
      MusicPlayer(playing:, favorite:, shuffle:, repeat:, **given(cover_alt:, src:), title:, artist:, album:, cover:, duration:, position: position.to_i, class: "w-95 max-w-full")
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
