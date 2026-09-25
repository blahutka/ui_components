# A newsletter signup: a heading, a pitch, a list of perks, an email form with a spam honeypot
# and a note, and social links - composed from Field, Input, Button, Thumbnail and Icon.
#
#   Newsletter(action: subscriptions_path, socials: [ { href: "https://github.com/acme", icon: :brand_github, label: "GitHub" } ]) do
#     NewsletterPerk(icon: :sparkles) { "Major library updates" }
#     NewsletterPerk(icon: :template) { "Premium templates" }
#   end
#
# The form posts `email` to `action:` (Turbo submits it) once the browser has validated it; a bot
# filling the hidden `website` field is dropped. On success the note turns into a thank-you and
# `blocks--newsletter:subscribed` fires with { email }. Without an `action:` it runs a demo.
# Strings: newsletter.locales.yml.
class Blocks::Newsletter < Blocks::Base
  prop :title,       default: -> { t(".title") }
  prop :description, default: -> { t(".description") }
  prop :note,        default: -> { t(".note") }
  prop :action,      default: -> { nil }
  prop :method,      default: -> { :post }
  prop :honeypot,    default: -> { "website" }
  prop :socials,     default: -> { [] }

  def view_template(&)
    section(**mix(defaults(data: {
      slot: "newsletter", controller: "blocks--newsletter", "blocks--newsletter-demo-value": @action.nil?.to_s,
      "blocks--newsletter-thanks-value": t(".thanks")
    }), @attributes.except(:class)), class: @attributes[:class]) do
      h2(class: "text-foreground-intense text-3xl font-semibold md:text-4xl") { @title }
      p(class: "text-foreground mt-5 md:max-w-105") { @description } if @description
      ul(class: "mt-8 flex flex-col gap-3.5", data: { slot: "newsletter-perks" }, &) if block_given?
      signup_form
      social_links if @socials.any?
    end
  end

  private
    def signup_form
      form(action: @action || "#", method: (@method.to_s == "get" ? "get" : "post"), aria_label: t(".form"), class: "mt-10 w-full md:max-w-105",
        data: { slot: "newsletter-form", "blocks--newsletter-target": "form",
          action: "submit->blocks--newsletter#submit turbo:submit-end->blocks--newsletter#submitted" }) do
        token = authenticity_token
        input(type: "hidden", name: "authenticity_token", value: token, autocomplete: "off") if token
        div(aria_hidden: "true", class: "absolute -start-[9999px] size-px overflow-hidden") do
          label do
            plain t(".honeypot")
            input(type: "text", name: @honeypot, tabindex: "-1", autocomplete: "off", data: { "blocks--newsletter-target": "honeypot" })
          end
        end
        div(class: "flex items-start gap-2.5") do
          Field(name: "email", class: "flex-1", messages: { value_missing: t(".missing"), type_mismatch: t(".invalid") }) do
            FieldLabel(class: "sr-only") { t(".email") }
            Input(type: "email", size: :lg, autocomplete: "email", placeholder: t(".placeholder"), required: true,
              data: { "blocks--newsletter-target": "email" })
            FieldError()
          end
          submit_button
        end
        div(class: "mt-3 text-sm") do
          p(role: "status", class: "sr-only", data: { "blocks--newsletter-target": "status" })
          p(class: "text-foreground-subtle data-success:text-success-emphasis", data: { slot: "newsletter-note", "blocks--newsletter-target": "note" }) { @note }
        end
      end
    end

    # The arrow flies out to the top-right and a new one flies in on hover / focus
    def submit_button
      Button(type: "submit", size: :lg, icon: true, class: "group", aria_label: t(".subscribe"), data: { "blocks--newsletter-target": "submit" }) do
        span(class: "relative grid size-5 place-items-center overflow-hidden rtl:-scale-x-100") do
          motion = "col-start-1 row-start-1 transition-transform duration-350 ease-out motion-reduce:transition-none"
          Icon(:arrow_up_right, class: "#{motion} motion-safe:group-hover:translate-x-full motion-safe:group-hover:-translate-y-full " \
            "motion-safe:group-focus-visible:translate-x-full motion-safe:group-focus-visible:-translate-y-full")
          Icon(:arrow_up_right, class: "#{motion} -translate-x-full translate-y-full motion-safe:group-hover:translate-x-0 motion-safe:group-hover:translate-y-0 " \
            "motion-safe:group-focus-visible:translate-x-0 motion-safe:group-focus-visible:translate-y-0")
        end
      end
    end

    def social_links
      nav(aria_label: t(".social"), class: "mt-8 flex items-center gap-2", data: { slot: "newsletter-social" }) do
        @socials.each do |social|
          Button(href: social[:href], target: "_blank", rel: "noreferrer", variant: :soft, icon: true, aria_label: social[:label]) { Icon(social[:icon]) }
        end
      end
    end

    # Rails' CSRF token when rendered in a request with forgery protection
    def authenticity_token
      view_context.form_authenticity_token if @action && view_context.protect_against_forgery?
    rescue StandardError
      nil
    end
end
