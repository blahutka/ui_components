# A flexible content container for a title, description, media and actions.
#
#   Card do
#     CardMedia(class: "h-44") { img(src: trip.photo_url, alt: trip.name) }
#     CardHeader do
#       CardTitle { trip.name }
#       CardDescription { trip.summary }
#     end
#     CardFooter { Button { "Book now" } }
#   end
#
# Renders an outer frame plus an inner content wrapper (a flex column holding the slots).
# One radius drives everything: set `--card-radius` (default `var(--radius-xl)`) and the
# frame (×4/3) and inset media (×3/4) scale with it.
class UI::Card < UI::Base
  FRAMES = {
    none: "rounded-(--card-radius)",
    solid: "rounded-[calc(var(--card-radius)*4/3)] bg-background-subtle p-2 backdrop-blur-md",
    glass: "rounded-[calc(var(--card-radius)*4/3)] border border-white/15 bg-white/10 p-2 backdrop-blur-sm"
  }.freeze

  CONTENT = "bg-background flex min-h-0 flex-1 flex-col overflow-hidden rounded-(--card-radius)"

  # The inner hairline: none on glass, softened inside a solid frame
  CONTENT_BORDERS = { none: "border", solid: "border-border-muted border", glass: nil }.freeze

  TAGS = %i[ div article section li form a ].freeze

  def initialize(frame: false, inset: true, as: :div, content: {}, **attributes)
    @frame = case frame
    when true then :solid
    when false, nil then :none
    else FRAMES.key?(frame.to_sym) ? frame.to_sym : :none
    end
    @inset = inset
    @tag = TAGS.include?(as.to_sym) ? as.to_sym : :div
    @content = content
    @attributes = attributes
  end

  def view_template(&)
    send(@tag, **mix(root_attributes, @attributes.except(:class)), class: cn(root_classes, override: @attributes[:class])) do
      div(**mix({ data: { slot: "card-content" } }, @content.except(:class)),
          class: cn(CONTENT, ("p-2" if @inset), CONTENT_BORDERS[@frame], override: @content[:class]), &)
    end
  end

  private
    # --card-radius comes first so a caller's [--card-radius:…] class wins
    def root_classes
      [ "group/card flex flex-col [--card-radius:var(--radius-xl)]", FRAMES[@frame] ]
    end

    def root_attributes
      { data: { slot: "card", frame: @frame, inset: (@inset ? "" : nil) } }
    end
end
