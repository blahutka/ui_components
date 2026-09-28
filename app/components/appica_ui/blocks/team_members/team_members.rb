# A team card: the member list with roles and presence, a seat count and an invite-by-email
# form - composed from Avatar, Badge, Button, Icon and Separator.
#
#   TeamMembers(seats: 5, used: members.size, action: invitations_path) do
#     TeamMemberList do
#       members.each { |m| TeamMember(name: m.name, email: m.email, avatar: m.avatar_url, role: m.role, online: m.online?) }
#     end
#     TeamInvite()
#   end
#
# The invite form posts `email` to `action:` (Turbo submits it); answer with
# `turbo_stream.append list_id, AppicaUI::Blocks::TeamMember.new(email:, role: :invited)` - the seat count
# follows the rows and the form disables when every seat is taken. Without an `action:` it runs a
# demo that adds the invited row itself. Strings: team_members.locales.yml.
class AppicaUI::Blocks::TeamMembers < AppicaUI::Blocks::Base
  prop :seats,   default: -> { nil }
  prop :used,    default: -> { 0 }
  prop :title,   default: -> { t(".title") }
  prop :action,  default: -> { nil }
  prop :method,  default: -> { :post }
  prop :invite,  default: -> { true }
  prop :list_id, default: -> { "team-members-#{SecureRandom.hex(4)}" }

  attr_reader :seats, :action, :method, :list_id

  def full?
    @seats && @used >= @seats
  end

  def view_template(&)
    provide(:team_members, self) do
      div(**mix(defaults(data: root_data), @attributes.except(:class)), class: cn(
        "bg-background border-border-muted flex flex-col rounded-xl border p-6 shadow-lg dark:shadow-[0_8px_16px_-4px_rgba(0,0,0,0.8)]",
        override: @attributes[:class]
      )) do
        header
        yield if block_given?
        template(data: { "appica-ui--blocks--team-members-target": "memberTemplate" }) { TeamMember(name: "", email: "", role: :invited) }
      end
    end
  end

  private
    def root_data
      {
        slot: "team-members", controller: "appica-ui--blocks--team-members",
        "appica-ui--blocks--team-members-demo-value": @action.nil?.to_s,
        "appica-ui--blocks--team-members-seats-value": @seats,
        # %{used} / %{seats} are filled in by the controller as rows are added
        "appica-ui--blocks--team-members-seats-label-value": t(".seats", used: "%{used}", seats: "%{seats}")
      }
    end

    def header
      div(class: "flex items-center justify-between gap-2") do
        div do
          h3(class: "text-foreground-intense text-sm font-semibold") { @title }
          p(class: "text-foreground-muted text-xs", data: { "appica-ui--blocks--team-members-target": "seats" }) { t(".seats", used: @used, seats: @seats) } if @seats
        end
        if @invite
          Button(variant: :outline, size: :sm, disabled: full?, data: { "appica-ui--blocks--team-members-target": "inviteButton", action: "appica-ui--blocks--team-members#focus" }) do
            Icon(:plus, data: { icon: "start" })
            plain t(".invite.button")
          end
        end
      end
    end
end
