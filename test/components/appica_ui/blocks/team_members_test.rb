require "test_helper"

class AppicaUI::Blocks::TeamMembersTest < ComponentTestCase
  def team(**options)
    render_ui do
      TeamMembers(seats: 5, used: 2, list_id: "team", **options) do
        TeamMemberList do
          TeamMember(name: "Sarah Jenkins", email: "sarah@appica.dev", avatar: "/avatars/01.png", role: :owner, online: true)
          TeamMember(name: "Lucas Müller", email: "lucas@appica.dev", role: :viewer, online: false)
        end
        TeamInvite()
      end
    end
  end

  test "renders the header, seat count, members and invite form" do
    html = team(action: "/invitations")
    root = html.at_css("[data-slot=team-members]")

    assert_equal "appica-ui--blocks--team-members", root["data-controller"]
    assert_equal "false", root["data-appica-ui--blocks--team-members-demo-value"]
    assert_equal "%{used} of %{seats} seats used", root["data-appica-ui--blocks--team-members-seats-label-value"]
    assert_equal "Team members", html.at_css("h3").text
    assert_equal "2 of 5 seats used", html.at_css("[data-appica-ui--blocks--team-members-target=seats]").text
    assert_equal "team", html.at_css("[data-slot=team-member-list]")["id"]
    assert_equal 2, html.css("[data-slot=team-member-list] [data-slot=team-member]").size

    form = html.at_css("form[data-slot=team-invite]")
    assert_equal "/invitations", form["action"]
    assert_equal "email", form.at_css("input")["type"]
    assert_equal "email", form.at_css("input")["name"]
    assert_equal "Send invite", form.at_css("button[type=submit]")["aria-label"]
  end

  test "members show avatar or initials, presence and a role badge" do
    sarah, lucas = team.css("[data-slot=team-member-list] [data-slot=team-member]")

    assert_equal "/avatars/01.png", sarah.at_css("img")["src"]
    assert_equal "Online", sarah.at_css("[data-slot=avatar-badge]")["aria-label"]
    assert_equal "primary-outline", sarah.at_css("[data-slot=badge]")["data-variant"]
    assert_equal "Owner", sarah.at_css("[data-slot=badge]").text
    assert_equal "LM", lucas.at_css("[data-slot=avatar-fallback]").text
    assert_includes lucas.at_css("[data-slot=avatar-badge]")["class"], "text-foreground-subtle"
    assert_equal "soft", lucas.at_css("[data-slot=badge]")["data-variant"]
  end

  test "a full team disables inviting" do
    html = render_ui { TeamMembers(seats: 2, used: 2) { TeamInvite() } }

    assert html.at_css("input[type=email]").key?("disabled")
    assert_equal "All seats are taken", html.at_css("input[type=email]")["placeholder"]
    assert html.css("button").all? { |button| button.key?("disabled") }
  end

  test "roles are translation keys or plain strings, in the current locale" do
    html = I18n.with_locale(:cs) do
      render_ui do
        TeamMembers(seats: 3, used: 1) do
          TeamMemberList { TeamMember(name: "Jonas", email: "j@x.dev", role: :invited); TeamMember(name: "Ann", email: "a@x.dev", role: "Billing") }
        end
      end
    end

    assert_equal "Členové týmu", html.at_css("h3").text
    assert_equal "Obsazeno 1 z 3 míst", html.at_css("[data-appica-ui--blocks--team-members-target=seats]").text
    assert_equal [ "Pozván", "Billing" ], html.css("[data-slot=team-member-list] [data-slot=badge]").map(&:text)
    assert_equal "outline", html.at_css("[data-slot=badge]")["data-variant"]
  end

  test "without an action it runs the demo; invite: false drops the button" do
    html = render_ui { TeamMembers(invite: false) { TeamMemberList { } } }

    assert_equal "true", html.at_css("[data-slot=team-members]")["data-appica-ui--blocks--team-members-demo-value"]
    assert_nil html.at_css("h3 + p")
    assert_empty html.css("button")
  end

  test "parts outside a TeamMembers raise" do
    assert_raises(ArgumentError) { render_ui { TeamInvite() } }
  end
end
