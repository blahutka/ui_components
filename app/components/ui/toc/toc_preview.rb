# An "on this page" sidebar that follows the headings in view.
#
# The examples track a scrolling panel (`container:`) so they stay put - scroll inside it. On a
# real page leave `container:` out and the Toc follows the page.
#
# @label Table of Contents
# @logical_path Navigation
# @component UI::Toc
# @display width wide
class UI::TocPreview < UI::BasePreview
  SECTIONS = {
    "Getting started" => "Install the gem, add the engine's stylesheet and JavaScript to your app, and render components from any view. Each component lives in its own folder with its Stimulus controller and styles, so there is nothing else to wire up - drop one into a page and it renders correctly straight away.",
    "Theming" => "Colors, radii, and motion are driven by CSS variables. Override them at any level of the tree to retheme a section or the whole application, with no build step. Light and dark modes are two sets of the same variables, so a theme toggle is a single class on a parent element.",
    "Accessibility" => "Components follow the WAI-ARIA patterns - roving focus, correct roles and labelled landmarks - so keyboard and screen-reader support come built in. Focus is trapped and restored where it should be, and every interactive element is reachable by keyboard.",
    "Right-to-left" => "Logical properties mean every component mirrors cleanly under dir=\"rtl\". Padding, borders and animations flip to follow the reading direction, and arrow-key navigation and popup placement respect it too. Switching the whole app is a single attribute."
  }.freeze

  NESTED = [
    [ "Installation", 2, "Add the gem to your Gemfile and run bundle install. It works with Propshaft and import maps, so there is nothing to configure." ],
    [ "Gemfile", 3, "Reference it by path while it lives next to your app, or from a git source; the engine loads its components on boot." ],
    [ "Assets", 3, "Import the stylesheet in your Tailwind entry point and the controllers in application.js, then restart the server." ],
    [ "Usage", 2, "Include the UI kit in your Phlex views and compose the parts. Components are assembled rather than configured through long option lists." ],
    [ "Composing", 3, "Nest the parts to build the shape you want; a block that takes an argument hands a part's attributes to your own element." ],
    [ "FAQ", 2, "Answers to the questions that come up most often, from Turbo compatibility to theming. The per-component pages go deeper." ]
  ].freeze

  ICONS = { "Getting started" => :rocket, "Theming" => :palette, "Accessibility" => :accessible, "Right-to-left" => :text_direction_rtl }.freeze

  # @label Usage
  # The link for the section in view lights up and the indicator slides to it.
  # @param aria_label text
  # @param root_margin text
  # @param container text
  def default(aria_label: nil, root_margin: "0px", container: "#toc-demo-default")
    phlex do
      div(class: "flex w-full max-w-xl gap-4") do
        div(id: "toc-demo-default", class: "border-border h-64 flex-1 overflow-auto rounded-lg border p-4 [scrollbar-width:none]") do
          SECTIONS.each do |title, body|
            section(class: "mb-6 last:mb-0") do
              h3(id: "toc-default-#{title.parameterize}", class: "text-foreground-intense mb-2 scroll-mt-6 font-semibold") { title }
              p(class: "text-sm leading-relaxed") { body }
            end
          end
        end
        Toc(root_margin:, **given(aria_label:), container:, class: "w-38 shrink-0") do
          TocList { SECTIONS.each_key { |title| TocItem { TocLink(href: "#toc-default-#{title.parameterize}") { title } } } }
        end
      end
    end
  end

  # @label Nested headings
  # `depth:` (the heading level) indents deeper entries; the indicator runs down the shared rail.
  def nested
    phlex do
      div(class: "flex w-full max-w-xl gap-4") do
        div(id: "toc-demo-nested", class: "border-border h-64 flex-1 overflow-auto rounded-lg border p-4 [scrollbar-width:none]") do
          NESTED.each do |title, depth, body|
            section(class: "mb-6 last:mb-0") do
              if depth == 2
                h3(id: "toc-nested-#{title.parameterize}", class: "text-foreground-intense mb-2 scroll-mt-6 font-semibold") { title }
              else
                h4(id: "toc-nested-#{title.parameterize}", class: "text-foreground-intense mb-2 scroll-mt-6 text-sm font-medium") { title }
              end
              p(class: "text-sm leading-relaxed") { body }
            end
          end
        end
        Toc(container: "#toc-demo-nested", aria_label: "On this page", class: "w-38 shrink-0") do
          TocList { NESTED.each { |title, depth, _| TocItem { TocLink(href: "#toc-nested-#{title.parameterize}", depth:) { title } } } }
        end
      end
    end
  end

  # @label With icons
  def icons
    phlex do
      div(class: "flex w-full max-w-xl gap-4") do
        div(id: "toc-demo-icons", class: "border-border h-64 flex-1 overflow-auto rounded-lg border p-4 [scrollbar-width:none]") do
          SECTIONS.each do |title, body|
            section(class: "mb-6 last:mb-0") do
              h3(id: "toc-icons-#{title.parameterize}", class: "text-foreground-intense mb-2 scroll-mt-6 font-semibold") { title }
              p(class: "text-sm leading-relaxed") { body }
            end
          end
        end
        Toc(container: "#toc-demo-icons", class: "w-44 shrink-0") do
          TocList do
            SECTIONS.each_key do |title|
              TocItem { TocLink(href: "#toc-icons-#{title.parameterize}", class: "flex items-center gap-2") { Icon(ICONS[title]); plain title } }
            end
          end
        end
      end
    end
  end

  # @label RTL
  # The rail and indentation sit on the start edge.
  def rtl
    sections = { "البدء" => "ثبّت الحزمة واستورد المكوّن الذي تحتاجه. لا يوجد ما يتطلب الإعداد، فالمكوّنات تحمل أنماطها معها وتعمل مباشرةً عند وضعها في الصفحة.",
                 "السمات" => "تتحكم متغيرات CSS في الألوان والزوايا والحركة. يمكنك تجاوزها في أي مستوى لإعادة تنسيق قسم واحد أو التطبيق بأكمله.",
                 "إمكانية الوصول" => "تتبع المكوّنات أنماط WAI-ARIA، لذا يأتي دعم لوحة المفاتيح وقارئات الشاشة مدمجًا.",
                 "من اليمين إلى اليسار" => "تنعكس المكوّنات تلقائيًا تحت dir=\"rtl\" بفضل الخصائص المنطقية." }
    phlex do
      div(dir: "rtl", class: "flex w-full max-w-xl gap-4") do
        div(id: "toc-demo-rtl", class: "border-border h-64 flex-1 overflow-auto rounded-lg border p-4 [scrollbar-width:none]") do
          sections.each_with_index do |(title, body), index|
            section(class: "mb-6 last:mb-0") do
              h3(id: "toc-rtl-#{index}", class: "text-foreground-intense mb-2 scroll-mt-6 font-semibold") { title }
              p(class: "text-sm leading-relaxed") { body }
            end
          end
        end
        Toc(container: "#toc-demo-rtl", aria_label: "في هذه الصفحة", class: "w-38 shrink-0") do
          TocList { sections.each_key.with_index { |title, index| TocItem { TocLink(href: "#toc-rtl-#{index}") { title } } } }
        end
      end
    end
  end
end
