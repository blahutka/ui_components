# A panel that slides in from a screen edge, with swipe-to-dismiss and snap points.
#
# Compound component on a native <dialog>: Drawer holds the edge and options,
# DrawerTrigger / DrawerClose accept a block with an argument to project their
# attributes onto your own Button (Appica's `render` prop).
#
# @label Drawer
# @logical_path Overlays
# @component UI::Drawer
# @display width wide
# @display min_height 32rem
class UI::DrawerPreview < UI::BasePreview
  TRACKS = [
    [ "Nightcall", "Neon Drift" ], [ "Midnight City", "Violet Skies" ], [ "Resonance", "Echo Theory" ],
    [ "A Real Hero", "Pixel Horizon" ], [ "Sunset Avenue", "The Lateliners" ], [ "Turbo Killer", "Chrome Wolf" ],
    [ "Afterglow", "Static Bloom" ], [ "Le Castle", "Power Circuit" ], [ "Tech Noir", "Ghost Signal" ], [ "Crystals", "Cassette 84" ]
  ].freeze

  EVENTS = [
    [ "Sarah Jenkins", "merged pull request #482", "2m ago" ], [ "Maya Torres", "commented on “Release checklist”", "18m ago" ],
    [ "Leo Martin", "approved pull request #480", "40m ago" ], [ "Daniel Reyes", "closed issue #311", "1h ago" ],
    [ "Priya Shah", "added a label to issue #309", "2h ago" ], [ "Emma Clarke", "deployed to production", "3h ago" ],
    [ "Sarah Jenkins", "opened pull request #485", "5h ago" ], [ "Tom Becker", "pushed 12 commits to main", "6h ago" ],
    [ "Maya Torres", "requested changes on #478", "8h ago" ], [ "Leo Martin", "linked issue #312 to #485", "11h ago" ],
    [ "Maya Torres", "invited 2 members", "Yesterday" ], [ "Nina Foster", "updated the roadmap", "Yesterday" ],
    [ "Priya Shah", "merged pull request #476", "Yesterday" ], [ "Daniel Reyes", "renamed the project", "2d ago" ],
    [ "Emma Clarke", "archived 4 tasks", "2d ago" ], [ "Tom Becker", "reverted commit 9f3c1a", "3d ago" ],
    [ "Sarah Jenkins", "created milestone “v2.0”", "3d ago" ], [ "Leo Martin", "closed issue #298", "4d ago" ],
    [ "Nina Foster", "edited the README", "5d ago" ], [ "Priya Shah", "opened pull request #470", "5d ago" ],
    [ "Daniel Reyes", "added 3 members", "6d ago" ], [ "Emma Clarke", "set up continuous integration", "1w ago" ],
    [ "Tom Becker", "imported the codebase", "1w ago" ], [ "Sarah Jenkins", "created the project", "2w ago" ]
  ].freeze

  # @label Usage
  # @param side [Symbol] select "Edge the drawer slides in from; the swipe direction follows" { choices: [top, right, bottom, left] }
  # @param close_button [Boolean] toggle "Corner × button"
  # @param frame [Boolean] toggle "Translucent glass frame around the panel (needs the backdrop)"
  # @param disable_pointer_dismissal [Boolean] toggle "Keep the drawer open when the backdrop is clicked"
  def default(side: :right, close_button: true, frame: true, disable_pointer_dismissal: false)
    phlex do
      Drawer(side:, disable_pointer_dismissal:) do
        DrawerTrigger { |trigger| Button(**trigger, variant: :outline) { "Open drawer" } }
        DrawerContent(close_button:, frame:, class: ("mx-auto max-w-2xl" if side.to_sym.in?(%i[ top bottom ]))) do
          DrawerHeader do
            DrawerTitle { "Notifications" }
            DrawerDescription { "Choose what you want to be notified about." }
          end
          DrawerBody do
            p { "Drag the handle or swipe toward the edge to dismiss. On the #{side} edge the panel slides in from there." }
          end
          DrawerFooter do
            DrawerClose { |close| Button(**close) { "Save" } }
            DrawerClose { |close| Button(**close, variant: :outline) { "Cancel" } }
          end
        end
      end
    end
  end

  # `side:` picks the edge; the swipe-to-dismiss direction follows.
  # Cap top/bottom sheets (`mx-auto max-w-2xl`) so they don't stretch edge-to-edge.
  def sides
    phlex do
      div(class: "flex flex-wrap items-center justify-center gap-3") do
        [ :top, :right, :bottom, :left ].each do |side|
          label = side.to_s.capitalize
          wide = side.in?(%i[ top bottom ])

          Drawer(side:) do
            DrawerTrigger { |trigger| Button(**trigger, variant: :outline) { label } }
            DrawerContent(class: ("mx-auto max-w-2xl" if wide)) do
              DrawerHeader do
                DrawerTitle { "#{label} drawer" }
                DrawerDescription { "This panel slides in from the #{side} edge." }
              end
              DrawerBody { p { "Drag the handle or swipe toward the #{side} edge to dismiss it." } }
              DrawerFooter do
                DrawerClose { |close| Button(**close, variant: :outline) { "Close" } }
              end
            end
          end
        end
      end
    end
  end

  # @!group Long content
  #
  # @label Snap points
  # `snap_points:` lets a top or bottom drawer rest at intermediate heights: a fraction of the
  # viewport (0-1), pixels (> 1) or a CSS length ("24rem"). It opens at the first point and
  # dismisses when dragged past the smallest.
  def snap_points
    phlex do
      Drawer(snap_points: [ 0.4, 1 ]) do
        DrawerTrigger { |trigger| Button(**trigger, variant: :outline) { "Open player" } }
        DrawerContent(class: "mx-auto max-w-2xl") do
          DrawerHeader do
            DrawerTitle { "Up next" }
            DrawerDescription { "Drag the sheet to a snap point - peek at 40% or pull it to full height." }
          end
          div(class: "min-h-0 flex-1 overflow-y-auto") do
            div(class: "flex flex-col gap-5 px-6 pb-6") do
              TRACKS.each do |title, artist|
                div(class: "flex items-center gap-3") do
                  span(class: "bg-background-muted text-foreground-muted flex size-9 shrink-0 items-center justify-center rounded-md") do
                    svg(viewBox: "0 0 24 24", fill: "none", stroke: "currentColor", stroke_width: "1.5", stroke_linecap: "round", stroke_linejoin: "round", class: "size-4.5", aria_hidden: "true") do |s|
                      s.path(d: "M9 18V5l12-2v13M9 18a3 3 0 1 1-6 0 3 3 0 0 1 6 0m12-2a3 3 0 1 1-6 0 3 3 0 0 1 6 0")
                    end
                  end
                  span(class: "flex min-w-0 flex-col") do
                    span(class: "text-foreground-intense truncate text-sm font-medium") { title }
                    span(class: "text-foreground-muted truncate text-xs") { artist }
                  end
                end
              end
            end
          end
        end
      end
    end
  end

  # @label Scrollable content
  # DrawerBody owns the overflow between a pinned header and footer. A left/right drawer
  # swipes horizontally, so it never fights the vertical scroll.
  def scrollable
    phlex do
      Drawer(side: :right) do
        DrawerTrigger { |trigger| Button(**trigger, variant: :outline) { "View activity" } }
        DrawerContent do
          DrawerHeader do
            DrawerTitle { "Activity" }
            DrawerDescription { "Everything that happened in this project." }
          end
          DrawerBody do
            ol(class: "flex flex-col gap-4 pb-2") do
              EVENTS.each do |who, what, time|
                li(class: "flex flex-col gap-0.5") do
                  p(class: "text-sm") do
                    span(class: "text-foreground-intense font-medium") { who }
                    plain " #{what}"
                  end
                  p(class: "text-foreground-muted text-xs") { time }
                end
              end
            end
          end
          DrawerFooter do
            DrawerClose { |close| Button(**close, variant: :outline) { "Close" } }
          end
        end
      end
    end
  end

  # @!endgroup

  # @label Nested drawers
  # A drawer can open another drawer: the parent tucks back as the child slides in,
  # and the child renders without a backdrop, as a solid card.
  def nested
    phlex do
      Drawer(side: :right) do
        DrawerTrigger { |trigger| Button(**trigger, variant: :outline) { "Workspace" } }
        DrawerContent do
          DrawerHeader do
            DrawerTitle { "Workspace" }
            DrawerDescription { "Manage the workspace and its members." }
          end
          DrawerBody(class: "flex flex-col items-start gap-3") do
            p { "Open a sub-panel to rename the workspace - the parent tucks back to show the stack." }

            Drawer(side: :right) do
              DrawerTrigger do |trigger|
                Button(**trigger) do
                  svg(viewBox: "0 0 24 24", fill: "none", stroke: "currentColor", stroke_width: "1.5", stroke_linecap: "round", stroke_linejoin: "round", aria_hidden: "true", data: { icon: "start" }) do |s|
                    s.path(d: "M4 20h4L18.5 9.5a2.8 2.8 0 0 0-4-4L4 16zm9.5-13.5 4 4")
                  end
                  plain "Rename workspace"
                end
              end
              DrawerContent(close_button: false) do
                DrawerHeader do
                  DrawerTitle { "Rename workspace" }
                  DrawerDescription { "This name is visible to everyone on the team." }
                end
                DrawerBody do
                  label(class: "flex flex-col gap-2 text-sm") do
                    span(class: "text-foreground-emphasis font-medium") { "Workspace name" }
                    input(value: "Appica", class: "border-border-strong bg-background text-foreground focus:ring-ring-input h-10 rounded-md border px-3.5 outline-none focus:border-transparent focus:ring-3")
                  end
                end
                DrawerFooter do
                  DrawerClose { |close| Button(**close) { "Save" } }
                  DrawerClose { |close| Button(**close, variant: :outline) { "Cancel" } }
                end
              end
            end
          end
        end
      end
    end
  end

  # @label RTL
  # The header, body and footer read right-to-left; set `dir: "rtl"` on DrawerContent
  # when RTL is scoped to part of an LTR page.
  def rtl
    phlex do
      div(dir: "rtl") do
        Drawer(side: :bottom) do
          DrawerTrigger { |trigger| Button(**trigger, variant: :outline) { "الإعدادات" } }
          DrawerContent(dir: "rtl", class: "mx-auto max-w-2xl") do
            DrawerHeader do
              DrawerTitle { "الإعدادات" }
              DrawerDescription { "اختر ما تريد أن يتم إعلامك به." }
            end
            DrawerFooter do
              DrawerClose { |close| Button(**close) { "حفظ" } }
              DrawerClose { |close| Button(**close, variant: :outline) { "إلغاء" } }
            end
          end
        end
      end
    end
  end
end
