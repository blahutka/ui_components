# The member rows. Its id (the root's `list_id`) is the Turbo Stream target for new members.
class Blocks::TeamMemberList < Blocks::Base
  def view_template(&)
    team = consume(:team_members, component: "Blocks::TeamMembers")

    div(**mix({ id: team.list_id, role: "list", aria_label: t(".title"), data: { slot: "team-member-list", "blocks--team-members-target": "list" } }, @attributes.except(:class)),
      class: cn("mt-4 flex flex-1 flex-col gap-4", override: @attributes[:class]), &)
  end
end
