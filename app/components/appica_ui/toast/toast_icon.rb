# The leading glyph of a toast: success, error, warning, info, loading (a spinner) or bell.
# `thumbnail: true` wraps it in a tinted badge for more prominence.
class AppicaUI::ToastIcon < AppicaUI::Base
  KINDS = %i[ success error warning info loading bell ].freeze

  COLORS = {
    success: "text-success-emphasis", error: "text-error-emphasis", warning: "text-warning-emphasis",
    info: "text-info-emphasis", loading: "text-foreground-muted", bell: "text-foreground-intense"
  }.freeze

  THUMBNAILS = {
    success: "bg-success-subtle text-success-emphasis", error: "bg-error-subtle text-error-emphasis",
    warning: "bg-warning-subtle text-warning-emphasis", info: "bg-info-subtle text-info-emphasis",
    loading: "bg-background-muted text-foreground-intense", bell: "bg-background-muted text-foreground-intense"
  }.freeze

  # Appica icons: filled glyphs on their own, outlined ones inside a thumbnail
  ICONS = {
    success: %i[ circle_check_filled circle_check ], error: %i[ circle_x_filled circle_x ],
    warning: %i[ alert_triangle_filled alert_triangle ], info: %i[ info_circle_filled info_circle ],
    bell: %i[ bell bell ]
  }.freeze

  prop :kind,      one_of(KINDS, :info)
  prop :thumbnail, default: -> { false }

  def view_template
    if @thumbnail
      span(class: cn("flex size-8 shrink-0 items-center justify-center rounded-md [&>svg]:size-4.5", THUMBNAILS[@kind]), data: { slot: "toast-thumbnail" }) { glyph }
    else
      glyph
    end
  end

  private
    def glyph
      if @kind == :loading
        render AppicaUI::Spinner.new(current_color: true, aria_label: "Loading", class: cn(@thumbnail ? "text-[1.125rem]" : "#{COLORS[:loading]} h-lh text-xl"))
      else
        filled, outlined = ICONS[@kind]
        render AppicaUI::Icon.new(@thumbnail ? outlined : filled, stroke_width: 1.75, class: (COLORS[@kind] unless @thumbnail))
      end
    end
end
