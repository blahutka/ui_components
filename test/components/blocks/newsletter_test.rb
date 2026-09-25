require "test_helper"

class Blocks::NewsletterTest < ComponentTestCase
  test "renders the pitch, perks, the email form with a honeypot and social links" do
    html = render_ui do
      Newsletter(action: "/subscriptions", socials: [ { href: "https://github.com/acme", icon: :brand_github, label: "GitHub" } ]) do
        NewsletterPerk(icon: :sparkles) { "Major library updates" }
      end
    end

    section = html.at_css("section[data-slot=newsletter]")
    assert_equal [ "blocks--newsletter", "false" ], [ section["data-controller"], section["data-blocks--newsletter-demo-value"] ]
    assert_equal "Stay connected. Stay updated.", section.at_css("h2").text
    assert_equal "Major library updates", section.at_css("[data-slot=newsletter-perk]").text.strip
    assert section.at_css("[data-slot=newsletter-perk] [data-slot=thumbnail] svg")

    form = section.at_css("form")
    assert_equal [ "/subscriptions", "post", "Newsletter subscription" ], %w[action method aria-label].map { |name| form[name] }
    assert_equal "-1", form.at_css("input[name=website]")["tabindex"]
    email = form.at_css("input[type=email]")
    assert_equal [ "email", "email", "Your Email" ], %w[name autocomplete placeholder].map { |name| email[name] }
    assert email.key?("required")
    assert_equal "Email", form.at_css("label[for='#{email["id"]}']").text
    assert_equal "Subscribe", form.at_css("button[type=submit]")["aria-label"]
    assert_equal "No spam. Just updates.", form.at_css("[data-slot=newsletter-note]").text
    assert form.at_css("[role=status]")

    link = section.at_css("nav[aria-label=Social] a")
    assert_equal [ "https://github.com/acme", "GitHub", "_blank" ], %w[href aria-label target].map { |name| link[name] }
  end

  test "without an action it's a demo and the optional parts are dropped" do
    html = render_ui { Newsletter(title: "Changelog", description: nil) }

    assert_equal "true", html.at_css("[data-slot=newsletter]")["data-blocks--newsletter-demo-value"]
    assert_equal "Changelog", html.at_css("h2").text
    assert_nil html.at_css("[data-slot=newsletter-perks]")
    assert_nil html.at_css("nav")
    assert_nil html.at_css("input[name=authenticity_token]")
  end
end
