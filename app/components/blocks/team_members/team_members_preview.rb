# A team card: members with roles and presence, a seat count and an invite-by-email form -
# composed from Avatar, Badge, Button and Icon.
#
# The preview runs a demo: invite an email and it joins the list as "Invited", the seat count
# follows and the form locks once every seat is taken. In an app, give it an `action:` and reply
# with a Turbo Stream. Localized - try the toolbar's **Locale** option.
#
# @label Team members
# @logical_path Blocks
# @component Blocks::TeamMembers
# @display width wide
class Blocks::TeamMembersPreview < UI::BasePreview
  # Props not in the Usage form (data, render blocks, generated ids): see ui_components:preview_params
  UNLISTED_PROPS = %i[ action list_id used ].freeze

  MEMBERS = [
    { name: "Sarah Jenkins", email: "sarah@appica.dev", avatar: "/avatars/01.png", role: :owner, online: true },
    { name: "Mateo Rossi", email: "mateo@appica.dev", avatar: "/avatars/03.png", role: :editor, online: true },
    { name: "Lucas Müller", email: "lucas@appica.dev", avatar: "/avatars/06.png", role: :viewer, online: false },
    { name: "Emily Carter", email: "emily@appica.dev", avatar: "/avatars/07.png", role: :editor, online: true }
  ].freeze

  # @label Usage
  # The Appica homepage card. Invite an email to add a row; at five members the form locks.
  # @param seats number
  # @param title text
  # @param method text
  # @param invite [Boolean] toggle
  def default(seats: 5, title: nil, method: "post", invite: true)
    phlex do
      TeamMembers(method:, invite:, **given(title:), seats: seats.to_i, used: MEMBERS.size, class: "w-100 max-w-full") do
        TeamMemberList do
          MEMBERS.each { |member| TeamMember(**member) }
        end
        TeamInvite(placeholder: "teammate@appica.dev")
      end
    end
  end

  # @label All seats taken
  # When `used:` reaches `seats:` the Invite button and the form are disabled.
  def full
    phlex do
      TeamMembers(seats: 4, used: 4, class: "w-100 max-w-full") do
        TeamMemberList { MEMBERS.each { |member| TeamMember(**member) } }
        TeamInvite()
      end
    end
  end

  # @label Roles & pending invites
  # Roles are translation keys (:owner, :admin, :editor, :viewer, :invited) or any string. Members
  # without an avatar show their initials; `online: nil` hides the presence dot.
  def roles
    phlex do
      TeamMembers(seats: 10, used: 5, class: "w-100 max-w-full") do
        TeamMemberList do
          TeamMember(**MEMBERS[0])
          TeamMember(name: "Priya Nair", email: "priya@appica.dev", role: :admin, online: true)
          TeamMember(name: "Jonas Berg", email: "jonas@appica.dev", avatar: "/avatars/05.png", role: "Billing", online: false)
          TeamMember(name: "Invited Teammate", email: "new.hire@appica.dev", role: :invited)
          TeamMember(name: "Chen Wei", email: "chen@appica.dev", avatar: "/avatars/08.png", role: :viewer)
        end
        TeamInvite()
      end
    end
  end

  # @label Read-only
  # `invite: false` drops the Invite button; leave out TeamInvite and `seats:` for a plain list.
  def read_only
    phlex do
      TeamMembers(invite: false, class: "w-100 max-w-full") do
        TeamMemberList { MEMBERS.first(3).each { |member| TeamMember(**member) } }
      end
    end
  end

  # @label RTL
  # Rendered in Arabic whatever the toolbar says: avatars lead from the right, roles and the send
  # button sit on the left.
  def rtl
    phlex do
      I18n.with_locale(:ar) do
        div(dir: "rtl") do
          TeamMembers(seats: 5, used: 3, class: "w-100 max-w-full") do
            TeamMemberList { MEMBERS.first(3).each { |member| TeamMember(**member) } }
            TeamInvite()
          end
        end
      end
    end
  end
end
