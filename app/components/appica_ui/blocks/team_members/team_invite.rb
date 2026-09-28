# The invite form under a divider: an email field with a send button. Posts `name:` to the
# root's `action:`; disabled while every seat is taken.
class AppicaUI::Blocks::TeamInvite < AppicaUI::Blocks::Base
  INPUT = "bg-background-muted text-foreground flex h-10 w-full items-center gap-2 rounded-md border border-transparent px-3.5 text-sm outline-none " \
    "transition-[background-color,border-color,box-shadow] duration-200 motion-reduce:transition-none hover:not-has-focus:border-border-strong " \
    "has-focus:bg-background has-focus:border-transparent has-focus:ring-3 has-focus:ring-ring-input " \
    "data-invalid:bg-error-subtle data-invalid:border-error data-invalid:has-focus:ring-ring-error " \
    "has-[input:disabled]:bg-background-subtle! has-[input:disabled]:border-border-strong! has-[input:disabled]:border-dashed has-[input:disabled]:opacity-disabled"

  prop :placeholder, default: -> { t(".invite.placeholder") }
  prop :name,        default: -> { "email" }
  prop :label,       default: -> { t(".invite.label") }

  def view_template
    team = consume(:team_members, component: "AppicaUI::Blocks::TeamMembers")
    full = team.full?

    Separator(class: "my-4")
    form(**mix({ action: team.action || "#", method: team.method, novalidate: true, data: { slot: "team-invite", action: "appica-ui--blocks--team-members#invite" } }, @attributes.except(:class)),
      class: cn(INPUT, override: @attributes[:class])) do
      input(type: "email", name: @name, required: true, autocomplete: "off", disabled: full, aria_label: @label,
        placeholder: (full ? t(".invite.full") : @placeholder), data: { "appica-ui--blocks--team-members-target": "input", action: "input->appica-ui--blocks--team-members#clearError", placeholder: @placeholder, full: t(".invite.full"), invalid: t(".invite.invalid") },
        class: "text-foreground placeholder:text-foreground-subtle h-full min-w-0 flex-1 bg-transparent outline-none disabled:cursor-not-allowed")
      Button(type: "submit", variant: :outline, size: :sm, icon: true, disabled: full, aria_label: t(".invite.send"), class: "-me-2",
        data: { "appica-ui--blocks--team-members-target": "send" }) { Icon(:plus) }
    end
  end
end
