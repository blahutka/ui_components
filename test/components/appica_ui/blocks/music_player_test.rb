require "test_helper"

class AppicaUI::Blocks::MusicPlayerTest < ComponentTestCase
  test "renders the track, seek bar, times and controls" do
    html = render_ui do
      MusicPlayer(title: "Midnight Drive", artist: "Neon Waves", album: "Retrograde", cover: "/cover.svg", duration: 222, position: 84)
    end

    player = html.at_css("[data-slot=music-player]")
    assert_equal [ "appica-ui--blocks--music-player", "222", "84", "false" ],
      %w[data-controller data-appica-ui--blocks--music-player-duration-value data-appica-ui--blocks--music-player-position-value data-appica-ui--blocks--music-player-playing-value].map { |name| player[name] }
    assert_equal [ "/cover.svg", "Album cover" ], %w[src alt].map { |name| player.at_css("img")[name] }
    assert_equal "Midnight Drive", player.at_css("[data-slot=music-player-title]").text
    assert_includes player.text, "Neon Waves - Retrograde"

    range = player.at_css("[data-slot=slider] input[type=range]")
    assert_equal [ "84", "222", "Seek" ], %w[value max aria-label].map { |name| range[name] }
    assert_equal "1:24", player.at_css("[data-appica-ui--blocks--music-player-target=elapsed]").text
    assert_equal "2:18", player.at_css("[data-appica-ui--blocks--music-player-target=remaining]").text

    labels = player.css("button[aria-label]").map { |button| button["aria-label"] }
    assert_equal [ "Favorite this track", "Shuffle", "Previous track", "Play", "Next track", "Repeat" ], labels
    assert_equal "false", player.at_css("[data-appica-ui--blocks--music-player-target=play]")["aria-pressed"]
  end

  test "playing, long tracks and a missing cover" do
    html = render_ui { MusicPlayer(title: "Mix", duration: 3_725, position: 1_800, playing: true, favorite: true) }

    assert_equal "Pause", html.at_css("[data-appica-ui--blocks--music-player-target=play]")["aria-label"]
    assert_equal "true", html.at_css("[data-appica-ui--blocks--music-player-target=play]")["aria-pressed"]
    assert_equal "30:00", html.at_css("[data-appica-ui--blocks--music-player-target=elapsed]").text
    assert_equal "32:05", html.at_css("[data-appica-ui--blocks--music-player-target=remaining]").text
    assert html.at_css("[data-slot=thumbnail] svg"), "a music tile instead of cover art"
    assert_equal "true", html.at_css("button[aria-label='Favorite this track']")["aria-pressed"]
    assert_nil html.at_css("audio")
  end

  test "with a source it plays audio" do
    html = render_ui { MusicPlayer(title: "Mix", duration: 60, src: "/track.mp3") }
    assert_equal "/track.mp3", html.at_css("audio[data-appica-ui--blocks--music-player-target=audio]")["src"]
  end
end
