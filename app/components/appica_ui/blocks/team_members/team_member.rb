# One member: avatar with a presence dot, name, email and role badge. `role:` may be a
# translation key (:owner, :admin, :editor, :viewer, :invited) or any string; `online:` true/false
# shows the dot (nil hides it).
class AppicaUI::Blocks::TeamMember < AppicaUI::Blocks::Base
  prop :name
  prop :email
  prop :avatar, default: -> { nil }
  prop :role,   default: -> { nil }
  prop :online, default: -> { nil }

  def view_template
    div(**mix({ role: "listitem", data: { slot: "team-member", role: @role } }, @attributes.except(:class)), class: cn("flex items-center gap-3", override: @attributes[:class])) do
      Avatar(size: :sm) do
        AvatarImage(src: @avatar, alt: @name) if @avatar
        AvatarFallback(data: { "appica-ui--blocks--team-members-target": "initial" }) { initials }
        AvatarBadge(class: (@online ? nil : "text-foreground-subtle"), aria_label: t(@online ? ".online" : ".offline")) unless @online.nil?
      end
      div(class: "min-w-0 flex-1") do
        div(class: "text-foreground-intense truncate text-sm font-medium", data: { field: "name" }) { @name }
        div(class: "text-foreground-muted truncate text-xs", data: { field: "email" }) { @email }
      end
      Badge(variant: badge_variant, size: :sm) { role_label } if @role
    end
  end

  private
    def initials
      @name.to_s.split.first(2).map { |part| part[0] }.join.upcase
    end

    def badge_variant
      case @role
      when :owner then :primary_outline
      when :invited then :outline
      else :soft
      end
    end

    def role_label
      @role.is_a?(Symbol) ? t(".roles.#{@role}") : @role
    end
end
