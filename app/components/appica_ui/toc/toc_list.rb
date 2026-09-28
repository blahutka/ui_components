# The Toc's list: a rail along the start edge with the active indicator.
class AppicaUI::TocList < AppicaUI::Base
  LIST = "border-border relative flex flex-col border-s before:pointer-events-none before:absolute before:-inset-s-px before:w-0.5 " \
    "before:top-(--toc-indicator-top) before:h-(--toc-indicator-height) before:bg-foreground-intense " \
    "before:transition-opacity before:duration-300 before:ease-out data-ready:before:transition-[top,height,opacity] motion-reduce:before:transition-none " \
    "before:opacity-0 data-visible:before:opacity-100"

  def view_template(&)
    ul(**mix({ role: "list", style: "--toc-indicator-top: 0px; --toc-indicator-height: 0px", data: { slot: "toc-list", "appica-ui--toc-target": "list" } }, @attributes.except(:class)),
      class: cn(LIST, override: @attributes[:class]), &)
  end
end
