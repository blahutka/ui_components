# The social-proof footer under a separator: a few reviewer avatars and a line of text.
#
#   ReviewHighlight(avatars: [ { src: "/avatars/02.png", alt: "Liam Hudson" } ]) { "Loved by 12,000+ shoppers" }
class Blocks::ReviewHighlight < Blocks::Base
  prop :avatars, default: -> { [] }

  def view_template(&)
    Separator(class: "my-4")
    div(**mix({ data: { slot: "review-highlight" } }, @attributes.except(:class)), class: cn("flex items-center gap-3", override: @attributes[:class])) do
      if @avatars.any?
        AvatarGroup(size: :xs) do
          @avatars.each do |avatar|
            Avatar do
              AvatarImage(src: avatar[:src], alt: avatar[:alt].to_s)
              AvatarFallback { avatar[:alt].to_s.split.map { |part| part[0] }.join.first(2) }
            end
          end
        end
      end
      span(class: "text-foreground-muted text-xs", &)
    end
  end
end
