# A now-playing card: cover art, title and artist with a favorite toggle, a seek bar with
# elapsed and remaining time, and shuffle / previous / play-pause / next / repeat controls -
# composed from Toggle, Button, Slider and Icon.
#
#   MusicPlayer(title: track.title, artist: track.artist, album: track.album, cover: track.cover_url,
#     duration: track.duration, src: track.audio_url)
#
# With `src:` it plays the audio; without, the demo advances the time itself. The controller
# (`appica-ui--blocks--music-player`) emits `play`, `pause`, `previous`, `next` and `seek` (with
# { position }), and the favorite / shuffle / repeat toggles emit `appica-ui--toggle:change`.
# Strings: music_player.locales.yml.
class AppicaUI::Blocks::MusicPlayer < AppicaUI::Blocks::Base
  prop :title
  prop :artist,    default: -> { nil }
  prop :album,     default: -> { nil }
  prop :cover,     default: -> { nil }
  prop :cover_alt, default: -> { t(".cover") }
  prop :duration,  ->(value) { value.to_i }
  prop :position,  ->(value) { value.to_i }, default: -> { 0 }
  prop :playing,   default: -> { false }
  prop :favorite,  default: -> { false }
  prop :shuffle,   default: -> { false }
  prop :repeat,    default: -> { false }
  prop :src,       default: -> { nil }

  def view_template
    div(**mix(defaults(data: root_data), @attributes.except(:class)), class: cn(
      "bg-background border-border-muted flex flex-col justify-between gap-4 rounded-xl border p-6 shadow-lg dark:shadow-[0_8px_16px_-4px_rgba(0,0,0,0.8)]",
      override: @attributes[:class]
    )) do
      audio(src: @src, preload: "metadata", data: { "appica-ui--blocks--music-player-target": "audio" }) if @src
      track
      seek_bar
      controls
    end
  end

  private
    def root_data
      {
        slot: "music-player", controller: "appica-ui--blocks--music-player",
        action: "appica-ui--slider:change->appica-ui--blocks--music-player#seek",
        "appica-ui--blocks--music-player-duration-value": @duration, "appica-ui--blocks--music-player-position-value": @position.clamp(0, @duration),
        "appica-ui--blocks--music-player-playing-value": @playing.to_s,
        "appica-ui--blocks--music-player-play-label-value": t(".play"), "appica-ui--blocks--music-player-pause-label-value": t(".pause")
      }
    end

    def track
      div(class: "flex items-center gap-3") do
        if @cover
          img(src: @cover, alt: @cover_alt, width: 48, height: 48, loading: "lazy", class: "size-12 shrink-0 rounded-md object-cover")
        else
          Thumbnail(variant: :icon_soft, size: 48, class: "rounded-md") { Icon(:music) }
        end
        div(class: "min-w-0 flex-1") do
          div(class: "text-foreground-intense truncate text-sm font-medium", data: { slot: "music-player-title" }) { @title }
          div(class: "text-foreground-muted truncate text-xs") { [ @artist, @album ].compact.join(" - ") } if @artist || @album
        end
        toggle(:heart, t(".favorite"), pressed: @favorite, pressed_icon: :heart_filled)
      end
    end

    def seek_bar
      div do
        Slider(default_value: @position.clamp(0, @duration), max: [ @duration, 1 ].max, step: 1, tooltip: :never, thumb_aria_label: t(".seek"),
          data: { "appica-ui--blocks--music-player-target": "slider" })
        div(class: "text-foreground-muted mt-1.5 flex justify-between text-xs tabular-nums") do
          span(data: { "appica-ui--blocks--music-player-target": "elapsed" }) { clock(@position) }
          span do
            plain "-"
            span(data: { "appica-ui--blocks--music-player-target": "remaining" }) { clock(@duration - @position) }
          end
        end
      end
    end

    def controls
      div(class: "flex items-center justify-between") do
        toggle(:arrows_shuffle, t(".shuffle"), pressed: @shuffle, target: "shuffle")
        div(class: "flex items-center gap-1") do
          Button(variant: :ghost, icon: true, class: "rounded-full", aria_label: t(".previous"), data: { action: "appica-ui--blocks--music-player#previous" }) { Icon(:player_track_prev_filled) }
          Toggle(pressed: @playing, aria_label: (@playing ? t(".pause") : t(".play")),
            data: { "appica-ui--blocks--music-player-target": "play", action: "appica-ui--toggle:change->appica-ui--blocks--music-player#toggle" }) do |toggle|
            Button(**toggle, icon: true, class: "rounded-full") do
              Icon(:player_play_filled, class: "in-data-pressed:hidden")
              Icon(:player_pause_filled, class: "hidden in-data-pressed:block")
            end
          end
          Button(variant: :ghost, icon: true, class: "rounded-full", aria_label: t(".next"), data: { action: "appica-ui--blocks--music-player#next" }) { Icon(:player_track_next_filled) }
        end
        toggle(:repeat, t(".repeat"), pressed: @repeat, target: "repeat")
      end
    end

    # A ghost icon toggle; `pressed_icon:` swaps the icon while pressed, otherwise it tints
    def toggle(icon, label, pressed:, pressed_icon: nil, target: nil)
      Toggle(pressed:, aria_label: label, data: { "appica-ui--blocks--music-player-target": target }) do |attributes|
        Button(**attributes, variant: :ghost, size: :sm, icon: true, class: ("data-pressed:text-primary" unless pressed_icon)) do
          if pressed_icon
            Icon(icon, class: "in-data-pressed:hidden")
            Icon(pressed_icon, class: "text-error hidden in-data-pressed:block")
          else
            Icon(icon)
          end
        end
      end
    end

    # 84 → 1:24, 3_725 → 1:02:05
    def clock(seconds)
      seconds = seconds.to_i.clamp(0, nil)
      hours, rest = seconds.divmod(3600)
      minutes, secs = rest.divmod(60)
      hours.positive? ? "%d:%02d:%02d" % [ hours, minutes, secs ] : "%d:%02d" % [ minutes, secs ]
    end
end
