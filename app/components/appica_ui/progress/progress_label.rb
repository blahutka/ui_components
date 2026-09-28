# Names the task; the root points aria-labelledby at it.
class AppicaUI::ProgressLabel < AppicaUI::Base
  def view_template(&)
    progress = consume(:progress, component: "AppicaUI::Progress")

    span(**mix({ id: progress.label_id, data: { slot: "progress-label", progress.state => "" } }, @attributes.except(:class)),
      class: cn("text-foreground-intense text-sm font-medium", override: @attributes[:class]), &)
  end
end
